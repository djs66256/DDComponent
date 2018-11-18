//
//  DDTableViewComponentCache.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#ifndef DDTableViewComponentCache_h
#define DDTableViewComponentCache_h

#include <vector>
#include <unordered_map>
#include <mutex>
#include <cstdint>
#include <tuple>
#include <memory>
#import <UIKit/UIKit.h>
#import "DDTableViewResponds.h"
#import "DDTableViewComponentProtocol.h"
#import "DDTableViewCompositeComponentProtocol.h"

@class DDTableViewSectionComponent;
namespace DD {
    namespace TableViewComponent {
        class RespondsManager {
        public:
            static RespondsManager& getInstance() {
                static RespondsManager *g_manager = nil;
                std::once_flag flag;
                std::call_once(flag, [](){
                    g_manager = new RespondsManager;
                });
                return *g_manager;
            }
            
            const TableViewResponds* respondsForObject(id<NSObject> obj) {
                if (obj == nil) return nullptr;
                
                std::uintptr_t ptr = reinterpret_cast<std::uintptr_t>(obj.class);
                
                if (std::get<0>(lastCache_) == ptr) return std::get<1>(lastCache_);
                
                auto responds = cache_.find(ptr);
                if (responds != cache_.end()) {
                    lastCache_ = std::make_pair(ptr, responds->second);
                    return responds->second;
                }
                else {
                    cache_[ptr] = new TableViewResponds(obj);
                    return cache_[ptr];
                }
            }
            
        private:
            RespondsManager() {}
            std::unordered_map<std::uintptr_t, TableViewResponds*> cache_;
            // At some time, we get a list of component that is the same type.
            std::pair<std::uintptr_t, TableViewResponds*> lastCache_ = std::make_pair(-1, nullptr);
        };
        
        class SectionCache {
        public:
            class Iterator {
            public:
                Iterator(SectionCache* cache): cache_(cache) {}
                Iterator(SectionCache* cache, size_t idx): cache_(cache), index_(idx) {}
                
                NSRange& range() { return cache_->indexPaths_[index_]; }
                DDTableViewSectionComponent* component() { return cache_->components_[index_]; }
                const TableViewResponds* responds() { return cache_->responds_[index_]; }
                
                friend bool operator== (const Iterator& l, const Iterator& r) { return l.index_ == r.index_; }
            private:
                SectionCache* cache_;
                size_t index_ = NSNotFound;
            };
            
            void fill(NSArray<DDTableViewSectionComponent*> *components, UITableView *tableView) {
                indexPaths_.clear();
                responds_.clear();
                indexPaths_.reserve(components.count);
                responds_.reserve(components.count);
                components_ = components;
                
                NSUInteger location = 0;
                TableViewResponds totalResponds;
                const TableViewResponds *rs, *prev = nullptr;
                auto manager = RespondsManager::getInstance();
                for (DDTableViewSectionComponent* comp in components) {
                    NSRange r = { location, static_cast<NSUInteger>([comp numberOfSectionsInTableView:tableView]) };
                    indexPaths_.push_back(r);
                    location += r.length;
                    if ([comp conformsToProtocol:@protocol(DDTableViewCompositeComponentProtocol)]) {
                        id<DDTableViewCompositeComponentProtocol> compositeComp = (id<DDTableViewCompositeComponentProtocol>)comp;
                        rs = compositeComp.respondsInfo;
                    }
                    else {
                        rs = manager.respondsForObject(comp);
                    }
                    responds_.push_back(rs);
                    // At some time, we get a list of component that is the same type.
                    if (prev != rs) {
                        totalResponds |= (*rs);
                    }
                    prev = rs;
                }
                myResponds_ = totalResponds;
            }
            
            Iterator begin() { return Iterator(this, indexPaths_.size() > 0 ? 0 : NSNotFound); }
            Iterator end() { return Iterator(this); }
            Iterator getSection(NSInteger section) {
                for (NSInteger i = 0; i < indexPaths_.size(); ++i) {
                    auto& r = indexPaths_[i];
                    if (r.location <= section && r.location + r.length > section) {
                        return Iterator(this, i);
                    }
                }
                NSCAssert(false, @"Can not find info in section %zd!", section);
                return end();
            }
            Iterator getComponent(id<DDTableViewComponentProtocol> comp) {
                auto idx = [components_ indexOfObject:comp];
                return Iterator(this, idx);
            }
            
            const TableViewResponds* myResponds() { return &myResponds_; }
            
            NSInteger numberOfSection() {
                if (indexPaths_.size()) {
                    auto& last = indexPaths_[indexPaths_.size() - 1];
                    return last.location + last.length;
                }
                return 0;
            }
            
        private:
            TableViewResponds myResponds_;
            std::vector<NSRange> indexPaths_;
            std::vector<const TableViewResponds*> responds_;
            __strong NSArray<DDTableViewSectionComponent*> *components_ = nil;
        };
        
        class RowCache {
        public:
            class Iterator {
            public:
                Iterator(RowCache* cache): cache_(cache) {}
                Iterator(RowCache* cache, size_t idx): cache_(cache), index_(idx) {}
                
                id<DDTableViewComponentProtocol> component() { return cache_->components_[index_]; }
                const TableViewResponds* responds() { return cache_->responds_[index_]; }
                size_t index() { return index_; }
                
                friend bool operator== (const Iterator& l, const Iterator& r) { return l.index_ == r.index_; }
            private:
                RowCache *cache_;
                size_t index_ = NSNotFound;
            };
            
            Iterator begin() { return Iterator(this, responds_.size() > 0 ? 0 : NSNotFound); }
            Iterator end() { return Iterator(this); }
            Iterator getRow(NSInteger row) {
                if (row < responds_.size()) {
                    return Iterator(this, row);
                }
                NSCAssert(false, @"Can not find info at row %zd!", row);
                return end();
            }
            Iterator getComponent(id<DDTableViewComponentProtocol> comp) {
                auto idx = [components_ indexOfObject:comp];
                return Iterator(this, idx);
            }
            
            void fill(NSArray<id<DDTableViewComponentProtocol>> *components, UITableView *tableView) {
                responds_.clear();
                responds_.reserve(components.count);
                components_ = components;
                
                auto manager = RespondsManager::getInstance();
                TableViewResponds totalResponds;
                const TableViewResponds *rs, *prev = nullptr;
                for (id<DDTableViewComponentProtocol> comp in components) {
                    rs = manager.respondsForObject(comp);
                    responds_.push_back(rs);
                    if (prev != rs) {
                        totalResponds |= (*rs);
                    }
                    prev = rs;
                }
                myResponds_ = totalResponds;
            }
            
            const TableViewResponds* myResponds() { return &myResponds_; }
            
            NSInteger numberOfRows() { return responds_.size(); }
            
        private:
            TableViewResponds myResponds_;
            std::vector<const TableViewResponds*> responds_;
            __strong NSArray<id<DDTableViewComponentProtocol>> *components_ = nil;
        };
        
        class HeaderFooterCache {
        public:
            void fill(id<DDTableViewComponentProtocol> self, id<DDTableViewComponentProtocol> header, id<DDTableViewComponentProtocol> footer) {
                myResponds_.clear();
                
                auto manager = RespondsManager::getInstance();
                headerResponds_ = manager.respondsForObject(header);
                footerResponds_ = manager.respondsForObject(footer);
                selfResponds_ = manager.respondsForObject(self);
                
                if (headerResponds_) {
                    myResponds_.mergeHeaderResponds(*headerResponds_);
                }
                if (footerResponds_) {
                    myResponds_.mergeFooterResponds(*footerResponds_);
                }
                if (selfResponds_) {
                    myResponds_.mergeCellResponds(*selfResponds_);
                }
            }
            
            const TableViewResponds* myResponds() { return &myResponds_; }
            const TableViewResponds* headerResponds() { return headerResponds_; }
            const TableViewResponds* footerResponds() { return footerResponds_; }
            
        private:
            TableViewResponds myResponds_;
            const TableViewResponds* selfResponds_;
            const TableViewResponds* headerResponds_;
            const TableViewResponds* footerResponds_;
            
        };
    }
}

#endif /* DDTableViewComponentCache_h */

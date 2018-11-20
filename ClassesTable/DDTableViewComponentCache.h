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
        struct Range {
            NSUInteger location;
            NSUInteger length;
            
            Range() : location(0), length(0) {}
            Range(NSInteger loc, NSInteger len): location(loc), length(len) {}
            
            bool contains(NSInteger loc) {
                return location <= loc && (location + length) > loc;
            }
        };
        
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
                
                Range& range() { return cache_->indexPaths_[index_]; }
                DDTableViewBaseComponent* component() { return cache_->components_[index_]; }
                const TableViewResponds* responds() { return cache_->responds_[index_]; }
                
                friend bool operator== (const Iterator& l, const Iterator& r) { return l.index_ == r.index_; }
            private:
                SectionCache* cache_;
                size_t index_ = NSNotFound;
            };
            
            void fill(NSArray<DDTableViewBaseComponent*> *components, std::function<NSUInteger(DDTableViewBaseComponent*)> numberOfComponent) {
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
                    Range r = Range(location, numberOfComponent(comp));
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
            Iterator getLocation(NSInteger location) {
                // Use binary search!
                auto i = std::lower_bound(indexPaths_.begin(), indexPaths_.end(), location, [](auto& r, auto sec) {
                    return r.location <= sec;
                });
                if (i == indexPaths_.end()) {
                    auto last = indexPaths_.rbegin();
                    if (last->contains(location)) {
                        return Iterator(this, indexPaths_.size() - 1);
                    }
                }
                else if (i != indexPaths_.begin()) {
                    --i;
                    if (i->contains(location)) {
                        return Iterator(this, i - indexPaths_.begin());
                    }
                }
                NSCAssert(false, @"Can not find info in section %zd!", location);
                return end();
            }
            Iterator getComponent(id<DDTableViewComponentProtocol> comp) {
                auto idx = [components_ indexOfObject:comp];
                return Iterator(this, idx);
            }
            
            const TableViewResponds* myResponds() { return &myResponds_; }
            
            NSInteger numberOfComponents() {
                if (indexPaths_.size()) {
                    auto last = indexPaths_.rbegin();
                    return last->location + last->length;
                }
                return 0;
            }
            
        private:
            TableViewResponds myResponds_;
            std::vector<Range> indexPaths_;
            std::vector<const TableViewResponds*> responds_;
            __strong NSArray<DDTableViewBaseComponent*> *components_ = nil;
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

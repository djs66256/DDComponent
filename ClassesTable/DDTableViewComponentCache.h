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
#import <UIKit/UIKit.h>
#import "DDTableViewResponds.h"
#import "DDTableViewComponentProtocol.h"
#import "DDTableViewCompositeComponentProtocol.h"

namespace DD {
    namespace TableViewComponent {
        class Manager {
        public:
            static Manager& getInstance() {
                static Manager *g_manager = nil;
                std::once_flag flag;
                std::call_once(flag, [](){
                    g_manager = new Manager;
                });
                return *g_manager;
            }
            
            const TableViewResponds* respondsForObject(id<NSObject> obj) {
                NSCAssert(![obj conformsToProtocol:@protocol(DDTableViewCompositeComponentProtocol)],
                          @"Composite object can not get responds from cache!");
                
                if (obj == nil) return nullptr;
                
                std::uintptr_t ptr = reinterpret_cast<std::uintptr_t>(obj.class);
                
                if (std::get<0>(lastCache_) == ptr) return std::get<1>(lastCache_);
                
                auto responds = cache_.find(ptr);
                if (responds != cache_.end()) {
                    lastCache_ = std::make_pair(ptr, &responds->second);
                    return &responds->second;
                }
                else {
                    cache_[ptr] = TableViewResponds(obj);
                    return &cache_[ptr];
                }
            }
            
        private:
            Manager() {}
            std::unordered_map<std::uintptr_t, TableViewResponds> cache_;
            // At some time, we get a list of component that is the same type.
            std::pair<std::uintptr_t, TableViewResponds*> lastCache_ = std::make_pair(-1, nullptr);
        };
        
        class SectionCache {
        public:
            void fill(NSArray<id<DDTableViewComponentProtocol>> *components, UITableView *tableView) {
                indexPaths_.clear();
                responds_.clear();
                indexPaths_.reserve(components.count);
                responds_.reserve(components.count);
                components_ = components;
                
                NSUInteger location = 0;
                TableViewResponds totalResponds;
                const TableViewResponds *rs, *prev = nullptr;
                auto manager = Manager::getInstance();
                for (id<DDTableViewComponentProtocol> comp in components) {
                    NSRange r = { location, static_cast<NSUInteger>([comp numberOfSectionsInTableView:tableView]) };
                    indexPaths_.push_back(r);
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
            
            std::pair<const TableViewResponds*, id<DDTableViewComponentProtocol>> respondsInSection(NSInteger section) {
                for (NSInteger i = 0; i < indexPaths_.size(); ++i) {
                    auto& r = indexPaths_[i];
                    if (r.location <= section && r.location + r.length > section) {
                        return std::make_pair(responds_[i], components_[i]);
                    }
                }
                NSCAssert(false, @"Can not find info in section %zd!", section);
                return std::make_pair(nullptr, nil);
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
            __strong NSArray<id<DDTableViewComponentProtocol>> *components_ = nil;
        };
        
        class RowCache {
        public:
            void fill(NSArray<id<DDTableViewComponentProtocol>> *components, UITableView *tableView) {
                responds_.clear();
                responds_.reserve(components.count);
                components_ = components;
                
                auto manager = Manager::getInstance();
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
            
            std::pair<const TableViewResponds*, id<DDTableViewComponentProtocol>> respondsAtRow(NSInteger row) {
                if (row < responds_.size()) {
                    return std::make_pair(responds_[row], components_[row]);
                }
                NSCAssert(false, @"Can not find info at row %zd!", row);
                return std::make_pair(nullptr, nil);
            }
            
        private:
            TableViewResponds myResponds_;
            std::vector<const TableViewResponds*> responds_;
            __strong NSArray<id<DDTableViewComponentProtocol>> *components_ = nil;
        };
        
        class HeaderFooterCache {
        public:
            void fill(id<DDTableViewComponentProtocol> self, id<DDTableViewComponentProtocol> header, id<DDTableViewComponentProtocol> footer) {
                myResponds_.clear();
                
                auto manager = Manager::getInstance();
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
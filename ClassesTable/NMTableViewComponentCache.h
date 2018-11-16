//
//  NMTableViewComponentCache.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#ifndef NMTableViewComponentCache_h
#define NMTableViewComponentCache_h

#include <vector>
#include <unordered_map>
#include <mutex>
#include <cstdint>
#include <tuple>
#import <UIKit/UIKit.h>
#import "NMTableViewResponds.h"
#import "NMTableViewComponentProtocol.h"
#import "NMTableViewCompositeComponentProtocol.h"

namespace NM {
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
            
            TableViewResponds& respondsForObject(id<NSObject> obj) {
                std::uintptr_t ptr = reinterpret_cast<std::uintptr_t>(obj.class);
                auto responds = cache_.find(ptr);
                if (responds != cache_.end()) {
                    return responds->second;
                }
                else {
                    cache_[ptr] = TableViewResponds(obj);
                    return respondsForObject(obj);
                }
            }
            
        private:
            Manager() {}
            std::unordered_map<std::uintptr_t, TableViewResponds> cache_;
        };
        
        class SectionCache {
        public:
            void fill(NSArray<id<NMTableViewComponentProtocol>> *components, UITableView *tableView) {
                indexPaths_.clear();
                responds_.clear();
                indexPaths_.reserve(components.count);
                responds_.reserve(components.count);
                components_ = components;
                
                NSUInteger location = 0;
                TableViewResponds totalResponds;
                TableViewResponds rs;
                for (id<NMTableViewComponentProtocol> comp in components) {
                    NSRange r = { location, static_cast<NSUInteger>([comp numberOfSectionsInTableView:tableView]) };
                    indexPaths_.push_back(r);
                    if ([comp conformsToProtocol:@protocol(NMTableViewCompositeComponentProtocol)]) {
                        id<NMTableViewCompositeComponentProtocol> compositeComp = (id<NMTableViewCompositeComponentProtocol>)comp;
                        rs = compositeComp.respondsInfo;
                    }
                    else {
                        rs = Manager::getInstance().respondsForObject(comp);
                    }
                    responds_.push_back(rs);
                    totalResponds &= rs;
                }
                myResponds_ = totalResponds;
            }
            
            std::pair<const TableViewResponds*, id<NMTableViewComponentProtocol>> respondsAtIndexPath(NSIndexPath *indexPath) {
                return respondsInSection(indexPath.section);
            }
            
            std::pair<const TableViewResponds*, id<NMTableViewComponentProtocol>> respondsInSection(NSInteger section) {
                for (NSInteger i = 0; i < indexPaths_.size(); ++i) {
                    auto& r = indexPaths_[i];
                    if (r.location <= section && r.location + r.length > section) {
                        return std::make_pair(&responds_[i], components_[i]);
                    }
                }
                NSCAssert(false, @"Can not find info in section %zd!", section);
                return std::make_pair(nullptr, nil);
            }
            
            const TableViewResponds& myResponds() { return myResponds_; }
            
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
            std::vector<TableViewResponds> responds_;
            __strong NSArray<id<NMTableViewComponentProtocol>> *components_ = nil;
        };
        
        class RowCache {
        private:
            TableViewResponds myResponds_;
            std::vector<TableViewResponds> responds_;
            __strong NSArray<id<NMTableViewComponentProtocol>> *components_ = nil;
        };
    }
}

#endif /* NMTableViewComponentCache_h */

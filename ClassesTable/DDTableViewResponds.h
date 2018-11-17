//
//  DDTableViewResponds.h
//  DDTableViewComponent
//
//  Created by daniel on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#ifndef DDTableViewResponds_h
#define DDTableViewResponds_h

#include <cstdint>
#import <UIKit/UIKit.h>

#define TableViewHeaderDelegateNameList(P) \
P(titleForHeaderInSection,              tableView:titleForHeaderInSection:)                 \
P(willDisplayHeaderView,                tableView:willDisplayHeaderView:forSection:)        \
P(didEndDisplayingHeaderView,           tableView:didEndDisplayingHeaderView:forSection:)   \
P(heightForHeaderInSection,             tableView:heightForHeaderInSection:)                \
P(estimatedHeightForHeaderInSection,    tableView:estimatedHeightForHeaderInSection:)       \
P(viewForHeaderInSection,               tableView:viewForHeaderInSection:)                  \

#define TableViewFooterDelegateNameList(P) \
P(titleForFooterInSection,              tableView:titleForFooterInSection:)                 \
P(willDisplayFooterView,                tableView:willDisplayFooterView:forSection:)        \
P(didEndDisplayingFooterView,           tableView:didEndDisplayingFooterView:forSection:)   \
P(heightForFooterInSection,             tableView:heightForFooterInSection:)                \
P(estimatedHeightForFooterInSection,    tableView:estimatedHeightForFooterInSection:)       \
P(viewForFooterInSection,               tableView:viewForFooterInSection:)                  \

#define TableViewCellDelegateNameList(P) \
P(canEditRowAtIndexPath,            tableView:canEditRowAtIndexPath:)                   \
P(commitEditingStyle,               tableView:commitEditingStyle:forRowAtIndexPath:)    \
P(willDisplayCell,                  tableView:willDisplayCell:forRowAtIndexPath:)       \
P(didEndDisplayingCell,             tableView:didEndDisplayingCell:forRowAtIndexPath:)  \
P(heightForRowAtIndexPath,          tableView:heightForRowAtIndexPath:)             \
P(estimatedHeightForRowAtIndexPath, tableView:estimatedHeightForRowAtIndexPath:)    \
P(shouldHighlightRowAtIndexPath,    tableView:shouldHighlightRowAtIndexPath:)       \
P(didHighlightRowAtIndexPath,       tableView:didHighlightRowAtIndexPath:)          \
P(didUnhighlightRowAtIndexPath,     tableView:didUnhighlightRowAtIndexPath:)        \
P(willSelectRowAtIndexPath,         tableView:willSelectRowAtIndexPath:)            \
P(willDeselectRowAtIndexPath,       tableView:willDeselectRowAtIndexPath:)          \
P(didSelectRowAtIndexPath,          tableView:didSelectRowAtIndexPath:)             \
P(didDeselectRowAtIndexPath,        tableView:didDeselectRowAtIndexPath:)           \
P(editingStyleForRowAtIndexPath,    tableView:editingStyleForRowAtIndexPath:)       \
P(editActionsForRowAtIndexPath,     tableView:editActionsForRowAtIndexPath:)        \
P(titleForDeleteConfirmationButtonForRowAtIndexPath,    tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)  \
P(leadingSwipeActionsConfigurationForRowAtIndexPath,    tableView:leadingSwipeActionsConfigurationForRowAtIndexPath:)  \
P(trailingSwipeActionsConfigurationForRowAtIndexPath,   tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:) \
P(shouldIndentWhileEditingRowAtIndexPath,   tableView:shouldIndentWhileEditingRowAtIndexPath:)  \
P(willBeginEditingRowAtIndexPath,           tableView:willBeginEditingRowAtIndexPath:)          \
P(didEndEditingRowAtIndexPath,              tableView:didEndEditingRowAtIndexPath:)             \
P(indentationLevelForRowAtIndexPath,        tableView:indentationLevelForRowAtIndexPath:)       \
P(shouldShowMenuForRowAtIndexPath,          tableView:shouldShowMenuForRowAtIndexPath:)         \
P(canPerformAction,     tableView:canPerformAction:forRowAtIndexPath:withSender:)               \
P(performAction,        tableView:performAction:forRowAtIndexPath:withSender:)                  \
\
P(canFocusRowAtIndexPath,           tableView:canFocusRowAtIndexPath:) \
P(shouldSpringLoadRowAtIndexPath,   tableView:shouldSpringLoadRowAtIndexPath:withContext:)


#define TableViewDelegateNameList(P) \
TableViewHeaderDelegateNameList(P) \
TableViewFooterDelegateNameList(P) \
TableViewCellDelegateNameList(P)

namespace DD {
    namespace TableViewComponent {
        struct TableViewResponds {
            Class cls = nil;
            
#define P(name, _) Boolean name = false;
            TableViewDelegateNameList(P)
#undef P
            
            TableViewResponds(NSObject *comp) :
#define P(name, sel_name) name([comp respondsToSelector:@selector(sel_name)]),
            TableViewDelegateNameList(P)
#undef P
            cls(comp.class)
            {}
            
            TableViewResponds() {}
            
            void clear() {
#define P(name, _) name = false;
                TableViewDelegateNameList(P)
#undef P
                cls = Nil;
            }
            
            TableViewResponds& mergeHeaderResponds(const TableViewResponds& other) {
#define P(name, _) this->name |= other.name;
                TableViewHeaderDelegateNameList(P)
#undef P
                return *this;
            }
            
            TableViewResponds& mergeFooterResponds(const TableViewResponds& other) {
#define P(name, _) this->name |= other.name;
                TableViewFooterDelegateNameList(P)
#undef P
                return *this;
            }
            
            TableViewResponds& mergeCellResponds(const TableViewResponds& other) {
#define P(name, _) this->name |= other.name;
                TableViewCellDelegateNameList(P)
#undef P
                return *this;
            }
            
            TableViewResponds& operator |= (const TableViewResponds& other) {
#define P(name, _) this->name |= other.name;
                TableViewDelegateNameList(P)
#undef P
                return *this;
            }
        };
    }
}


#define ScrollViewDelegateNameList(P) \
P(scrollViewDidScroll,                  scrollViewDidScroll:)               \
P(scrollViewWillBeginDragging,          scrollViewWillBeginDragging:)       \
P(scrollViewWillEndDragging,            scrollViewWillEndDragging:withVelocity:targetContentOffset:) \
P(scrollViewDidEndDragging,             scrollViewDidEndDragging:willDecelerate:)   \
P(scrollViewWillBeginDecelerating,      scrollViewWillBeginDecelerating:)   \
P(scrollViewDidEndDecelerating,         scrollViewDidEndDecelerating:)      \
P(scrollViewDidEndScrollingAnimation,   scrollViewDidEndScrollingAnimation:)\
P(scrollViewShouldScrollToTop,          scrollViewShouldScrollToTop:)       \
P(scrollViewDidScrollToTop,             scrollViewDidScrollToTop:)          \
P(scrollViewDidChangeAdjustedContentInset, scrollViewDidChangeAdjustedContentInset:)

namespace DD {
    namespace TableViewComponent {
        struct ScrollResponds {
            Class cls = nil;
            
#define P(name, _) Boolean name = false;
            ScrollViewDelegateNameList(P)
#undef P
            
            ScrollResponds(NSObject *comp) :
#define P(name, sel_name) name([comp respondsToSelector:@selector(sel_name)]),
            ScrollViewDelegateNameList(P)
#undef P
            cls(comp.class)
            {}
            
            ScrollResponds() {}
            
            void clear() {
#define P(name, _) name = false;
                ScrollViewDelegateNameList(P)
#undef P
                cls = Nil;
            }
            
            void fill(NSObject* comp) {
                if (cls == comp.class) return;
                
#define P(name, sel_name) name = [comp respondsToSelector:@selector(sel_name)];
                ScrollViewDelegateNameList(P)
#undef P
                cls = comp.class;
            }
        };
    }
}

#endif /* DDTableViewResponds_h */

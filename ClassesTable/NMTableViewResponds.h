//
//  NMTableViewResponds.h
//  NMTableViewComponent
//
//  Created by hzduanjiashun on 2018/11/16.
//  Copyright © 2018 daniel. All rights reserved.
//

#ifndef NMTableViewResponds_h
#define NMTableViewResponds_h

#include <cstdint>
#import <UIKit/UIKit.h>

#define TableViewDelegateNameList(P) \
P(titleForHeaderInSection, tableView:titleForHeaderInSection:)  \
P(titleForFooterInSection, tableView:titleForFooterInSection:)  \
P(canEditRowAtIndexPath, tableView:canEditRowAtIndexPath:)      \
P(commitEditingStyle, tableView:commitEditingStyle:forRowAtIndexPath:) \
\
P(willDisplayCell, tableView:willDisplayCell:forRowAtIndexPath:)        \
P(willDisplayHeaderView, tableView:willDisplayHeaderView:forSection:)   \
P(willDisplayFooterView, tableView:willDisplayFooterView:forSection:)   \
P(didEndDisplayingCell, tableView:didEndDisplayingCell:forRowAtIndexPath:)      \
P(didEndDisplayingHeaderView, tableView:didEndDisplayingHeaderView:forSection:) \
P(didEndDisplayingFooterView, tableView:didEndDisplayingFooterView:forSection:) \
\
P(heightForRowAtIndexPath, tableView:heightForRowAtIndexPath:)      \
P(heightForHeaderInSection, tableView:heightForHeaderInSection:)    \
P(heightForFooterInSection, tableView:heightForFooterInSection:)    \
P(estimatedHeightForRowAtIndexPath, tableView:estimatedHeightForRowAtIndexPath:)    \
P(estimatedHeightForHeaderInSection, tableView:estimatedHeightForHeaderInSection:)  \
P(estimatedHeightForFooterInSection, tableView:estimatedHeightForFooterInSection:)  \
\
P(viewForHeaderInSection, tableView:viewForHeaderInSection:)                \
P(viewForFooterInSection, tableView:viewForFooterInSection:)                \
P(shouldHighlightRowAtIndexPath, tableView:shouldHighlightRowAtIndexPath:)  \
P(didHighlightRowAtIndexPath, tableView:didHighlightRowAtIndexPath:)        \
P(didUnhighlightRowAtIndexPath, tableView:didUnhighlightRowAtIndexPath:)    \
P(willSelectRowAtIndexPath, tableView:willSelectRowAtIndexPath:)            \
P(willDeselectRowAtIndexPath, tableView:willDeselectRowAtIndexPath:)        \
\
P(didSelectRowAtIndexPath, tableView:didSelectRowAtIndexPath:)              \
P(didDeselectRowAtIndexPath, tableView:didDeselectRowAtIndexPath:)          \
P(editingStyleForRowAtIndexPath, tableView:editingStyleForRowAtIndexPath:)  \
P(titleForDeleteConfirmationButtonForRowAtIndexPath, tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)  \
P(editActionsForRowAtIndexPath, tableView:editActionsForRowAtIndexPath:)    \
P(leadingSwipeActionsConfigurationForRowAtIndexPath, tableView:leadingSwipeActionsConfigurationForRowAtIndexPath:)  \
P(trailingSwipeActionsConfigurationForRowAtIndexPath, tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:) \
P(shouldIndentWhileEditingRowAtIndexPath, tableView:shouldIndentWhileEditingRowAtIndexPath:) \
P(willBeginEditingRowAtIndexPath, tableView:willBeginEditingRowAtIndexPath:)        \
P(didEndEditingRowAtIndexPath, tableView:didEndEditingRowAtIndexPath:)              \
P(indentationLevelForRowAtIndexPath, tableView:indentationLevelForRowAtIndexPath:)  \
P(shouldShowMenuForRowAtIndexPath, tableView:shouldShowMenuForRowAtIndexPath:)      \
P(canPerformAction, tableView:canPerformAction:forRowAtIndexPath:withSender:)       \
P(performAction, tableView:performAction:forRowAtIndexPath:withSender:)             \
\
P(canFocusRowAtIndexPath, tableView:canFocusRowAtIndexPath:) \
P(shouldSpringLoadRowAtIndexPath, tableView:shouldSpringLoadRowAtIndexPath:withContext:)


namespace NM {
    namespace TableViewComponent {
        struct TableViewResponds {
            NSObject *object;
            
#define P(name, _) Boolean name = false;
            TableViewDelegateNameList(P)
#undef P
            
            TableViewResponds(NSObject *comp) :
#define P(name, sel_name) name([comp respondsToSelector:@selector(sel_name)]),
            TableViewDelegateNameList(P)
#undef P
            object(comp)
            {}
            
            TableViewResponds() :
#define P(name, _) name(false),
            TableViewDelegateNameList(P)
#undef P
            object(nil)
            {}
            
            TableViewResponds& operator &= (TableViewResponds& other) {
#define P(name, _) this->name &= other.name;
                TableViewDelegateNameList(P)
#undef P
                return *this;
            }
        };
    }
}

#endif /* NMTableViewResponds_h */

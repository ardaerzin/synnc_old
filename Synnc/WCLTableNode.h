//
//  WCLTableNode.h
//  Synnc
//
//  Created by Arda Erzin on 1/9/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

#ifndef WCLTableNode_h
#define WCLTableNode_h


#endif /* WCLTableNode_h */

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

/**
 * ASTableNode is a node based class that wraps an ASTableView. It can be used
 * as a subnode of another node, and provide room for many (great) features and improvements later on.
 */

@interface WCLTableView : ASTableView
@property BOOL programaticScrollEnabled;
@end

@interface WCLTableNode : ASDisplayNode

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) WCLTableView *view;

@end
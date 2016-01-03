//
//  WCLScrollNode.h
//  Synnc
//
//  Created by Arda Erzin on 1/1/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

#ifndef WCLScrollNode_h
#define WCLScrollNode_h


#endif /* WCLScrollNode_h */

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/ASDisplayNode.h>

/**
 * Simple node that wraps UIScrollView.
 */

@interface WCLScrollView : UIScrollView
@property BOOL programaticScrollEnabled;
@end

@interface WCLScrollNode : ASDisplayNode

/**
 * @abstract The node's UIScrollView.
 */
@property (nonatomic, readonly, strong) WCLScrollView *view;

@end
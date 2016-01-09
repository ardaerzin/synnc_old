//
//  WCLTableNode.m
//  Synnc
//
//  Created by Arda Erzin on 1/9/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCLTableNode.h"
#import "_ASDisplayLayer.h"

@implementation WCLTableView

CGPoint p_offset;
- (void) setContentOffset:(CGPoint)contentOffset
{
    if(self.programaticScrollEnabled) {
        p_offset = contentOffset;
        [super setContentOffset:contentOffset];
    } else {
        [super setContentOffset:p_offset];
    }
}
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style asyncDataFetching:NO]) {
        self.programaticScrollEnabled = YES;
        return self;
    }
    return nil;
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.programaticScrollEnabled = YES;
//    }
//    return self;
//}
@end

@implementation WCLTableNode
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithViewBlock:^UIView *{
        return [[WCLTableView alloc] initWithFrame:CGRectZero style:style];
    }]) {
        return self;
    }
    return nil;
}
- (WCLTableView *)view
{
    return (WCLTableView *)[super view];
}
@end
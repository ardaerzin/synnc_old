//
//  WCLScrollNode.m
//  Synnc
//
//  Created by Arda Erzin on 1/1/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCLScrollNode.h"
#import "_ASDisplayLayer.h"


@implementation WCLScrollView

CGPoint oldOffset;

+ (Class)layerClass
{
    return [_ASDisplayLayer class];
}

- (void) setContentOffset:(CGPoint)contentOffset
{
    if(self.programaticScrollEnabled) {
        oldOffset = contentOffset;
        [super setContentOffset:contentOffset];
    } else {
        [super setContentOffset:oldOffset];
//        NSLog(@"sector %@", oldOffset);
    }
}
//- (void) setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
//{
//    if(self.programaticScrollEnabled) {
//        [super setContentOffset:contentOffset animated:animated];
//    } else {
//        NSLog(@"sector");
//    }
//}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.programaticScrollEnabled = YES;
    }
    return self;
}
//setContentOffset
//{
//    
//}

@end

@implementation WCLScrollNode
@dynamic view;

- (instancetype)init
{
    return [super initWithViewBlock:^UIView *{
        return [[WCLScrollView alloc] init];
    } didLoadBlock:nil];
}

@end
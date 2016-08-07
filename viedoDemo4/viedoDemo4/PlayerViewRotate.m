//
//  PlayerViewRotate.m
//  videoDemo2
//
//  Created by 林之杰 on 16/1/14.
//  Copyright © 2016年 林之杰. All rights reserved.
//

#import "PlayerViewRotate.h"

@implementation PlayerViewRotate

+ (void)forceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


+ (BOOL)isOrientationLandscape {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    }else {
        return NO;
    }
}
@end

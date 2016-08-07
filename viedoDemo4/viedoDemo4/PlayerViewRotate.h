//
//  PlayerViewRotate.h
//  videoDemo2
//
//  Created by 林之杰 on 16/1/14.
//  Copyright © 2016年 林之杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface PlayerViewRotate : NSObject

+ (void)forceOrientation: (UIInterfaceOrientation)orientation;

+ (BOOL)isOrientationLandscape;

@end

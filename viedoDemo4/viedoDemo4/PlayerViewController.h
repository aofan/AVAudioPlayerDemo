//
//  PlayerViewController.h
//  viedoDemo4
//
//  Created by 林之杰 on 16/1/19.
//  Copyright © 2016年 林之杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "PlayerViewControl.h"
@class PlayerViewControl;

@interface PlayerViewController : UIView
@property (atomic, strong) NSURL *url;
@property (atomic, retain) id <IJKMediaPlayback> player;
@property (strong, nonatomic) PlayerViewControl *playerControl;
@property (strong, nonatomic) UIView *playerView;

- (instancetype)initWithURL:(NSURL*)url withFrame:(CGRect)frame;


@end

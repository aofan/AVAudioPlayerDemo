//
//  ViewController.h
//  VideoDemo
//
//  Created by 林之杰 on 16/1/13.
//  Copyright © 2016年 林之杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface ViewController : UIViewController 
@property (atomic, strong) NSURL *url;
@property (atomic, retain) id <IJKMediaPlayback> player;
@property (weak, nonatomic) IBOutlet UIView *PlayerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

//- (id)initWithURL:(NSURL *)url;

- (IBAction)onCIickPlay:(id)sender;
//- (IBAction)didSliderValueChange;


@end


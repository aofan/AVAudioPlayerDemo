//
//  PlayerViewController.m
//  viedoDemo4
//
//  Created by 林之杰 on 16/1/19.
//  Copyright © 2016年 林之杰. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerView+Notification.h"
#import "PlayerViewRotate.h"
@interface PlayerViewController (){
    BOOL isHidden;
    UIInterfaceOrientation _lastOrientaion;
    NSTimer *timer;
}

@end

@implementation PlayerViewController
UISlider* volumeViewSlider;
float systemVolume;
CGPoint startPoint;
CGRect smallFrame;

- (void)dealloc {
    [self.player stop];
    [_player shutdown];
    [self removeNotification];
}


- (id)initWithURL:(NSURL *)url withFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.url = url;
        self.frame = frame;
        NSLog(@"%@",url);
        [self setupPlayer];
        isHidden = false;
        [self addSubview:self.playerView];
        
        NSLog(@"View Did Init");
        if (![_player isPlaying]) {
            [self.player prepareToPlay];
        }
    }
    return self;
}


- (void)setupPlayer {
    /*!
     *  @author 林之杰, 16-01-22 15:01:52
     *
     *  @brief setUp playerView
     *
     *  @since 1.0
     */
    self.backgroundColor = [UIColor grayColor];
    
    if (!_playerView) {
        self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    
    smallFrame = self.playerView.frame;
    IJKFFOptions *options;
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT
                             forKey:@"skip_loop_filter"];
    [options setCodecOptionIntValue:IJK_AVDISCARD_DEFAULT
                             forKey:@"skip_frame"];
    [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    [options setPlayerOptionIntValue:8 forKey:@"framedrop"];
    if (!_player) {
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    }
    
    _player.view.frame = CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height);
    
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    
    [self setupNotification];
    /*!
     playerControl method
     
     
     */

    if (!_playerControl) {
        self.playerControl = [[PlayerViewControl alloc] initWithFrame:self.frame];
    }
    self.playerControl.delegatePlayer = _player;
    [_player.view addSubview:self.playerControl];
    [self.playerView addSubview:_player.view];
    
    
    
    [self.playerControl.fullScreenBut addTarget:self action:@selector(fullScreenButDidTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.playerControl.danmakuBut addTarget:self action:@selector(danmakuButDidTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.playerControl.switchBut addTarget:self action:@selector(switchButDidTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerControl showAndFade];
    
    /*!
     Volume method
     
    
     */
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    systemVolume = volumeViewSlider.value;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"!!!!!!!");
    if (event.allTouches.count == 1) {
        [self.playerControl showAndFade];

        startPoint = [[touches anyObject] locationInView:self];;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.allTouches.count == 1) {
        CGPoint point = [[touches anyObject] locationInView:self];
        float dx = point.x - startPoint.x;
        float dy = point.y - startPoint.y;
        NSLog(@"Point(x,y) =%.2f:%.2f",point.x,point.y);
        int indexY = (int)dy;
        if (startPoint.x > self.bounds.size.width/2) {
            if (indexY > 0) {
                if (indexY % 5 == 0) {
                    NSLog(@"%.2f",systemVolume);
                    if (systemVolume > 0.1) {
                        systemVolume = systemVolume - 0.05;
                        [volumeViewSlider setValue:systemVolume animated:YES];
                        [volumeViewSlider sendActionsForControlEvents:  UIControlEventTouchUpInside];
                    }
                }
            }else {
                if (indexY%5 == 0) {
                    NSLog(@"+x == %d",indexY);
                    NSLog(@"%.2f",systemVolume);
                    if (systemVolume >= 0 && systemVolume < 1) {
                        systemVolume +=0.05;
                        [volumeViewSlider setValue:systemVolume animated:YES];
                        [volumeViewSlider sendActionsForControlEvents:  UIControlEventTouchUpInside];
                    }
                }
            }
            
        }else {
            NSLog(@"%.2f",dx);
            [UIScreen mainScreen].brightness = (float) dy/self.bounds.size.height;
            NSLog(@"%.2f",[UIScreen mainScreen].brightness);
        }
    }
}
#pragma -ActionSelector

-(void) switchButDidTouch{
    
    
    [self.player stop];
    [_player shutdown];
    _player = nil;
    self.player = nil;
    _playerControl = nil;
    self.playerControl = nil;
    _playerView = nil;
    self.playerView = nil;
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timeEnd) userInfo:nil repeats:YES];
    
    [self removeNotification];
   
//    self.url = [NSURL URLWithString:@"http://61.143.225.69:8080/live/12345_3.m3u8"];
    NSLog(@"%@",_url);
    [self setupPlayer];
    [_playerControl.switchBut setTitle:@"高清" forState:UIControlStateNormal];
    isHidden = false;
    [self addSubview:self.playerView];
        
    NSLog(@"View Did Init");

}

- (void)timeEnd {
    [timer invalidate];
    [self.player prepareToPlay];
}


- (void) danmakuButDidTouch {
    
}
- (void) fullScreenButDidTouch {
    if ([PlayerViewRotate isOrientationLandscape]) {
        [PlayerViewRotate forceOrientation:UIInterfaceOrientationPortrait];
         _lastOrientaion = [UIApplication sharedApplication].statusBarOrientation;
         [self prepareForSmallScreen];
    }else {
        
        [PlayerViewRotate forceOrientation:UIInterfaceOrientationLandscapeRight];
       
        [self prepareForFullScreen];
    }
}


- (void)prepareForFullScreen {

    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    [_playerControl.fullScreenBut setTitle:@"缩" forState:UIControlStateNormal];
    self.frame = [[UIScreen mainScreen] bounds];
    _playerView.frame = self.frame;
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth & UIViewAutoresizingFlexibleHeight;
}

- (void)prepareForSmallScreen {
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    self.frame = CGRectMake(0, 64, smallFrame.size.width, smallFrame.size.height);
    _playerView.frame = CGRectMake(0, 0, smallFrame.size.width, smallFrame.size.height);
    [_playerControl.fullScreenBut setTitle:@"全" forState:UIControlStateNormal];
}

@end

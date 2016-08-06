//
//  MVAudioDetails.m
//  GMAudioVideoCacheProgress
//
//  Created by geimin on 14/11/3.
//  Copyright (c) 2014年 Geimin. All rights reserved.
//

#import "MVAudioDetails.h"
#import "AVVideoViewController.h"

@interface MVAudioDetails ()
@property (strong , nonatomic) AVVideoViewController *playbackViewController;
@property (nonatomic) BOOL    tapType;      //是否显示标题栏

@end

@implementation MVAudioDetails
@synthesize tapType = _tapType;
@synthesize detailsDict = _detailsDict;
@synthesize playbackViewController = _playbackViewController;
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _detailsDict = nil;
    _playbackViewController.delegate = nil;
    _playbackViewController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tapType = YES;
    
    //播放器
    [self playAction];
    
    //隐藏状态栏
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        //刷新页面
        [self playerFrameAction];
    }
    
    //通知退出播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAudioPlayAction:) name:@"endAudioPlayAction" object:nil];
    //通知状态栏显示、隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenAudioStatusAction:) name:@"hiddenAudioStatusAction" object:nil];
    
    //更换状态栏颜色
    [self setNeedsStatusBarAppearanceUpdate];
}
//更换状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    //UIStatusBarStyleDefault
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    //延时刷新页面
    [self performSelector:@selector(playerFrameAction) withObject:nil afterDelay:0.1f];
    return !_tapType;
}
//通知状态栏显示、隐藏
-(void)hiddenAudioStatusAction:(id)sender{
   NSString *hidden = (NSString *)[[sender userInfo] objectForKey:@"hidden"];
    //显示
    if([hidden isEqualToString:@"1"]){
        _tapType = YES;
        //隐藏状态栏
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            // iOS 7
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            //刷新页面
            [self playerFrameAction];
        }
    //隐藏
    }else if([hidden isEqualToString:@"0"]){
        _tapType = NO;
        //隐藏状态栏
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            // iOS 7
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            //刷新页面
            [self playerFrameAction];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//通知退出播放
-(void)endAudioPlayAction:(id)sender{
    //关闭播放器
    [_playbackViewController pauses:nil];
    _playbackViewController.URL = nil;
    _playbackViewController = nil;
    
    [self returnAction:nil];
}

//播放器
-(void)playAction{
    
    NSString *strBundelPath = [_detailsDict objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:strBundelPath];
    if (!_playbackViewController){
        _playbackViewController = [[AVVideoViewController alloc] initWithNibName:@"AVVideoViewController" bundle:nil];
        [self.view addSubview:_playbackViewController.view];
    }
    _playbackViewController.mtitle = [_detailsDict objectForKey:@"title"];
    _playbackViewController.isColection = YES;
    _playbackViewController.detailsDict = _detailsDict;
    //frame
    [self playerFrameAction];
    [_playbackViewController setURL:url];
}

//播放器改变Frame
-(void)playerFrameAction{
    _playbackViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_playbackViewController changetollBarView:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    [_playbackViewController playFrameAction];
}

//返回
- (void)returnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end

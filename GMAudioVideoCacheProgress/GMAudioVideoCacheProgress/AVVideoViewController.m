/*
     File: AVVideoViewController.m
 Abstract: UIViewController managing a playback view, thumbnail view, and associated playback UI.
  Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */
#import "AVVideoViewController.h"
#import "AVPlayerDemoPlaybackView.h"
#import "AVPlayerDemoMetadataViewController.h"
#import <MediaPlayer/MediaPlayerDefines.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AVVideoViewController (){
    BOOL isShowToolBar;
    CGPoint firstPoint;
    CGPoint lastPoint;
    UIImageView* topImge;
}

- (void)plays:(id)sender;
- (void)pauses:(id)sender;
- (void)showMetadata:(id)sender;
- (void)initScrubberTimer;
- (void)showPlayButton;
- (void)showStopButton;
- (void)syncScrubber;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
- (BOOL)isScrubbing;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id)init;
- (void)dealloc;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;
- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;
- (void)syncPlayPauseButtons;
- (void)setURL:(NSURL*)URL;
- (NSURL*)URL;


@property (strong, nonatomic) MPVolumeView* ChangevolumeViews;
@property (weak, nonatomic) IBOutlet UIView   *m_toobarBackView;
@property (weak, nonatomic) IBOutlet UIView   *m_titleToolView;
@property (weak, nonatomic) IBOutlet UIButton *pasueBtn;
@property (weak, nonatomic) IBOutlet UIButton *PlayBtn;
@property (weak, nonatomic) IBOutlet UILabel  *starTimeLab;
@property (weak, nonatomic) IBOutlet UILabel  *endTimeLab;

@property (strong, nonatomic) MPVolumeView *volumeView;
@property (strong, nonatomic) UIButton *VomBtn;
@property (strong, nonatomic) UIButton *fullBtn;
@property (strong, nonatomic) UIButton *minBtn;
@property (strong, nonatomic) IBOutlet UIButton *m_addmarkBtn;

@end

@interface AVVideoViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end


static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

#pragma mark -
@implementation AVVideoViewController
@synthesize isColection = _isColection;
@synthesize detailsDict = _detailsDict;
@synthesize mPlayer, mPlayerItem, mPlaybackView, mToolbar, mPlayButton, mStopButton, mScrubber,m_toobarBackView,m_toolbarViews,pasueBtn,PlayBtn,volumeView,VomBtn,fullBtn,minBtn,m_title,mtitle,m_addmarkBtn,m_titleToolView,ChangevolumeViews,delegate,starTimeLab,endTimeLab;


#pragma mark Asset URL
- (void)setURL:(NSURL*)URL
{
	if (mURL != URL)
	{
        self.m_title.text = mtitle;        
        if(self.mPlayer ){
            [self.mPlayer pause];
        }
        
		mURL = [URL copy];
		
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{		 
             dispatch_async( dispatch_get_main_queue(), 
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];
	}
}

- (NSURL*)URL
{
	return mURL;
}

#pragma mark -
#pragma mark Movie controller methods
-(float)getcurentTime
{
    double time = CMTimeGetSeconds([self.mPlayer currentTime]);
    return time;
}

#pragma mark
#pragma mark Button Action Methods
- (void)plays:(UIButton*)sender
{
	/* If we are at the end of the movie, we must seek to the beginning first 
		before starting playback. */
    if(![sender isSelected]){
        if (YES == seekToZeroBeforePlay)
        {
            seekToZeroBeforePlay = NO;
            [self.mPlayer seekToTime:kCMTimeZero];
        }
        
        [self.mPlayer play];
        
        [self showStopButton];
        sender.selected = YES;
    }else{
        [self.mPlayer pause];
        
        [self showPlayButton];
        sender.selected = NO;
    }
	   
}

- (void)pauses:(id)sender
{
	[self.mPlayer pause];

    [self showPlayButton];
}

/* Display AVMetadataCommonKeyTitle and AVMetadataCommonKeyCopyrights metadata. */

- (void)showMetadata:(id)sender
{
//	AVPlayerDemoMetadataViewController* metadataViewController = [[AVPlayerDemoMetadataViewController alloc] init];
//
//	[metadataViewController setMetadata:[[[self.mPlayer currentItem] asset] commonMetadata]];
//	
//	[self presentViewController:metadataViewController animated:YES completion:NULL];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"willEnterFull" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:m_titleToolView,@"info",m_addmarkBtn,@"addmark", nil]];
}

//收藏
- (IBAction)ShareBtn:(UIButton *)sender {
    UIButton *tempBut = (UIButton *)[m_titleToolView viewWithTag:20];
    //已收藏
    if(tempBut.isSelected){
        tempBut.selected = NO;
        BOOL result = [MVPublicMethod addCollectionWith:_detailsDict andMark:@"video"];
        if(result){
            //成功收藏
            [_collectionBut setImage:[UIImage imageNamed:@"shoucang4.png"] forState:UIControlStateNormal];
            [_colectionTitle setTitleColor:[UIColor colorWithRed:255/255.0 green:160/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
        }
        
   //未收藏
    }else{
        tempBut.selected = YES;
        BOOL result = [MVPublicMethod cancelCollectionWith:_detailsDict andMark:@"video"];
        if(result){
            //取消收藏
            [_collectionBut setImage:[UIImage imageNamed:@"shoucang3.png"] forState:UIControlStateNormal];
            [_colectionTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //通知更新 我的收藏
            NSNotification *vCollNF = [[NSNotification alloc] initWithName:@"cancelCollectionAction" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:vCollNF];
        }
        
    }
}

//收藏按钮状态
-(void)collectionButState{
    BOOL result = [MVPublicMethod isCollectionWith:_detailsDict andMark:@"video"];
    if(result){
        //已经收藏
        [_collectionBut setImage:[UIImage imageNamed:@"shoucang4.png"] forState:UIControlStateNormal];
          [_colectionTitle setTitleColor:[UIColor colorWithRed:255/255.0 green:160/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
        [_collectionBut setSelected:NO];
    }else{
        //未收藏
        [_collectionBut setImage:[UIImage imageNamed:@"shoucang3.png"] forState:UIControlStateNormal];
         [_colectionTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_collectionBut setSelected:YES];
    }
}

//退出播放
- (IBAction)ExitFull:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endAudioPlayAction" object:self userInfo:nil];    
}

#pragma mark -
#pragma mark Play, Stop buttons
/* Show the stop button in the movie player controller. */
-(void)showStopButton
{
    [self.PlayBtn setImage:[UIImage imageNamed:@"zanting.png"] forState:UIControlStateNormal];
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton
{
    [self.PlayBtn setImage:[UIImage imageNamed:@"bofang2.png"] forState:UIControlStateNormal];
}

/* If the media is playing, show the stop button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
	if ([self isPlaying])
	{
        [self showStopButton];
	}
	else
	{
        [self showPlayButton];        
	}
}

-(void)enablePlayerButtons
{
    self.mPlayButton.enabled = YES;
    self.mStopButton.enabled = YES;
}

-(void)disablePlayerButtons
{
    self.mPlayButton.enabled = NO;
    self.mStopButton.enabled = NO;
}

#pragma mark -
#pragma mark Movie scrubber control

/* ---------------------------------------------------------
**  Methods to handle manipulation of the movie scrubber control
** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
	double interval = .1f;	
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration)) 
	{
		return;
	} 
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
		interval = 0.5f * duration / width;
	}

	/* Update the scrubber during normal playback. */
	__weak AVVideoViewController *weakSelf = self;
	mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) 
								queue:NULL /* If you pass NULL, the main queue is used. */
								usingBlock:^(CMTime time) 
                                            {
                                                [weakSelf syncScrubber];
                                            }];
}

-(void)showStarLabletimeToEndLableTime:(double)startime end:(double)endttime
{
    if(startime<=0){
        [starTimeLab setText:@"00:00"];
    }else{
    
        int sec = startime/60;
        int mmin = (int)startime%60;
        if(sec<10 && mmin<10){
            [starTimeLab setText:[NSString stringWithFormat:@"0%d:0%d",sec,mmin]];
        }else if(sec<10 && mmin>=10){
            [starTimeLab setText:[NSString stringWithFormat:@"0%d:%d",sec,mmin]];
        }else if (sec>=10 && mmin<10){
            [starTimeLab setText:[NSString stringWithFormat:@"%d:0%d",sec,mmin]];
        }else{
            [starTimeLab setText:[NSString stringWithFormat:@"%d:%d",sec,mmin]];
        }
    }
    
    if(endttime<=0){
        [endTimeLab setText:@"00:00"];
    }else{
        
        int sec = endttime/60;
        int mmin = (int)endttime%60;
        
        if(sec<10 && mmin<10){
            [endTimeLab setText:[NSString stringWithFormat:@"0%d:0%d",sec,mmin]];
        }else if(sec<10 && mmin>=10){
            [endTimeLab setText:[NSString stringWithFormat:@"0%d:%d",sec,mmin]];
        }else if (sec>=10 && mmin<10){
            [endTimeLab setText:[NSString stringWithFormat:@"%d:0%d",sec,mmin]];
        }else{
            [endTimeLab setText:[NSString stringWithFormat:@"%d:%d",sec,mmin]];
        }
    }
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration)) 
	{
		mScrubber.minimumValue = 0.0;
        [self showStarLabletimeToEndLableTime:0.0 end:0.0];
		return;
	} 

	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		float minValue = [self.mScrubber minimumValue];
		float maxValue = [self.mScrubber maximumValue];
		double time = CMTimeGetSeconds([self.mPlayer currentTime]);
		[self showStarLabletimeToEndLableTime:time end:duration];
		[self.mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
    /*缓冲进度*/
    NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//    NSLog(@"Time Interval:%f",timeInterval);
    CMTime duration11 = self.mPlayerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration11);
    [_cacheProgressV setProgress:timeInterval / totalDuration animated:YES];
}

// 计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.mPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [self.mPlayer rate];
	[self.mPlayer setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
	{
		isSeeking = YES;
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
            [self showStarLabletimeToEndLableTime:0.0 end:0.0];
			return;
		} 
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			[self showStarLabletimeToEndLableTime:time end:duration];
            
			[self.mPlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
				dispatch_async(dispatch_get_main_queue(), ^{
					isSeeking = NO;
				});
			}];
		}
	}
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
	if (!mTimeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) 
		{
            [self showStarLabletimeToEndLableTime:0.0 end:0.0];
			return;
		} 
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
			double tolerance = 0.5f * duration / width;
            
			[self showStarLabletimeToEndLableTime:tolerance end:duration];
            
			__weak AVVideoViewController *weakSelf = self;
			mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
			^(CMTime time)
			{
				[weakSelf syncScrubber];
			}];
		}
	}

	if (mRestoreAfterScrubbingRate)
	{
		[self.mPlayer setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing
{
	return mRestoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.mScrubber.enabled = YES;
}

-(void)disableScrubber
{
    self.mScrubber.enabled = NO;    
}

#pragma mark
#pragma mark View Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self setPlayer:nil];
		
		[self setEdgesForExtendedLayout:UIRectEdgeAll];
	}
	
	return self;
}

- (id)init
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
    {
        return [self initWithNibName:@"AVPlayerDemoPlaybackView-iPad" bundle:nil];
	} 
    else 
    {
        return [self initWithNibName:@"AVPlayerDemoPlaybackView" bundle:nil];
	}
}


//改变声音

-(void)tapgestures:(UIGestureRecognizer*)tapss
{
    UIView* mviews = tapss.view;
    if(tapss.state == UIGestureRecognizerStateBegan){
        firstPoint = [tapss locationInView:mviews];
    }else if (tapss.state == UIGestureRecognizerStateChanged){
        lastPoint = [tapss locationInView:mviews];
        float xx = lastPoint.x-firstPoint.x;
        float yy = lastPoint.y-firstPoint.y;
        float L = sqrtf(xx*xx + yy*yy);
        float angle = yy/L;
        
        if((angle >= 0.866 && angle < 1.0) || (angle>= -1.0 && angle <= -0.866)){
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            if(yy<0){
                float vom = fabs(yy/3000.0);
                mpc.volume += vom;  //0.0~1.0
                mpc = nil;
            }else{
                float vom = fabs(yy/3000.0);
                mpc.volume -= vom;  //0.0~1.0
                mpc = nil;
            }
        }
    }
}


- (void)viewDidUnload
{
    self.mPlaybackView = nil;
    self.mToolbar = nil;
    self.mPlayButton = nil;
    self.mStopButton = nil;
    self.mScrubber = nil;
	
	[super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setPlayer:nil];
    isShowToolBar = NO;
    self.m_title.text = mtitle;
//	UIView* view  = [self view];
//    UIPanGestureRecognizer* tapss = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapgestures:)];
//    [view addGestureRecognizer:tapss];
//    
//    UITapGestureRecognizer* TapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    TapRecognizer.numberOfTapsRequired = 1;
//    [view addGestureRecognizer:TapRecognizer];
    //播放
    [PlayBtn addTarget:self action:@selector(plays:) forControlEvents:UIControlEventTouchUpInside];
    //暂停
    [pasueBtn addTarget:self action:@selector(pauses:) forControlEvents:UIControlEventTouchUpInside];
    
    //播放器Frame适配
    [self playFrameAction];
    
	isSeeking = NO;
	[self initScrubberTimer];
	[self syncPlayPauseButtons];
	[self syncScrubber];
    
    //进度条滚动球
    [mScrubber setThumbImage:[UIImage imageNamed:@"jindu1.png"] forState:UIControlStateNormal];
}

//播放器Frame适配
-(void)playFrameAction{
    //收藏按钮状态
    [self collectionButState];
   
}

-(void)changetollBarView:(CGRect)rect{
    self.m_toobarBackView.frame =rect;
    self.m_toolbarViews.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.view bringSubviewToFront:self.m_toolbarViews];
    
    CGRect rect1 = CGRectZero;
    CGRect rects = CGRectZero;
    for (UIView * views in [self.m_toolbarViews subviews]) {
        if(views.tag == 1000){
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =15;
            if(rects.size.width>340){
                rects.size.width = 734;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 734;;
                sl.frame = rec;
                
            }else{
                rects.size.width = 330;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 330;;
                sl.frame = rec;
            }
            
            views.frame = rects;
            rect1 = rects;
            
        }else if(views.tag ==1001){
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =15;
            views.frame = rects;
            rect1 = rects;
        }else{
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =5;
            views.frame = rects;
            rect1 = rects;
            
        }
        
    }
}


-(void)willEnterFullView:(CGRect)rect
{
    self.m_toobarBackView.frame = rect;
    self.m_toolbarViews.frame = CGRectMake(0, 0, 1024, 55);
    [self.view bringSubviewToFront:self.m_toolbarViews];

    if(!minBtn){
        minBtn = [[UIButton alloc] init];
        minBtn.frame = CGRectMake(0, 0, 44, 44);
        [minBtn setImage:[UIImage imageNamed:@"全屏-缩小.png"] forState:UIControlStateNormal];
        [minBtn addTarget:self action:@selector(ExitFull:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(!VomBtn){
        VomBtn = [[UIButton alloc] init];
        VomBtn.frame = CGRectMake(0, 0, 44, 44);
        [VomBtn setImage:[UIImage imageNamed:@"全屏-音量.png"] forState:UIControlStateNormal];
        [VomBtn addTarget:self action:@selector(showVom:) forControlEvents:UIControlEventTouchUpInside];
    }
    

    MPVolumeView* reAireview = volumeView;
    CGRect recta = volumeView.frame;
    VomBtn.frame = recta;
    [self.m_toolbarViews insertSubview:VomBtn atIndex:4];
    [volumeView removeFromSuperview];
    volumeView = reAireview;
    
    UIButton* reFullBtn = fullBtn;
    CGRect rectaa = fullBtn.frame;
    minBtn.frame = rectaa;
    [self.m_toolbarViews insertSubview:minBtn atIndex:5];
    [fullBtn removeFromSuperview];
    fullBtn = reFullBtn;
    
    
    /**/
    
    CGRect rect1 = CGRectZero;
    CGRect rects = CGRectZero;
    
    for (UIView * views in [self.m_toolbarViews subviews]) {
        if(views.tag == 1000){
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =15;
            if(rects.size.width>340){
                rects.size.width = 330;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 330;;
                sl.frame = rec;
            }else{
                rects.size.width = 734;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 734;;
                sl.frame = rec;
            }
            
            views.frame = rects;
            rect1 = rects;
            
        }else{
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =5;
            views.frame = rects;
            rect1 = rects;
            
        }
    }
    
//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hiddenToolview:) userInfo:nil repeats:NO];
    
}

-(void)showVom:(UIButton*)sender
{
    NSLog(@"显示声音");
    if(![sender isSelected]){
        CGRect rect = sender.frame;
        rect.origin.x += 10;
        rect.origin.y = 500;
        rect.size.width = 44;
        rect.size.height = 200;
        
        if(!ChangevolumeViews){
            ChangevolumeViews = [ [MPVolumeView alloc] init];
            [ChangevolumeViews setVolumeThumbImage:[UIImage imageNamed:@"播放全屏-进度.png"] forState:UIControlStateNormal];
            ChangevolumeViews.transform = CGAffineTransformMakeRotation(-M_PI_2);
            ChangevolumeViews.backgroundColor = [UIColor clearColor];
            ChangevolumeViews.alpha = 0.0;
            ChangevolumeViews.frame = rect;
            [ChangevolumeViews setShowsVolumeSlider:YES];
            [ChangevolumeViews setShowsRouteButton:NO];
            [self.view addSubview:ChangevolumeViews];
        }
        
        __weak AVVideoViewController* weak = self;
        [UIView animateWithDuration:0.3 animations:^{
            weak.ChangevolumeViews.alpha = 1.0;
        }];
        
        sender.selected  = YES;
    }else{
        sender.selected  = NO;
        __weak AVVideoViewController* weak = self;
        [UIView animateWithDuration:0.3 animations:^{
            weak.ChangevolumeViews.alpha = 0.0;
        }];
        
    }
}


-(void)willExitFullView:(CGRect)rect
{
    self.m_toobarBackView.frame = rect;
    self.m_toolbarViews.frame = CGRectMake(0, 0, 622, 55);

    UIButton* reminBtn = VomBtn;
    CGRect recta = VomBtn.frame;
    volumeView.frame = recta;
    [self.m_toolbarViews insertSubview:volumeView atIndex:4];
    [VomBtn removeFromSuperview];
    VomBtn = reminBtn;
    
    UIButton* reFullBtn = minBtn;
    CGRect rectaa = minBtn.frame;
    fullBtn.frame = rectaa;
    [self.m_toolbarViews insertSubview:fullBtn atIndex:5];
    [minBtn removeFromSuperview];
    minBtn = reFullBtn;
    
    
    CGRect rect1 = CGRectZero;
    CGRect rects = CGRectZero;
    
    for (UIView * views in [self.m_toolbarViews subviews]) {
        if(views.tag == 1000){
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =15;
            if(rects.size.width>340){
                rects.size.width = 330;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 330;;
                sl.frame = rec;
                
            }else{
                rects.size.width = 734;
                UISlider* sl = [[views subviews] firstObject];
                CGRect rec = sl.frame;
                rec.size.width = 734;;
                sl.frame = rec;
            }
            
            views.frame = rects;
            rect1 = rects;
            
        }else if(views.tag ==1001){
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =15;
            views.frame = rects;
            rect1 = rects;
        }else{
            
            rects = views.frame;
            rects.origin.x=rect1.origin.x+rect1.size.width+10;
            rects.origin.y =5;
            views.frame = rects;
            rect1 = rects;
            
        }
    }
    
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hiddenToolview:) userInfo:nil repeats:NO];
}


-(void)hiddenToolview:(NSTimer*)timer
{
    __weak AVVideoViewController* weak = self;
    
//    if(self.ChangevolumeViews){
//        self.ChangevolumeViews.alpha = 0.0f;
//    }
    
    [UIView animateWithDuration:0.3 animations:^{
        weak.m_toobarBackView.alpha = 0.0;
        if(![weak.m_titleToolView isHidden]){
            weak.m_titleToolView.alpha = 0.0;
        }
        if(weak.ChangevolumeViews){
            weak.ChangevolumeViews.alpha = 0.0f;
        }
        isShowToolBar = YES;
    }];
    
    [timer invalidate];
    timer = nil;
}



- (void)viewWillDisappear:(BOOL)animated
{
	[self.mPlayer pause];
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)setViewDisplayName
{
    /* Set the view title to the last component of the asset URL. */
    self.title = [mURL lastPathComponent];
    
    /* Or if the item has a AVMetadataCommonKeyTitle metadata, use that instead. */
	for (AVMetadataItem* item in ([[[self.mPlayer currentItem] asset] commonMetadata]))
	{
		NSString* commonKey = [item commonKey];
		
		if ([commonKey isEqualToString:AVMetadataCommonKeyTitle])
		{
			self.title = [item stringValue];
		}
	}
}


-(void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    //隐藏播放菜单
    if(!isShowToolBar){
        
        __weak AVVideoViewController* weak = self;
        
        [UIView animateWithDuration:0.3 animations:^{
            weak.m_toobarBackView.alpha = 0.0;
            if(![weak.m_titleToolView isHidden]){
                weak.m_titleToolView.alpha = 0.0;
            }
            isShowToolBar = YES;
        }];
        //通知状态栏隐藏
        NSNotification *statusNFhidden = [[NSNotification alloc] initWithName:@"hiddenAudioStatusAction" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"hidden", nil]];
        [[NSNotificationCenter defaultCenter] postNotification:statusNFhidden];
        
    //显示播放菜单
    }else{
        __weak AVVideoViewController* weak = self;
        
        [UIView animateWithDuration:0.3 animations:^{
            weak.m_toobarBackView.alpha = 1.0;
            if(![weak.m_titleToolView isHidden]){
                weak.m_titleToolView.alpha = 1.0;
            }
            isShowToolBar = NO;
//            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hiddenToolview:) userInfo:nil repeats:NO];
            //通知状态栏显示
            NSNotification *statusNF = [[NSNotification alloc] initWithName:@"hiddenAudioStatusAction" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"hidden", nil]];
            [[NSNotificationCenter defaultCenter] postNotification:statusNF];
        }];
    }
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
	UIView* view = [self view];
	UISwipeGestureRecognizerDirection direction = [gestureRecognizer direction];
	CGPoint location = [gestureRecognizer locationInView:view];
	
	if (location.y < CGRectGetMidY([view bounds]))
	{
		if (direction == UISwipeGestureRecognizerDirectionUp)
		{
			[UIView animateWithDuration:0.2f animations:
			^{
				[[self navigationController] setNavigationBarHidden:YES animated:YES];
			} completion:
			^(BOOL finished)
			{
				[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			}];
		}
		if (direction == UISwipeGestureRecognizerDirectionDown)
		{
			[UIView animateWithDuration:0.2f animations:
			^{
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
			} completion:
			^(BOOL finished)
			{
				[[self navigationController] setNavigationBarHidden:NO animated:YES];
			}];
		}
	}
	else
	{
		if (direction == UISwipeGestureRecognizerDirectionDown)
		{
            if (![self.mToolbar isHidden])
			{
				[UIView animateWithDuration:0.2f animations:
				^{
					[self.mToolbar setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([self.mToolbar bounds]))];
				} completion:
				^(BOOL finished)
				{
					[self.mToolbar setHidden:YES];
				}];
			}
		}
		else if (direction == UISwipeGestureRecognizerDirectionUp)
		{
            if ([self.mToolbar isHidden])
			{
				[self.mToolbar setHidden:NO];
				
				[UIView animateWithDuration:0.2f animations:
				^{
					[self.mToolbar setTransform:CGAffineTransformIdentity];
				} completion:^(BOOL finished){}];
			}
		}
	}
}

- (void)dealloc
{
    [self removePlayerTimeObserver];
	[mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.mPlayer removeObserver:self forKeyPath:@"rate"];
    [self.mPlayer removeObserver:self forKeyPath:@"currentItem"];
	
	[self.mPlayer pause];
    _detailsDict = nil;
    volumeView = nil;
    VomBtn = nil;
    fullBtn = nil;
    minBtn = nil;
    m_addmarkBtn = nil;
    
    mPlayerItem = nil;
    mPlaybackView = nil;
    mToolbar = nil;
    mPlayButton = nil;
    mStopButton = nil;
    m_toolbarViews = nil;
    m_title = nil;
}

@end

@implementation AVVideoViewController (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
	return mRestoreAfterScrubbingRate != 0.f || [self.mPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification 
{
	/* After the movie has played to its end time, seek back to time zero 
		to play it again. */
	seekToZeroBeforePlay = YES;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem. 
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.mPlayer currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
	if (mTimeObserver)
	{
		[self.mPlayer removeTimeObserver:mTimeObserver];
		mTimeObserver = nil;
	}
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 ** 
 **  1) values of asset keys did not load successfully, 
 **  2) the asset keys did load successfully, but the asset is not 
 **     playable
 **  3) the item did not become ready to play. 
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//														message:[error localizedFailureReason]
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles:nil];
//	[alertView show];
    
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
		/* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
	}
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable) 
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey, 
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey, 
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
	/* At this point we're ready to set up for playback of the asset. */
    	
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self 
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
	
    seekToZeroBeforePlay = NO;
	
    /* Create new player, if we don't already have one. */
    if (!self.mPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];	
        [self.mPlayer setAllowsExternalPlayback:YES];
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did 
         occur.*/
        [self.player addObserver:self 
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self 
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs 
         asynchronously; observe the currentItem property to find out when the 
         replacement will/did occur
		 
		 If needed, configure player item here (example: adding outputs, setting text style rules,
		 selecting media options) before associating it with a player
		 */
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        [self.mPlayer setAllowsExternalPlayback:YES];
        
        [self syncPlayPauseButtons];
    }
	[self.mPlayer play];
    [self.mScrubber setValue:0.0];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
**  Called when the value at the specified key path relative
**  to the given object has changed. 
**  Adjust the movie play and pause button controls when the 
**  player item "status" value changes. Update the movie 
**  scrubber control when the player item is ready to play.
**  Adjust the movie scrubber control when the player item 
**  "rate" value changes. For updates of the player
**  "currentItem" property, set the AVPlayer for which the 
**  player layer displays visual output.
**  NOTE: this method is invoked on the main queue.
** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path 
			ofObject:(id)object 
			change:(NSDictionary*)change 
			context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
		[self syncPlayPauseButtons];

        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because 
             it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                if(delegate&&[delegate respondsToSelector:@selector(removeViewSuccess)]){
                    [delegate removeViewSuccess];
                }
                
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self disableScrubber];
                [self disablePlayerButtons];
            }
            break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e. 
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self enableScrubber];
                [self enablePlayerButtons];
            }
            break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
            break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
        [self syncPlayPauseButtons];
	}
	/* AVPlayer "currentItem" property observer. 
        Called when the AVPlayer replaceCurrentItemWithPlayerItem: 
        replacement will/did occur. */
	else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.mPlaybackView setPlayer:mPlayer];
            
            [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and 
             fit the video within the layer’s bounds. */
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}



@end


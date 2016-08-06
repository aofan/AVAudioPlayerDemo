//
//  ViewController.m
//  GMAudioVideoCacheProgress
//
//  Created by gamin on 15/6/30.
//  Copyright (c) 2015年 gamin. All rights reserved.
//

#import "ViewController.h"
#import "MVVideoDetails.h"
#import "MVAudioDetails.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//视频
- (IBAction)videoAction:(id)sender {
    NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
    [objDict setObject:@"32" forKey:@"id"];
    [objDict setObject:@"雪窦寺" forKey:@"title"];
    [objDict setObject:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4" forKey:@"url"];
    
    MVVideoDetails *videoDetails = [[MVVideoDetails alloc] initWithNibName:@"MVVideoDetails" bundle:nil];
    videoDetails.detailsDict = objDict;
    [self.navigationController pushViewController:videoDetails animated:YES];
}

//音频
- (IBAction)audioAction:(id)sender {
    NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
    [objDict setObject:@"33" forKey:@"id"];
    [objDict setObject:@"凋谢的曾经 向梦园 蛋大大" forKey:@"title"];
    [objDict setObject:@"http://sc1.111ttt.com/2015/1/06/30/99301525147.mp3" forKey:@"url"];
    
    MVAudioDetails *audioDetails = [[MVAudioDetails alloc] initWithNibName:@"MVAudioDetails" bundle:[NSBundle mainBundle]];
    audioDetails.detailsDict = objDict;
    [self.navigationController pushViewController:audioDetails animated:YES];

}


@end

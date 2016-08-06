//
//  MVPublicMethod.m
//  palmtrends_MovieIphone
//
//  Created by geimin on 14/11/4.
//  Copyright (c) 2014年 Geimin. All rights reserved.
//

#import "MVPublicMethod.h"
static MVPublicMethod * sharedPublic = nil;
@implementation MVPublicMethod
//单例初始化
+(id)sharedPublicMethod{
    @synchronized (self){
        if(!sharedPublic){
            sharedPublic = [[MVPublicMethod alloc] init];
        }
        return sharedPublic;
    }
    return sharedPublic;
}

//收藏数据
+(NSMutableDictionary *)collectionDictionary{
    NSString *collectionPath = [self collectionPath];
    //收藏数据
    NSMutableDictionary *collDict = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:collectionPath];
    if(collDict == nil){
        collDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *articleArr = [[NSMutableArray alloc] init];
        NSMutableArray *videoArr = [[NSMutableArray alloc] init];
        [collDict setObject:articleArr forKey:@"article"];
        [collDict setObject:videoArr forKey:@"video"];
        //存往本地
        [self saveCellctionDataWith:collDict];
    }
    
    return collDict;
}
//收藏文章数据列表
+(NSMutableArray *)articleArray{
    NSMutableDictionary *tempDict = [self collectionDictionary];
    return [tempDict objectForKey:@"article"];
}
//收藏视频时间列表
+(NSMutableArray *)videoArray{
    NSMutableDictionary *tempDict = [self collectionDictionary];
    return [tempDict objectForKey:@"video"];
}
//收藏路径
+(NSString *)collectionPath{
    //Documents-cache
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString*docupath = [NSString stringWithFormat:@"%@/cache",docuPath];
    //创建文件夹：若不存在路径则自动创建
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:docupath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ){
        [[NSFileManager defaultManager] createDirectoryAtPath:docupath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //收藏路径
    NSString *collectionPath = [NSString stringWithFormat:@"%@/collection",docupath];
    return collectionPath;
}
//存储收藏数据到本地
+(void)saveCellctionDataWith:(NSMutableDictionary *)theDict{
    NSString *collectionPath = [self collectionPath];
    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:theDict];
    [[NSFileManager defaultManager] createFileAtPath:collectionPath contents:tempData attributes:nil];
}
//是否本地有收藏当前数据
+(BOOL)isCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark{
    BOOL result = NO;
    //收藏数据
    NSMutableDictionary *colDict = [self collectionDictionary];
    NSMutableArray *selectArr;
    //文章
    if([theMark isEqualToString:@"article"]){
        selectArr = [colDict objectForKey:@"article"];
    //视频
    }else if([theMark isEqualToString:@"video"]){
        selectArr = [colDict objectForKey:@"video"];
    }
    //当前收藏是否有这个对象
    for (int i = 0; i < selectArr.count ; i ++) {
        NSDictionary *tempDict = (NSDictionary *)[selectArr objectAtIndex:i];
        if([[theDict objectForKey:@"id"] isEqualToString:[tempDict objectForKey:@"id"]]){
            result = YES;
        }
    }
    
    return result;
}

//添加到收藏
+(BOOL)addCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark{
    BOOL result = NO;
    //收藏数据
    NSMutableDictionary *colDict = [self collectionDictionary];
    NSMutableArray *selectArr;
    //文章
    if([theMark isEqualToString:@"article"]){
        selectArr = [colDict objectForKey:@"article"];
    //视频
    }else if([theMark isEqualToString:@"video"]){
        selectArr = [colDict objectForKey:@"video"];
    }
    //当前收藏是否有这个对象
    BOOL haveDict = NO;
    for (int i = 0; i < selectArr.count ; i ++) {
        NSDictionary *tempDict = (NSDictionary *)[selectArr objectAtIndex:i];
        if([[theDict objectForKey:@"id"] isEqualToString:[tempDict objectForKey:@"id"]]){
            haveDict = YES;
        }
    }
    //添加至收藏
    if(haveDict == NO){
        [selectArr insertObject:theDict atIndex:0];
        //存储收藏数据到本地
        [self saveCellctionDataWith:colDict];
        result = YES;
    }else{
        result = NO;
    }
    
    return result;
}
//取消收藏
+(BOOL)cancelCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark{
    BOOL result = NO;
    //收藏数据
    NSMutableDictionary *colDict = [self collectionDictionary];
    NSMutableArray *selectArr;
    //文章
    if([theMark isEqualToString:@"article"]){
        selectArr = [colDict objectForKey:@"article"];
    //视频
    }else if([theMark isEqualToString:@"video"]){
        selectArr = [colDict objectForKey:@"video"];
    }
    //当前收藏是否有这个对象
    for (int i = 0; i < selectArr.count ; i ++) {
        NSDictionary *tempDict = (NSDictionary *)[selectArr objectAtIndex:i];
        if([[theDict objectForKey:@"id"] isEqualToString:[tempDict objectForKey:@"id"]]){
            //取消收藏
            [selectArr removeObject:tempDict];
            //存储收藏数据到本地
            [self saveCellctionDataWith:colDict];
            result = YES;
            break;
        }
    }
    
    return result;
}


@end

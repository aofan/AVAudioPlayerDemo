//  公共方法
//  MVPublicMethod.h
//  palmtrends_MovieIphone
//
//  Created by geimin on 14/11/4.
//  Copyright (c) 2014年 Geimin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVPublicMethod : NSObject

//单例初始化
+(id)sharedPublicMethod;

/*收藏
 */
//是否本地有收藏当前数据
+(BOOL)isCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark;
//添加到收藏
+(BOOL)addCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark;
//取消收藏
+(BOOL)cancelCollectionWith:(NSDictionary *)theDict andMark:(NSString *)theMark;
//收藏文章数据列表
+(NSMutableArray *)articleArray;
//收藏视频时间列表
+(NSMutableArray *)videoArray;

@end

//
//  NEStoryAPI.m
//  NEStorySDK
//
//  Created by H-YXH on 14-4-17.
//  Copyright (c) 2014年 NetEase. All rights reserved.
//

#import "NEStoryAPI.h"

@implementation NEStoryAPI

/**
 *  @brief 注册同步学习进度完成后回调方法
 *
 *  @param dictionary eg:{listener = callback}
 *  
 *  @return 注册成功返回YES，注册失败返回NO。
 */
+ (BOOL)RegistSynchronousLearningProgressCallback:(NSDictionary*)dictionary {
    return false;
}

/**
 *  @brief 启动网易识字主App进行学习进度同步
 */
+ (void)SynchronousLearningProgressWithElearnApp {
    
}
@end

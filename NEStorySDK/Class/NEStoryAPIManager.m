//
//  NEStoryAPIManager.m
//  NEStorySDK
//
//  Created by H-YXH on 14-4-22.
//  Copyright (c) 2014年 NetEase. All rights reserved.
//

#import "NEStoryAPIManager.h"
#import "NEStoryAPIDefines.h"

@implementation NEStoryAPIManager

+ (NEStoryAPIManager *)sharedManager
{
    static NEStoryAPIManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil]init];
    });
    return instance;
}

#pragma mark
#pragma mark URL请求处理
- (BOOL)handleUrl:(NSURL*)url {
    // 返回故事书设置成功与失败的状态
    if ([LAST_PATH_COMPONENT_FOR_SETTING_STATUS isEqualToString:url.lastPathComponent]) {
        return [self handleSettingStatus:url.query];
    }
    
    
    // 将网易识字传递过来的数据进行存储
    if ([LAST_PATH_COMPONENT_FOR_STORE_DATA isEqualToString:url.lastPathComponent]) {
        return [self storingDataTransferedFromElearn];
    }
    
    // 无法处理的Url_Scheme进行提示
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示"
                                                 message:@"无法处理的Url_Scheme"
                                                delegate:self
                                       cancelButtonTitle:@"确定"
                                       otherButtonTitles:nil, nil];
    [av show];
    [av release];
    
    return NO;
}

#pragma mark
#pragma mark 与网易识字同步
- (void)synchronousWitheLearnApp {
    NSString* m_SDKVersion  = kMainAppSDKRequireVersion;
    NSString* m_UrlScheme   = URL_SCHEME_STORY_APP;
    NSString* m_Component   = LAST_PATH_COMPONENT_FOR_SYNCHRONOUS;
    NSString* m_TargetUrl   = URL_SCHEME_MAIN_APP;
    NSString* m_AppName     = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString* m_AppVersion  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString* urlString = [NSString stringWithFormat:@"%@://61.163.com/%@?sdkversion=%@&urlscheme=%@&name=%@&version=%@", m_TargetUrl, m_Component, m_SDKVersion, m_UrlScheme, m_AppName, m_AppVersion];
    DMLog(@"网易识字同步学习进度URL:%@", urlString);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

#pragma mark
#pragma mark 网易识字学习流程设置成功的状态处理
- (BOOL)handleSettingStatus:(NSString*)query {
    NSString* query = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* components = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary* parameters = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString* component in components)
    {
        NSArray* subComponents = [component componentsSeparatedByString:@"="];
        [parameters setObject:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
    }
    
    BOOL m_SettingStatus = [[parameters valueForKey:@"status"] integerValue] > 0 ? YES : NO;
    
    if (m_SettingStatus) {
        //设置成功
    }
    else {
        //设置失败
        NSString* m_ErrorString = [parameters valueForKey:@"error"];
        if ([m_ErrorString length] == 0) {
            m_ErrorString = @"未知的原因导致设置失败！"；
        }
        
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:m_ErrorString
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil, nil];
    }
    
    return YES;
}

#pragma mark
#pragma mark 存储学习进度
/**
 *  存储网易识字传递过来的学习进度及配置文件
 *
 *  @return 存储成功返回YES, 失败返回NO
 */
- (BOOL)storingDataTransferedFromElearn {
    NSData* m_PasteBoardData = [[UIPasteboard generalPasteboard] dataForPasteboardType:kPasteBoardTypeAudioFile];
    
    if (m_PasteBoardData) {
        NSDictionary* m_DictInfo = [NSKeyedUnarchiver unarchiveObjectWithData:m_PasteBoardData];
        
        if (m_DictInfo) {
            // 章节信息
            NSString* chapterInfo       = [m_DictInfo valueForKey:kDictionaryChapterInfo];
            
            // 音频文件路径信息
            NSString* soundPath         = [m_DictInfo valueForKey:kDictionaryAudioFilePath];
            NSArray* pathArray          = [soundPath componentsSeparatedByString:@"&"];
            
            // 文件管理系统初始化
            NSFileManager* p_FileManager  = [NSFileManager defaultManager];
            [p_FileManager setDelegate:self];
            
            NSString* bunldPath = [[NSBundle mainBundle] bundlePath];
            NSString* lastPath  = bunldPath.lastPathComponent;
            NSRange range       = [bunldPath rangeOfString:lastPath];
            bunldPath           = [bunldPath stringByReplacingCharactersInRange:range withString:@""];
            
            NSString* targetPath= [NSString stringWithFormat:@"%@",pathArray[0]];
            lastPath            = targetPath.lastPathComponent;
            range               = [targetPath rangeOfString:lastPath];
            targetPath          = [targetPath stringByReplacingCharactersInRange:range withString:@""];
            targetPath          = [targetPath substringFromIndex:1];
            NSArray* array      = [targetPath pathComponents];
            targetPath = @"";
            
            for (int i = 0; i != 4; i ++) { targetPath = [NSString stringWithFormat:@"%@%@/", targetPath, array[i]]; }
            
            targetPath          = [NSString stringWithFormat:@"%@%@", bunldPath, targetPath];
            
            NSString* configFilePath    = [NSString stringWithFormat:@"%@Config.txt", targetPath];
            BOOL isDir                  = NO;
            BOOL isDirExist             = [p_FileManager fileExistsAtPath:targetPath isDirectory:&isDir];
            
            // 删除目标目录中的所有文件及子目录
            if (isDir && isDirExist) { [p_FileManager removeItemAtPath:targetPath error:nil]; }
            
            //将音频文件写入硬盘
            for (NSString* child in pathArray) {
                lastPath = child.lastPathComponent;
                
                if ([lastPath hasSuffix:@"mp3"]) {
                    range           = [child rangeOfString:lastPath];
                    NSString* dir   = [child stringByReplacingCharactersInRange:range withString:@""];
                    dir             = [NSString stringWithFormat:@"%@/..%@",[[NSBundle mainBundle] bundlePath],dir];
                    isDirExist      = [p_FileManager fileExistsAtPath:dir isDirectory:&isDir];
                    
                    // 如果目录不存在，则创建相应目录
                    if (!(isDir && isDirExist)) { [p_FileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil]; }
                    
                    NSData* data    = [m_DictInfo valueForKey:child];
                    dir             = [NSString stringWithFormat:@"%@/..%@",[[NSBundle mainBundle] bundlePath], child];
                    
                    [data writeToFile:dir atomically:YES];
                }
            }
            
            // 将学号、昵称、章节信息传递给Unity3D
            // 启动相应故事章节
            
            // 将配置文件写入硬盘
            [chapterInfo writeToFile:configFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"数据为空"
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil, nil];
            [av show];
            [av release];
        }
        
        [self clearPasteBoard];
    }
    else {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:@"没有数据可以处理"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil, nil];
        [av show];
        [av release];
    }
    
    [[UIPasteboard generalPasteboard] setData:nil forPasteboardType:kPasteBoardTypeAudioFile];
}

/**
 *  NSFileManager Delegate Method
 */
- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path
{
    return [fileManager isDeletableFileAtPath:path];
}

/**
 *  清除粘贴板数据
 */
- (void)clearPasteBoard
{
    UIPasteboard* pasteBoard    = [UIPasteboard generalPasteboard];
    NSData* data                = [pasteBoard dataForPasteboardType:kPasteBoardTypeAudioFile];
    
    if (data) { [pasteBoard setData:nil forPasteboardType:kPasteBoardTypeAudioFile]; }
}
@end

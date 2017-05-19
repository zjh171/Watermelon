//
//  Watermelon.h
//  Watermelon
//
//  Created by zhujinhui on 17/3/7.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERDEFAULTS_HOSTKEY @"NSUserDefaultCurrentBaseUrlStr"

#define HOST ([[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_HOSTKEY] ? [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_HOSTKEY] : [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultOriginalBaseUrlStr"])

static NSString  *WatermelonNotificationUpdateUIHeader = @"Watermelon.Notification.UpdateUIHeader";

static NSString  *WatermelonNotificationRefreshWebViewController = @"com.watermelon.notification.loginsuccess";

/**
 * html等资源文件下载到本地后，下次读取读取失败的通知
 */
static NSString  *WatermelonNotificationLoadLocalFileFailed = @"com.watermelon.notification.loginsuccess";


@interface Watermelon : NSObject

typedef void(^WatermelonDownloadFinished)(NSString *zipUrl);


+(Watermelon *) shareInstance;
/**
 * 注册服务
 */
+(void) registeWatermelonService;

/**
 * 下载web资源，资源必须是zip压缩的。
 */
-(void)downloadWebAppWithUrl:(NSString *) webAppUrlString downloadFinished:(WatermelonDownloadFinished) finished;



-(void)setPackageNameWithURL:(NSString *) urlString ;

@end

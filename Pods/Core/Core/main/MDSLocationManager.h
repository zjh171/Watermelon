//
//  MDSLocationManager.h
//  Core
//
//  Created by kyson on 2016/11/1.
//  Copyright © 2016年 kyson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef NS_ENUM(NSUInteger, MDSLocationServiceStatus)
{
    /**
     *  定位服务被打开
     */
    MDSLocationServiceStatusOpen,
    
    /**
     *  定位服务正在请求权限
     */
    MDSLocationServiceStatusNotDetermined,
    
    /**
     *  定位服务权限请求被拒绝
     */
    MDSLocationServiceStatusDenied,
    
    /**
     *  网络不给力
     */
    MDSLocationServiceStatusNetworkDisabled,
    
    /**
     *  定位服务打开，并已经定位成功
     */
    MDSLocationServiceStatusSucceeded,
    
    /**
     *  定位服务打开，但是定位失败
     */
    MDSLocationServiceStatusFailed,
};



@interface MDSLocationManager : NSObject



+(id)shareInstance;

/**
 *  定位获取的坐标
 */
@property (nonatomic, readonly) CLLocation *location;

/**
 *  定位获取的城市名
 */
@property (nonatomic, readonly) NSString *cityName;

/**
 *  定位获取的城市区域名
 */
@property (nonatomic, readonly) NSString *districtName;

/**
 *  定位服务的状态
 */
@property (nonatomic, readonly) MDSLocationServiceStatus status;



/**
 *  激活定位服务。
 *
 *  @param isRestart 标志是否是重启。
 */
- (void)startLocate:(BOOL)isRestart;

/**
 *  关闭定位服务。
 */
- (void)stopLocate;

/**
 *  定位服务的状态改变后，将得到此通知。此通知发往主线程。用户收到此通知后可以访问本类的 status 属性。
 */
@property (nonatomic, readonly) NSString *MDSLocationServiceStatusChangeNotification;




@end























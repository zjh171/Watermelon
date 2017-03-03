//
//  MDSLocationManager.m
//  Core
//
//  Created by kyson on 2016/11/1.
//  Copyright © 2016年 kyson. All rights reserved.
//

#import "MDSLocationManager.h"
#import <UIKit/UIKit.h>



@interface MDSLocationManager ()




@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, assign) MDSLocationServiceStatus status;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *districtName;
@property (nonatomic, strong) NSString *BIFLocationServiceStatusChangeNotification;






@end

@implementation MDSLocationManager



-(instancetype)init{
    if (self = [super init]) {
        
        self.cityName = @"";
        self.districtName = @"";
        self.BIFLocationServiceStatusChangeNotification = @"发发发发你妹的";
        //    [self startLocate:NO];
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

        
    }
    
    
    return self;
}




#pragma mark - publics

- (void)startLocate:(BOOL)isRestart
{
    if (isRestart) {
        [self stopLocate];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocate
{
    [self.locationManager stopUpdatingLocation];
}



- (void)didEnterBackground:(NSNotification *)notification
{
    [self stopLocate];
}












@end

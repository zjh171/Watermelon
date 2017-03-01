//
//  WMActionManager.m
//  Watermelon
//
//  Created by zhujinhui on 17/3/1.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMActionManager.h"

@implementation WMActionManager

static WMActionManager *actionManager = nil;

+(WMActionManager *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{   //onceToken是GCD用来记录是否执行过 ，如果已经执行过就不再执行(保证执行一次）
        actionManager = [[WMActionManager alloc] init];
    });

    return actionManager;
}


-(void)managerWithAction:(NSString *) action{
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"1" object:nil];

    
    
}





@end

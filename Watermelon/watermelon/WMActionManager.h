//
//  WMActionManager.h
//  Watermelon
//
//  Created by zhujinhui on 17/3/1.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMActionManager : NSObject



+(WMActionManager *)shareInstance;

/**
 处理对应的action

 @param action 动作
 */
-(void)managerWithAction:(NSString *) action;


@end

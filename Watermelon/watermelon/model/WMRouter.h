//
//  WMRouter.h
//  MDSResidentApp
//
//  Created by jilei on 16/7/6.
//  Copyright © 2016年 medishare.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef UIViewController *  (^WMRouterBlock)();
@interface WMRouter : NSObject
/**
 *  注册映射所有的路由关系，通过json文件添加影射关系
 */
+ (void)registerAllControllers;

/**
 *  你可以使用key去push出一个viewController
 *
 *  @param urlString
 */
+(void)openingPath:(NSString*)urlString;

@end

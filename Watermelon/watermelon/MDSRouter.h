//
//  MDSRouter.h
//  MDSResidentApp
//
//  Created by jilei on 16/7/6.
//  Copyright © 2016年 medishare.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef UIViewController *  (^MDSRouterBlock)();
@interface MDSRouter : NSObject
/**
 *  注册映射所有的路由关系，通过json文件添加影射关系
 */
+ (void)registerAllControllers;
/**
 *  如果不想每次都创建对象, 也可以直接映射一个实例
 *
 *  @param Key        key
 *  @param controller 控制器
 */
+(void)mapKey:(NSString*)Key WithController:(UIViewController*)controller;

/**
 *  注册单个的控制器的映射值
 *
 *  @param mapKey              控制器对应的key
 *  @param ControllerClassName 控制器的名称
 */

+(void)CreatingMapWithController:(NSString*)mapKey WithControllerClassName:(NSString*)ControllerClassName;

/**
 *  当取出ViewController的时候, 如果有单例[ViewController sharedInstance], 默认返回单例, 如果没有, 返回[[ViewController alloc] init].
 *
 *  @param mapKey 映射的key
 */
+(UIViewController*)getControllerWithMapKey:(NSString*)mapKey;
/**
 *  如果想更好的定制对象, 可以用block
 */
+(void)mapKey:(NSString*)key toBlock:(MDSRouterBlock)block;

/**
 *  你可以使用key去push出一个viewController
 *
 *  @param urlString
 */
+(void)openingPath:(NSString*)urlString;
@end

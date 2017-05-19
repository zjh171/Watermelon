//
//  MDJSCallManager.h
//  JavaScriptAndObjectiveC
//
//  Created by jilei on 2017/3/14.
//  Copyright © 2017年 huangyibiao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


typedef void (^MDSJSCallBackBlock)(NSString *method, NSArray *params);


@interface MDJSCallManager : NSObject 



/**
 *  JavaScript调用Objective-C中某个类的方法
 *
 *  @param webView  webView
 *  @param name     调用类名
 *  @param toObject 调用类
 以JS中调用了mApplication.getVersion()函数为例,
 首先创建调用类如下：
 @protocol JSObjectProtocol <JSExport>
 - (NSString *)getVersion; // 这里的函数可根据JS内的调用函数去定义，如果函数多个可在这里添加
 @end
 
 @interface JSObject : NSObject <JSObjectProtocol>
 
 @end
 
 @implementation JSObject
 
 - (NSString *)getVersion
 {
 return @"1.0.0";
 }
 @end
 
 [JSOCInteraction JSCallClassWebView:webView name:@"mApplication" toObject:[JSObject new]];
 */
+ (void)JSCallClassWebView:(UIWebView *)webView name:(NSString *)name toObject:(id<JSExport>)toObject;

/**
 *  JavaScript调用Objective-C的方法
 *
 *  @param webView webView
 *  @param methods 函数数组 例如:@[@"test",@"login"]，注意这里的函数名不要带小括号
 *  @param block   结束回调
 */
+ (void)JSCallOCWebView:(UIWebView *)webView methods:(NSArray<NSString *> *)methods callBack:(MDSJSCallBackBlock)block;

/**
 *  Objective-C调用JavaScript的函数
 *
 *  @param webView webView
 *  @param methods 函数数组 例如:@[@"test()",@"login(username,password)"]
 *  @param block   结束回调
 */
+ (void)OCCallJSWebView:(UIWebView *)webView methods:(NSArray<NSString *> *)methods callBack:(void(^)(BOOL success,NSError *error))block;


/**
 *  Objective-C调用JavaScript的函数
 *
 *  @param webView webView
 *  @param methods 函数名称 例如:@[@"test"]
 *  @param block   结束回调
 */
+ (void)OCCallJSWebView:(UIWebView *)webView methods:(NSString *)method withPrams:(NSArray*)prams callBack:(void (^)(BOOL, NSError *))block;
@end

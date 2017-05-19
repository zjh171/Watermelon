//
//  MDJSCallManager.m
//  JavaScriptAndObjectiveC
//
//  Created by jilei on 2017/3/14.
//  Copyright © 2017年 huangyibiao. All rights reserved.
//

#import "MDJSCallManager.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
@interface MDJSCallManager ()

@property (nonatomic, strong) MDSJSCallBackBlock jcBlock;

@end
@implementation MDJSCallManager
void execute(id self, SEL _cmd)
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    //    return 100;
    if (self) {
        [self handleExecute];
    }
}

+ (void)JSCallClassWebView:(UIWebView *)webView name:(NSString *)name toObject:(id<JSExport>)toObject
{
    JSContext * context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[name] = toObject;
}

+ (void)JSCallOCWebView:(UIWebView *)webView methods:(NSArray<NSString *> *)methods callBack:(MDSJSCallBackBlock)block
{
    JSContext * context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    JSObject *jsObj = [JSObject new];
    [methods enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr;
        if ([obj isKindOfClass:[NSString class]]) {
            arr = [obj componentsSeparatedByString:@"."];
        }
        if (arr.count > 1) {
            //            IMP imp = imp_implementationWithBlock(^(id obj) {
            //                NSLog(@"%@", obj);
            //                if (block) {
            //                    block(arr[1],nil);
            //                }
            //                return @"1";
            //            });
            //            class_addMethod([JSObject class], NSSelectorFromString(arr[1]), imp, "v@:");
            //            context[arr[0]] = jsObj;
        }else{
            
            context[obj] = ^() {
                NSArray *args = [JSContext currentArguments];
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(obj,args);
                    });
                }
            };
        }
        
    }];
}

- (void)handleExecute
{
    
}

+ (void)OCCallJSWebView:(UIWebView *)webView methods:(NSArray<NSString *> *)methods callBack:(void (^)(BOOL, NSError *))block
{
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [methods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *alertJS=obj; //准备执行的js代码
        JSValue *value = [context evaluateScript:alertJS];//通过oc方法调用js的alert
        if (value) {
            NSLog(@"%@",value);
        }
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(YES,nil);
            });
        }
    }];
}
+ (void)OCCallJSWebView:(UIWebView *)webView methods:(NSString *)method withPrams:(NSArray*)prams callBack:(void (^)(BOOL, NSError *))block
{
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    [context[method] callWithArguments:prams];
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(YES,nil);
        });
    }
}


@end

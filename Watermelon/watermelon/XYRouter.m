//
//  XYRouter.m
//  XYRouter
//
//  Created by heaven on 15/1/21.
//  Copyright (c) 2015年 heaven. All rights reserved.
//

#import "XYRouter.h"
#import <objc/runtime.h>

#import "NSString+JKURLEncode.h"

#pragma mark - XYRouter_private
@interface NSString (XYRouter_private)
- (NSMutableDictionary *)__uxy_dictionaryFromQueryComponents;
@end

@interface XYRouterNib : NSObject
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation XYRouterNib
@end

#pragma mark - UIViewController_private
@interface UIViewController (UIViewController_private)
@property (nonatomic, copy) NSString *uxy_URLPath;
@end

#pragma mark -
@interface XYRouter ()

@property (nonatomic, strong) NSMutableDictionary *map;
@property (nonatomic, strong) UIViewController *currentViewRoute;       // 当前的控制器
@property (nonatomic, copy) NSString *currentPath;

@property (nonatomic, assign) BOOL isPathCacheChanged;

@end

@implementation XYRouter

+ (instancetype)sharedInstance
{
    static XYRouter *router = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (!router)
        {
            router = [[self alloc] init];
        }
    });
    return router;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isPathCacheChanged = YES;
        _map                = [@{} mutableCopy];
    }
    return self;
}

- (NSString *)currentPath
{
    if (!_isPathCacheChanged)
    {
        return _currentPath;
    }

    __block NSString *string    = @"";
    UINavigationController *nvc = [[self class] __expectedVisibleNavigationController];

    if (nvc)
    {
        [nvc.viewControllers
         enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
            NSString *tmp = string.length > 0 ? @"%@/%@" : @"%@%@";
            string = [NSString stringWithFormat:tmp, string, vc.uxy_URLPath];
        }];
    }
    else
    {
        UIViewController *vc = [[self class] __visibleViewController];
        NSString *tmp        = string.length > 0 ? @"%@/%@" : @"%@%@";
        string = [NSString stringWithFormat:tmp, string, vc.uxy_URLPath];
    }

    _currentPath = string;

    return _currentPath;
}

- (void)mapKey:(NSString *)key toControllerClassName:(NSString *)className
{
    if (key.length == 0)
    {
        return;
    }

    _map[key] = className;
}

- (void)mapKey:(NSString *)key toControllerInstance:(UIViewController *)viewController
{
    if (key.length == 0)
    {
        return;
    }

    _map[key] = viewController;
}

- (void)mapKey:(NSString *)key toBlock:(XYRouterBlock)block
{
    if (key.length == 0)
    {
        return;
    }

    _map[key] = block;
}

- (void)mapKey:(NSString *)key toNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if (key.length == 0)
    {
        return;
    }

    XYRouterNib *nib = [[XYRouterNib alloc] init];
    nib.nibName = nibName;
    nib.bundle  = bundle;
    _map[key]   = nib;
}

- (id)viewControllerForKey:(NSString *)key
{
    NSObject *obj = key.length > 0 ? _map[key] : nil;

    if (obj == nil)
    {
        return nil;
    }

    UIViewController *vc = nil;

    if ([obj isKindOfClass:[NSString class]])
    {
        Class classType = NSClassFromString((NSString *)obj);
#ifdef DEBUG
        NSString *error = [NSString stringWithFormat:@"%@ must be  a subclass of UIViewController class", obj];
        NSAssert([classType isSubclassOfClass:[UIViewController class]], error);
#endif
        if ([classType respondsToSelector:@selector(sharedInstance)])
        {
            vc = [classType sharedInstance];
        }
        else
        {
            vc = [[classType alloc] init];
        }
    }
    else if ([obj isKindOfClass:[UIViewController class]])
    {
        vc = (UIViewController *)obj;
    }
    else if ([obj isKindOfClass:[XYRouterNib class]])
    {
        vc = [[UIViewController alloc] initWithNibName:((XYRouterNib *)obj).nibName
                                                bundle:((XYRouterNib *)obj).bundle];
    }
    else
    {
        XYRouterBlock objBlock = (XYRouterBlock)obj;
        vc = objBlock();
    }

    if ([vc isKindOfClass:[UINavigationController class]])
    {
        ((UINavigationController *)vc).visibleViewController.uxy_URLPath = key;
    }
    else
    {
        vc.uxy_URLPath = key;
    }

    return vc;
}

- (id)viewControllerForClassName:(NSString *)name
{
    Class classType = NSClassFromString(name);

    if (![classType isKindOfClass:[UIViewController class]])
    {
        return nil;
    }

    UIViewController *vc = [[classType alloc] init];
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        ((UINavigationController *)vc).visibleViewController.uxy_URLPath = name;
    }
    else
    {
        vc.uxy_URLPath = name;
    }

    return vc;
}

- (UIViewController *)__viewControllerForKey:(NSString *)key anchor:(NSString *)anchor argument:(NSArray *)argument
{
    NSObject *obj = key.length > 0 ? _map[key] : nil;

    if (obj == nil)
    {
        return nil;
    }

    SEL sel = NSSelectorFromString(anchor);

    if (sel == NULL)
    {
        return nil;
    }


    NSMethodSignature *sig = [NSClassFromString(key) methodSignatureForSelector:sel];
    if (sig == nil)
    {
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.target   = NSClassFromString(key);
    invocation.selector = sel;

    for (int i = 0; i < argument.count; i++)
    {
        const char *argumentType = [sig getArgumentTypeAtIndex:i + 2];
        id arg                   = argument[i];
        // js数据类型转换成oc数据类型
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0])
        {
#define __UXY_CALL_ARG_CASE(_typeString, _type, _selector) \
    case _typeString: {                              \
        _type value = [arg _selector];                     \
        [invocation setArgument:&value \
                        atIndex:i + 2]; \
        break; \
    }

            __UXY_CALL_ARG_CASE('c', char, charValue)
            __UXY_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
            __UXY_CALL_ARG_CASE('s', short, shortValue)
            __UXY_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
            __UXY_CALL_ARG_CASE('i', int, intValue)
            __UXY_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
            __UXY_CALL_ARG_CASE('l', long, longValue)
            __UXY_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
            __UXY_CALL_ARG_CASE('q', long long, longLongValue)
            __UXY_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
            __UXY_CALL_ARG_CASE('f', float, floatValue)
            __UXY_CALL_ARG_CASE('d', double, doubleValue)
            __UXY_CALL_ARG_CASE('B', BOOL, boolValue)

            default:
                if ([arg isKindOfClass:[NSNull class]])
                {
                    arg = [NSNull null];
                    [invocation setArgument:&arg
                                    atIndex:i + 2];
                }
                else
                {
                    [invocation setArgument:&arg
                                    atIndex:i + 2];
                }
                break;
        }
    }

    [invocation invoke];
    void *returnValue;
    [invocation getReturnValue:&returnValue];

    return (__bridge id)returnValue;
}

- (void)openURLString:(NSString *)URLString
{
    // 处理模态dismiss
    BOOL isChanged = [self __handleDismissWithURLString:URLString];
    if (isChanged)
    {
        return;
    }

    NSURL *url          = [NSURL URLWithString:[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSArray *components = [url pathComponents];

#ifdef DEBUG
    NSString *scheme          = url.scheme;
    NSString *host            = url.host;
    NSString *parameterString = url.parameterString;
#endif

    _isPathCacheChanged = YES;

    isChanged = [self __handleModalWithURL:url];

    if (isChanged)
    {
        // todo 处理modal的情况
    }

    isChanged = [self __handleWindowWithURL:url];

    if (isChanged)
    {
        // todo 处理window.rootViewController改变的情况
    }

    UINavigationController *nvc;
    if (![_delegate respondsToSelector:@selector(xyRouter:navigationControllerFromController:toController:URL:)])
    {
        nvc = [[self class] __expectedVisibleNavigationController];
    }
    else
    {
        // 处理 自定义navigationController的
        nvc = [_delegate xyRouter:self
               navigationControllerFromController:nil
                                     toController:nil
                                              URL:URLString];
    }

    // 先看需求pop一些vc
    [self __handlePopViewControllerByComponents:components
                         atNavigationController:nvc];

    // 多个路径先无动画push中间的vc
    if (components.count > 1)
    {
        NSInteger start = [self lastSameComponentWithComponents:components
                                                viewControllers:nvc.viewControllers] + 1;
        for (NSInteger i = start; i < components.count - 1; i++)
        {
            if ([components[i]
                 isEqualToString:@"."] || [components[i]
                                           isEqualToString:@".."])
            {
                continue;
            }

            UIViewController *vc = [self viewControllerForKey:components[i]];
            [self __pushViewController:vc
                            parameters:nil
                atNavigationController:nvc
                              animated:NO];
        }
    }

    // 最后在push最后的vc
    UIViewController *vc     = [self viewControllerForKey:[components lastObject]];
    NSDictionary *parameters = [self __dictionaryFromQuery:url.query];

    if (vc != nil)
    {
        [self __pushViewController:vc
                        parameters:parameters
            atNavigationController:nvc
                          animated:YES];
        return;
    }


    // 处理有锚点的
    NSArray *array = [[components lastObject] componentsSeparatedByString:@"#"];
    if (array.count == 2)
    {
        NSArray *list = [array[1]
                         componentsSeparatedByString:@","];
        if (list.count < 1)
        {
            return;
        }

        NSArray *argument = list.count > 1 ? [list subarrayWithRange:NSMakeRange(1, list.count - 1)] : nil;

        vc = [self __viewControllerForKey:array[0]
                                   anchor:list[0]
                                 argument:argument];
        [self __pushViewController:vc
                        parameters:nil
            atNavigationController:nvc
                          animated:YES];
        return;
    }
}

#pragma mark - private
- (XYRouteType)routeTypeByComponent:(NSString *)component
{
    if ([@"." isEqualToString:component])
    {
        return XYRouteURLType_push;
    }
    else if ([@".." isEqualToString:component])
    {
        return XYRouteURLType_pushAfterPop;
    }
    else if ([@"/" isEqualToString:component])
    {
        return XYRouteURLType_pushAfterGotoRoot;
    }

    return XYRouteURLType_push;
}

+ (UINavigationController *)__expectedVisibleNavigationController
{
    UIViewController *vc        = [self __visibleViewControllerWithRootViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
    UINavigationController *nvc = (UINavigationController *)([vc isKindOfClass:[UINavigationController class]] ? vc : vc.navigationController);

    return nvc;
}

+ (UIViewController *)__visibleViewController
{
    UIViewController *vc = [self __visibleViewControllerWithRootViewController:[UIApplication sharedApplication].delegate.window.rootViewController];

    return vc;
}

+ (UIViewController *)__visibleViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tbc = (UITabBarController *)rootViewController;
        return [self __visibleViewControllerWithRootViewController:tbc.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nvc = (UINavigationController *)rootViewController;
        return [self __visibleViewControllerWithRootViewController:nvc.visibleViewController];
    }
    else if (rootViewController.presentedViewController)
    {
        UIViewController *presentedVC = rootViewController.presentedViewController;
        return [self __visibleViewControllerWithRootViewController:presentedVC];
    }
    else
    {
        return rootViewController;
    }
}

// 处理host改变的情况
- (BOOL)__handleWindowWithURL:(NSURL *)URL
{
    NSString *scheme = URL.scheme;
    NSString *host   = URL.host;

    if (![@"window" isEqualToString:scheme] || host.length == 0)
    {
        return NO;
    }


    UIViewController *vc = [self viewControllerForKey:host];
    NSArray *components  = [URL pathComponents];
    if (components.count < 2)
    {
        NSDictionary *queryDictonary = [self __dictionaryFromQuery:URL.query];
        [queryDictonary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            // todo 安全性检查
            [vc setValue:obj
                  forKey:key];
        }];
    }
    self.rootViewController = vc;

    return YES;
}

// 处理dismiss模态视图
- (BOOL)__handleDismissWithURLString:(NSString *)URLString
{
    if (![@"dismiss" isEqualToString:URLString])
    {
        return NO;
    }

    [self.rootViewController
     dismissViewControllerAnimated:YES
                        completion:nil];

    return YES;
}

// 处理模态视图
- (BOOL)__handleModalWithURL:(NSURL *)URL
{
    NSString *scheme = URL.scheme;
    NSString *host   = URL.host;

    if (![@"modal" isEqualToString:scheme] || host.length == 0)
    {
        return NO;
    }

    UIViewController *vc = [self viewControllerForKey:host];
    NSArray *components  = [URL pathComponents];
    BOOL animated        = NO;

    if (components.count < 2)
    {
        NSDictionary *queryDictonary = [self __dictionaryFromQuery:URL.query];
        [queryDictonary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            // todo 安全性检查
            [vc setValue:obj
                  forKey:key];
        }];
        animated = YES;
    }

    [self.rootViewController
     presentViewController:vc
                  animated:animated
                completion:nil];

    return YES;
}

// 先看需求pop一些vc
- (void)__handlePopViewControllerByComponents:(NSArray *)components atNavigationController:(UINavigationController *)navigationController
{
    XYRouteType type = [self routeTypeByComponent:[components firstObject]];
    BOOL animated    = NO;
    if (components.count == 1 &&
        ([components[0]
          isEqualToString:@".."] || [components[0]
                                     isEqualToString:@"/"]))
    {
        animated = YES;
    }

    if (type == XYRouteURLType_push)
    {
    }
    else if (type == XYRouteURLType_pushAfterPop)
    {
        [navigationController popViewControllerAnimated:animated];
    }
    else if (type == XYRouteURLType_pushAfterGotoRoot)
    {
        NSInteger last = [self lastSameComponentWithComponents:components
                                               viewControllers:navigationController.viewControllers];
        UIViewController *vc = navigationController.viewControllers[last];
        [navigationController popToViewController:vc
                                         animated:animated];
    }
}

- (NSInteger)lastSameComponentWithComponents:(NSArray *)components viewControllers:(NSArray *)vcs
{
    NSInteger max = MIN(components.count, vcs.count);

    NSInteger result = 0;
    for (NSInteger i = 1; i < max; i++)
    {
        if (![components[i]
              isEqualToString:[vcs[i] uxy_URLPath]])
        {
            result = i - 1;
            break;
        }
        result = i;
    }

    return result;
}

- (void)__pushViewController:(UIViewController *)viewController parameters:(NSDictionary *)parameters atNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated
{
    if (viewController == nil || [viewController isKindOfClass:[UINavigationController class]] || navigationController == nil)
    {
        return;
    }

    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // todo 安全性检查
        @try {
            
            [viewController setValue:obj
                              forKey:key];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }];

    [navigationController pushViewController:viewController
                                    animated:animated];
}

- (NSString *)__URLDecodingWithEncodingString:(NSString *)encodingString
{
    NSMutableString *string = [NSMutableString stringWithString:encodingString];
    [string replaceOccurrencesOfString:@"+"
                            withString:@" "
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)__dictionaryFromQuery:(NSString *)query
{
    NSMutableDictionary *result = [@{} mutableCopy];
    NSArray *array              = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePairString in array)
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2)
        {
            continue;
        }
        if ([keyValuePairArray count] == 2) {
            NSString *key   = [self __URLDecodingWithEncodingString:keyValuePairArray[0]];
            NSString *value = [self __URLDecodingWithEncodingString:keyValuePairArray[1]];
            NSString *newValue = [value jk_urlDecodeUsingEncoding:NSUTF8StringEncoding];
            result[key] = newValue;
        }
        else {
            NSString *key   = [self __URLDecodingWithEncodingString:keyValuePairArray[0]];
            NSString *beReplace = [NSString stringWithFormat:@"%@=", keyValuePairArray[0]];
            NSString *value = [self __URLDecodingWithEncodingString:[keyValuePairString stringByReplacingOccurrencesOfString:beReplace withString:@""]];
           NSString *newValue = [value jk_urlDecodeUsingEncoding:NSUTF8StringEncoding];
            result[key] = newValue;
        }
      
    }

    return result;
}

#pragma mark - getter / setter
- (void)setRootViewController:(UIViewController *)rootViewController
{
    [UIApplication sharedApplication].delegate.window.rootViewController = rootViewController;
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}

- (UIViewController *)rootViewController
{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

@end

#pragma mark -


@implementation UIViewController (XYRouter)

static const char *XYRouter_URLPath = "XY.ViewController.URLPath";
- (NSString *)uxy_URLPath
{
    return objc_getAssociatedObject(self, XYRouter_URLPath);
}

- (void)setUxy_URLPath:(NSString *)uxy_URLPath
{
    objc_setAssociatedObject(self, XYRouter_URLPath, uxy_URLPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark - XYRouter_private


#pragma mark -








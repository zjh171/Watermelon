//
//  MDSRouter.m
//  MDSResidentApp
//
//  Created by jilei on 16/7/6.
//  Copyright © 2016年 medishare.cn. All rights reserved.
//

#import "MDSRouter.h"
#import "XYRouter.h"
@implementation MDSRouter
+ (void)registerAllControllers
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSArray *paths = [bundle pathsForResourcesOfType:@"json" inDirectory:@"."];
    NSData *manifestData            = [[NSString stringWithContentsOfFile:[paths objectAtIndex:0] encoding:NSUTF8StringEncoding error:NULL] dataUsingEncoding:NSUTF8StringEncoding];;
    NSDictionary *manifest          = [NSJSONSerialization JSONObjectWithData:manifestData options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *applicationRoutes = [manifest valueForKeyPath:@"application.routes"];

    [applicationRoutes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[XYRouter sharedInstance] mapKey:key
                    toControllerClassName:obj];
    }];

}
+(void)CreatingMapWithController:(NSString*)mapKey WithControllerClassName:(NSString*)ControllerClassName
{
    [[XYRouter sharedInstance] mapKey:mapKey toControllerClassName:ControllerClassName];
}

+(void)mapKey:(NSString*)Key WithController:(UIViewController*)controller
{
    [[XYRouter sharedInstance] mapKey:Key toControllerInstance:[[[controller class] alloc] init]];
}

+(UIViewController*)getControllerWithMapKey:(NSString*)mapKey
{
   UIViewController *vc = [[XYRouter sharedInstance] viewControllerForKey:mapKey];
    return vc;
}

+(void)mapKey:(NSString*)key toBlock:(MDSRouterBlock)block
{
    [[XYRouter sharedInstance] mapKey:key toBlock:block];
}

+(void)openingPath:(NSString*)urlString{
    
    if ([urlString rangeOfString:@"hybrid://"].location != NSNotFound) {
        NSString *newString = [urlString substringFromIndex:9];
        if ([newString hasPrefix:@"forward"]) {
            NSString *params = [newString substringFromIndex:8];
            
            
            if ([params hasPrefix:@"param"]) {
                NSString *paramsDetail = [params substringFromIndex:6];
                NSDictionary *parmDict = [self __jsonObjectWithString:paramsDetail];
                
                
                NSString *routeDetail = parmDict[@"topage"];
                [[XYRouter sharedInstance] openURLString:routeDetail];
            }

        }
        
        
       [[XYRouter sharedInstance] openURLString:newString];
        return;
    }
    
    
    if ([urlString rangeOfString:@"back://"].location != NSNotFound) {
        NSString *newString = [urlString substringFromIndex:9];
        [[XYRouter sharedInstance] openURLString:newString];
        return;
    }
    
    [[XYRouter sharedInstance] openURLString:urlString];
}




+ (instancetype)__jsonObjectWithString:(NSString *)jsonStr {
    if (jsonStr == nil || (![jsonStr isKindOfClass:[NSString class]])) {
        return nil;
    }
    NSError *error = nil;
    id v = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers
                                             error:&error];
    if (error) {
        NSLog(@"你妹，什么破 json: %@", jsonStr);
        return nil;
    }
    
    return v;
}
@end

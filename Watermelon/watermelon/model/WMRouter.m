//
//  WMRouter.m
//  MDSResidentApp
//
//  Created by jilei on 16/7/6.
//  Copyright © 2016年 medishare.cn. All rights reserved.
//

#import "WMRouter.h"
#import "WMXYRouter.h"
#import "Watermelon.h"

@implementation WMRouter

+ (void)registerAllControllers
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MDSRouting" ofType:@"json"];
    
    NSData *manifestData            = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL] dataUsingEncoding:NSUTF8StringEncoding];;
    NSDictionary *manifest          = [NSJSONSerialization JSONObjectWithData:manifestData options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *applicationRoutes = [manifest valueForKeyPath:@"application.routes"];
    //    NSString *applicationMain       = [manifest valueForKeyPath:@"application.main"];
    //    NSLog(@"%@", applicationRoutes);
    [applicationRoutes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[WMXYRouter sharedInstance] mapKey:key
                      toControllerClassName:obj];
    }];
    
}

+(void)openingPath:(NSString*)urlString{
    
    if ([urlString rangeOfString:@"router://"].location != NSNotFound) {
        NSString *newString = [urlString substringFromIndex:9];
        
        NSString *baseUrl = HOST;
        if (baseUrl && ![newString containsString:@"url=http"]) {
            if ([newString containsString:@"undefined"]) {
                newString = [newString stringByReplacingOccurrencesOfString:@"undefined" withString:baseUrl];
            } else{
                NSString *hostString = [NSString stringWithFormat:@"url=%@",baseUrl];
                newString = [newString stringByReplacingOccurrencesOfString:@"url=" withString:hostString];
            }
        }else{
            //do nothing
        }
        
        [[WMXYRouter sharedInstance] openURLString:newString];
        return;
    }
    
    [[WMXYRouter sharedInstance] openURLString:urlString];
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

//
//  Watermelon.m
//  Watermelon
//
//  Created by zhujinhui on 17/3/7.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "Watermelon.h"
#import "WMRouter.h"

#import "OHHTTPStubs.h"
#import "SSZipArchive.h"
#import "AFURLSessionManager.h"
#import "MGNetworkAccess.h"

@interface Watermelon () {
    
}

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,copy) NSString *suggestedFilename;

@property (nonatomic, strong ) NSMutableDictionary *urlHashMap;


@end

@implementation Watermelon



+(Watermelon *) shareInstance{
    static Watermelon *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance -> _urlHashMap = [[NSMutableDictionary alloc] init];
        
    });
    
    return sharedInstance;
}



+(void) registeWatermelonService{
    //[WMURLProtocol start];
    [[self shareInstance] installHtmlStubs];
    [WMRouter registerAllControllers];
}

- (void)installHtmlStubs {
    static id<OHHTTPStubsDescriptor> textStub = nil;
    __block NSMutableDictionary *interuptedRequest = [[NSMutableDictionary alloc] init];
    
    textStub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        // This stub will only configure stub requests for "*.txt" files
        //return [request.URL.pathExtension isEqualToString:@"txt"];
        NSString *urlString = request.URL.absoluteString;
        NSString *pathExtension = request.URL.pathExtension.lowercaseString;
        
        //这里做个判断，如果是打开新页面就做过滤处理，其他情况不做过滤处理，这是因为ios本身的bug
        if ([urlString hasPrefix:@"hybrid://"]) {
            
            if ([urlString.lowercaseString hasPrefix:@"hybrid://opennewpage"]) {
                //这里做个判断，如果被点击过就不点击了，不点击过就点击，
                if (interuptedRequest[urlString]) {
                    
                    
                }else {
                    NSString *urlString1 = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [self performSelectorOnMainThread:@selector(postNotification:) withObject:urlString1 waitUntilDone:YES];
#define INTERUPT_TIME 5
                    //这里要清一次字典
                    if (interuptedRequest.allKeys.count >= INTERUPT_TIME) {
                        [interuptedRequest removeAllObjects];
                    }
                }
                interuptedRequest[urlString] = @YES;
                return NO;
                
            }else {
                return YES;
            }
            
        }
        
        
        //        if ([urlString hasPrefix:@"https://"] && ![request.URL.pathExtension isEqualToString:@"json"] && ![request.URL.pathExtension isEqualToString:@"jpg"] && ![request.URL.pathExtension isEqualToString:@"png"] ) {
        //            return YES;
        //        }
        
        if ([urlString hasPrefix:@"file://"]) {
            NSString *urlStringWithNoScheme = [urlString substringFromIndex:7];
            NSURL *filePathUrl = [NSURL URLWithString:urlStringWithNoScheme];
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePathUrl.path];
            
            if (fileExists) {
                return NO;
            }else {
                NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                if (!self.suggestedFilename) {
                    self.suggestedFilename = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Watermelon.response.suggestedFilename"];
                }else{
                    //do nothign
                }
                
                if(self.suggestedFilename) {
                    NSString *path = [cachesPath stringByAppendingPathComponent:self.suggestedFilename];
                    NSString *lastPath = [path stringByDeletingPathExtension];
                    NSString *detailPath = [lastPath stringByAppendingString:urlStringWithNoScheme];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:detailPath];
                    if (fileExists) {
                        self.urlHashMap[urlString] = detailPath;
                    }else {
                        //do nothing
                        NSLog(@"url:%@ has not source ",urlString);
                        //self.urlHashMap[urlString] = [NSString stringWithFormat:@"%@/%@",HOST,urlStringWithNoScheme];
                    }
                    
                } else {
                    //do nothign
                }
                return YES;
            }
            
            
        }
        
        return NO;
        //return nil;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSString *urlString = request.URL.absoluteString;
        
        NSString *pathExtension = request.URL.pathExtension.lowercaseString;
        
        if ([urlString hasPrefix:@"hybrid://"]) {
            //[WMRouter openingPath:urlString1];
            NSString *urlString1 = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self performSelectorOnMainThread:@selector(postNotification:) withObject:urlString1 waitUntilDone:YES];
            
            return nil;
        }else if ([urlString hasPrefix:@"file://"]) {
            
            if (self.urlHashMap[urlString]) {
                NSData *data = [NSData dataWithContentsOfFile:self.urlHashMap[urlString]];
                OHHTTPStubsResponse *response2 = [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:request.allHTTPHeaderFields];
                return response2;
            }else {
                NSString *urlStringWithNoScheme = [urlString substringFromIndex:7];
                NSString *urlStringWithHost = [NSString stringWithFormat:@"%@/%@",HOST,urlStringWithNoScheme];
                
                NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[dat timeIntervalSince1970]];
                if ([urlStringWithHost containsString:@"?"]) {
                    urlStringWithHost = [urlStringWithHost stringByAppendingFormat:@"&timestamp_web=%@",timestamp] ;
                }else {
                    urlStringWithHost = [urlStringWithHost stringByAppendingFormat:@"?timestamp_web=%@",timestamp] ;
                }
                NSMutableURLRequest *redirectedRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStringWithHost]];
                redirectedRequest.HTTPMethod = request.HTTPMethod;
                redirectedRequest.HTTPBodyStream = request.HTTPBodyStream;
                redirectedRequest.HTTPBody = request.HTTPBody;
                NSString *shimDataString = [request valueForHTTPHeaderField:@"Shim-Data"];
                NSString *decodedShimDataString =  [shimDataString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSData *shimData = [decodedShimDataString dataUsingEncoding:NSUTF8StringEncoding];
                redirectedRequest.HTTPBody = shimData;
                NSMutableDictionary *allHttpHeaderAndFields = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
                [allHttpHeaderAndFields removeObjectForKey:@"Shim-Data"];
                [allHttpHeaderAndFields removeObjectForKey:@"X-Medishare-Engine"];
                
                redirectedRequest.allHTTPHeaderFields = allHttpHeaderAndFields;
                redirectedRequest.cachePolicy =  NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
                
                MGNetworkAccess *networkAccess = [[MGNetworkAccess alloc] initWithHost:HOST modulePath:nil];
                networkAccess.requestType = RequestTypeNone;
                networkAccess.request = redirectedRequest;
                MGNetwokResponse *response = [networkAccess doHttpRequest:urlStringWithNoScheme params:nil];
                NSData *data = [response.rawJson dataUsingEncoding:NSUTF8StringEncoding];
                OHHTTPStubsResponse *response2 = [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:request.allHTTPHeaderFields];
                return response2;
                
            }
            
            return nil;
        }
        /*else if ([urlString hasPrefix:@"https://"]) {
         
         NSMutableURLRequest *redirectedRequest = [NSMutableURLRequest requestWithURL:request.URL];
         redirectedRequest.HTTPMethod = request.HTTPMethod;
         redirectedRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
         redirectedRequest.HTTPBodyStream = request.HTTPBodyStream;
         redirectedRequest.HTTPBody = request.HTTPBody;
         
         MGNetworkAccess *networkAccess = [[MGNetworkAccess alloc] initWithHost:HOST modulePath:nil];
         networkAccess.requestType = RequestTypeNone;
         networkAccess.request = redirectedRequest;
         MGNetwokResponse *response = [networkAccess doHttpRequest:urlString params:nil];
         NSData *data = [response.rawJson dataUsingEncoding:NSUTF8StringEncoding];
         OHHTTPStubsResponse *response2 = [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:request.allHTTPHeaderFields];
         return response2;
         
         }*/
        else {
            
            return nil;
        }
    }];
    
    //[OHHTTPStubs removeStub:textStub];
    
}



- (UIViewController *)currentViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc visibleViewController];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        vc = [(UITabBarController *)vc selectedViewController];
    }
    return vc;
}

-(void)postNotification:(NSString *) urlString1{
    NSString *notificationName = [NSString stringWithFormat:@"%@.%@",WatermelonNotificationUpdateUIHeader,self.currentViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:urlString1];
    
}


-(void)downloadWebAppWithUrl:(NSString *) webAppUrlString downloadFinished:(WatermelonDownloadFinished) finished{
    
    //远程地址
    NSURL *URL = [NSURL URLWithString:webAppUrlString];
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName=NO;
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //下载Task操作
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // @property int64_t totalUnitCount;     需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
        
        // 给Progress添加监听 KVO
        NSLog(@"+++++%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        // 回到主队列刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // 设置进度条的百分比
            
            
            
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *path = [documentDirectory stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //设置下载完成操作
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        NSString *filePathString = [filePath path];
        NSString *lastPath = [filePathString stringByDeletingPathExtension];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:lastPath error:nil];
        
        NSError *createError = nil;
        
        if ([fileManager createDirectoryAtPath:lastPath withIntermediateDirectories:NO attributes:nil error:&createError] !=  YES) {
            NSLog(@"创建失败");
        }else {
            NSLog(@"创建成功");
        }
        
        
        BOOL zipSuccess = [SSZipArchive unzipFileAtPath:filePathString toDestination:lastPath];
        if (zipSuccess) {
            NSLog(@"解压成功");
            NSDictionary *packageNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Watermelon.packages.names"];
            if ([packageNames isKindOfClass:[NSDictionary class]] || !packageNames) {
                NSMutableDictionary *localPackageNames = [NSMutableDictionary dictionaryWithDictionary:packageNames];
                localPackageNames[request.URL.absoluteString] = response.suggestedFilename;
                
                [[NSUserDefaults standardUserDefaults] setValue:localPackageNames forKey:@"com.Watermelon.packages.names"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else {
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"com.Watermelon.packages.names"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            
            
            finished(webAppUrlString);
        }else{
            NSLog(@"解压失败");
            [fileManager removeItemAtPath:lastPath error:nil];
            NSError *removeError = nil ;
            [fileManager removeItemAtPath:filePathString error:&removeError];
            if (removeError) {
                NSLog(@"移除失败");
            }
        }
        
        
    }];
    
    //开始下载
    [_downloadTask resume];
    
}

-(NSString *)suggestedFilename {
    if (!_suggestedFilename) {
        _suggestedFilename = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Watermelon.response.suggestedFilename"];
    }
    return _suggestedFilename;
}

-(void)setPackageNameWithURL:(NSString *) urlString {
    NSDictionary *allPackageNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.Watermelon.packages.names"];
    if ([allPackageNames isKindOfClass:[NSDictionary class]]) {
        NSString *packageName = allPackageNames[urlString];
        if (packageName) {
            [[NSUserDefaults standardUserDefaults] setValue:packageName forKey:@"com.Watermelon.response.suggestedFilename"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

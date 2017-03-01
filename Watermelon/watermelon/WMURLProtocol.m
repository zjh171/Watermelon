//
//  WMURLProtocol.m
//  Watermelon
//
//  Created by zhujinhui on 17/2/28.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMURLProtocol.h"
#import "WMActionManager.h"
#import "MDSRouter.h"

static NSString *URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface WMURLProtocol ()<NSURLSessionDelegate>{

}

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WMURLProtocol

+ (void)start {

    [NSURLProtocol registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    //看看是否已经处理过了，防止无限循环
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    
    return YES;
}




+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}


- (void)startLoading {
    NSMutableURLRequest * request = [self.request mutableCopy];
    
    // 标记当前传入的Request已经被拦截处理过，防止在最开始又继续拦截处理
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:request];
    
    //使用NSURLSession继续把重定向的request发送出去
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:mainQueue];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[self changeSinaToSohu:request]];
    
    [task resume];
}

- (void)stopLoading {
//    [self.connection cancel];
//    self.connection = nil;
}




//把所用url中包括sina的url重定向到sohu
- (NSMutableURLRequest *)changeSinaToSohu:(NSMutableURLRequest *)request{
    NSString *urlString = request.URL.absoluteString;
    if ([urlString isEqualToString:@"https://www.baidu.com/"]) {
        urlString = @"https://m.sohu.com/";
        request.URL = [NSURL URLWithString:urlString];
    }
    
    NSString *urlString1 = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if ([urlString hasPrefix:@"hybrid://forward"]) {
        [MDSRouter openingPath:urlString1];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"1" object:urlString1];
    }
    
    return request;
}




/*
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

*/

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(proposedResponse);
}


@end

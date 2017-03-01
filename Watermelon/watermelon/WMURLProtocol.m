//
//  WMURLProtocol.m
//  Watermelon
//
//  Created by zhujinhui on 17/2/28.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMURLProtocol.h"


static NSString *URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface WMURLProtocol ()

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation WMURLProtocol



+ (void)start {

    [NSURLProtocol registerClass:self];
}


/**
+ (void)setDelegate:(id<CustomHTTPProtocolDelegate>)newValue {
    @synchronized (self) {
        sDelegate = newValue;
    }
}


*/


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    //看看是否已经处理过了，防止无限循环
    if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    
    NSString *scheme = [[request URL] scheme];
    NSDictionary *dict = [request allHTTPHeaderFields];
    
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
    
    // 标记当前传入的Request已经被拦截处理过，
    //防止在最开始又继续拦截处理
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:request];
    
    self.connection = [NSURLConnection connectionWithRequest:[self changeSinaToSohu:request] delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}




//把所用url中包括sina的url重定向到sohu
- (NSMutableURLRequest *)changeSinaToSohu:(NSMutableURLRequest *)request{
    NSString *urlString = request.URL.absoluteString;
    if ([urlString isEqualToString:@"https://www.baidu.com/"]) {
        urlString = @"https://m.sohu.com/";
        request.URL = [NSURL URLWithString:urlString];
    }
    
    if ([urlString hasPrefix:@"hybrid"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"1" object:nil];
        
    }
    
    return request;
}





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


@end

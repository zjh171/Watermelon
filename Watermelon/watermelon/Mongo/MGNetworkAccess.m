//
//  MGNetworkAccess.m
//  Angejia
//
//  Created by kyson on 15/11/26.
//  Copyright © 2015年 Plan B Inc. All rights reserved.
//

#import "MGNetworkAccess.h"
#import "MGMockAccess.h"
#import "MGJsonHandler.h"

@implementation MGUrlReplacementField

+(MGUrlReplacementField *) fieldWithOrigin:(NSString *)origin :(NSString *)replace :(NSString *)relatedParamKey{
    MGUrlReplacementField *field = [[MGUrlReplacementField alloc] init];
    field.originField = origin;
    field.replaceField = replace;
    field.relatedParamKey = relatedParamKey;
    return field;
}

@end

@interface MGNetworkAccess ()<NSURLSessionDelegate>{
    
    dispatch_semaphore_t semaphore;
}

@property (nonatomic , assign) BOOL isMockAccess;

@property (nonatomic, strong) NSError *mError;
@property (nonatomic, strong) NSURLResponse *mURLResponse;
@property (strong, nonatomic) NSMutableData *mResponseData;

@end


@implementation MGNetworkAccess



-(instancetype)initWithHost:(NSString *) host modulePath:(NSString *)path{
    if (self = [super init]) {
        self.host = host;
        self.modulePath = path;
        
        /**
         * Judge if it is mock access
         */
        if ([_host isEqualToString:HOST_MOCK] ) {
            self.isMockAccess = YES;
        }else{
            self.isMockAccess = NO;
        }
        
        semaphore = dispatch_semaphore_create(0);
        
    }
    return self;
}

-(NSMutableURLRequest *)generateHttpRequest:(NSString *)requestUrlString params:(NSDictionary *) params{
    if (nil == _host) {
        return nil;
    }
    
    if (self.modulePath) {
        requestUrlString = [NSString stringWithFormat:@"/%@%@",self.modulePath,requestUrlString];
    }else{
        requestUrlString = [NSString stringWithFormat:@"/%@",requestUrlString];
    }
    
    //    if (![_host hasPrefix:@"http://"]) {
    //        _host = [NSString stringWithFormat:@"http://%@",_host];
    //    }
    
    requestUrlString = [_host stringByAppendingString:requestUrlString];
    
    return [self generateRequestWithParams:params requestUrl:requestUrlString];
}

-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *) params replaceUrlWith:(NSArray<MGUrlReplacementField *> *)replacements{
    //service name
    if (self.isMockAccess) {
        MGMockAccess *mock = [[MGMockAccess alloc]init];
        return [mock doHttpRequestWithJsonFileNamed:self.localJsonName];
    }
    
    NSMutableString *requestUrl = [[NSMutableString alloc] initWithString:requestUrlString];
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
    NSLog(@"requestUrl原地址：%@",requestUrl);
    for (MGUrlReplacementField *replacementItem in replacements) {
        NSLog(@"requestUrl将要替换的字段：%@,替换成%@",replacementItem.originField,replacementItem.replaceField);
        [requestUrl replaceOccurrencesOfString:replacementItem.originField withString:replacementItem.replaceField options:NSCaseInsensitiveSearch range:NSMakeRange(0, requestUrl.length)];
        NSLog(@"requestUrl替换后变成了%@",requestUrl);
        [requestParams removeObjectForKey:replacementItem.relatedParamKey];
    }
    
    return [self doHttpRequest:requestUrl params:requestParams];
}

/**
 
 HTTP Header:
 {
 "Angejia-CamelCase" = 1;
 "Angejia-MobileAgent" = "app=i-angejia;av=2.5;ccid=1;gcid=1;ch=A01;lng=121.388305;lat=31.172144;ip=192.168.163.103;mac=None;net=WIFI;p=iOS;pm=iPhone 5s;osv=8.3;dvid=F40A6BE3-4EFD-4AF4-97C7-201601121500;idfa=E3A03BD4-ACA1-482A-941E-F01575D7E866";
 "Angejia-Payload" = "2.0";
 "Angejia-Signature" = d37dac11fca5118bb79cbafad92ab6d27fb40b858b1eae23ea1814d8cf91ff18;
 "Angejia-Stringify" = 1;
 "Angejia-auth" = "GUQjGX4hJPiHo3NYLDOfhUR/tVFevSCy4iJGm9wAfBx10px0u/fPKwB44yRIIOm5/lPaKivioOhkoUpICyOWl+tJiEWX+JMTAb3ikKUao+tQAaTeD0t1Cr4L3aiyYRAT4DeIlFFd/Xa07zNeT4ct7NRtqKv0K6aaZ/WBa2BEWYayD4Myafsz/sAFJANUcc5SQr8V1FFNh260gO8LYC7nsQ==";
 cid = 9e588e69b2d2b43a472b60fd00f2a6cb;
 token = "GUQjGX4hJPiHo3NYLDOfhUR/tVFevSCy4iJGm9wAfBx10px0u/fPKwB44yRIIOm5/lPaKivioOhkoUpICyOWl+tJiEWX+JMTAb3ikKUao+tQAaTeD0t1Cr4L3aiyYRAT4DeIlFFd/Xa07zNeT4ct7NRtqKv0K6aaZ/WBa2BEWYayD4Myafsz/sAFJANUcc5SQr8V1FFNh260gO8LYC7nsQ==";
 }
 
 **/

-(NSMutableURLRequest *)generateRequestWithParams:(NSDictionary *)params requestUrl:(NSString *) requestUrlString{
    
    NSMutableURLRequest *request2 = nil;
    switch (self.requestType) {
        case RequestTypeNone: {
            request2 = [NSMutableURLRequest requestWithURL:self.request.URL];
            request2.HTTPMethod = self.request.HTTPMethod;
            request2.allHTTPHeaderFields = self.request.allHTTPHeaderFields;
            request2.HTTPBodyStream = self.request.HTTPBodyStream;
            request2.HTTPBody = self.request.HTTPBody;
            request2.cachePolicy = self.request.cachePolicy;
        }
        break;
        case RequestTypeGet:{
            if (params.allKeys.count > 0) {
                //先判断url中是否已经带参数，也就是"？"在URL中有没有出现过,如果出现过那就直接追加新的参数，并以"&"开头，否则就添加"？"
                if ([requestUrlString rangeOfString:@"?"].location == NSNotFound) {
                    requestUrlString = [requestUrlString stringByAppendingString:@"?"];
                }else{
                    requestUrlString = [requestUrlString stringByAppendingString:@"&"];
                }
                
                for (NSInteger index = 0; index < params.allKeys.count; ++ index) {
                    NSString *paramsKey = params.allKeys[index];
                    requestUrlString = [requestUrlString stringByAppendingFormat:@"%@=%@",paramsKey,params[paramsKey]];
                    if (index != params.allKeys.count - 1) {
                        requestUrlString = [requestUrlString stringByAppendingString:@"&"];
                    }
                }
            }else{
                NSLog(@"there is no params");
            }
            requestUrlString = [requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            request2 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:requestUrlString]];
            [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        }
        break;
        
        case RequestTypePost:{
            request2 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:requestUrlString]];
#define REQUESTMETHOD_POST @"POST"
            [request2 setHTTPMethod:REQUESTMETHOD_POST ];
            [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            
            //set http post body
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc]initWithDictionary:params];
            NSInteger keyCount = [[tempDictionary allKeys] count];
            NSMutableString *string = [[NSMutableString alloc]init];
            NSArray *arrKey = [tempDictionary allKeys];
            for (int i = 0 ; i < keyCount; ++i) {
                NSString *key = [arrKey objectAtIndex:i];
                NSString *value = [params objectForKey:key];
                if (0 == i) {
                    [string appendFormat:@"%@=%@",key,value];
                }else{
                    [string appendFormat:@"&%@=%@",key,value];
                }
            }
            NSLog(@"kyson:%@:post data:%@",self,string);
            NSData *bodyData = [string dataUsingEncoding:NSUTF8StringEncoding];
            [request2 setHTTPBody:bodyData];
        }
        break;
        case RequestTypePostJson:{
            request2 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:requestUrlString]];
            [request2 setHTTPMethod:@"POST"];
            [request2 setValue:@"application/json" forHTTPHeaderField:@"content-type"];
            
            if(params){
                NSError *parserError= nil;
                NSData *jsonData = nil;
                @try {
                    jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&parserError];
                    [request2 setHTTPBody:jsonData];
                }
                @catch (NSException *exception) {
                    NSAssert(1!=1, @"json parse wrong!");
                    NSLog(@"%@:kyson exception :%@",self,exception);
                }
                NSLog(@"kyson:%@:%@",self,requestUrlString);
            }else{
                NSLog(@"No params");
            }
            
            
        }
        break;
        
        default:
        break;
    }
    //set header
    for (NSString *keyItem in [self.protocolHandler defaultHttpHeaders].allKeys) {
        [request2 setValue:[self.protocolHandler defaultHttpHeaders][keyItem] forHTTPHeaderField:keyItem];
    }
    
    if ([self.protocolHandler additionHttpHeaders]) {
        for (NSString *keyItem in [self.protocolHandler additionHttpHeaders].allKeys) {
            [request2 setValue:[self.protocolHandler additionHttpHeaders][keyItem] forHTTPHeaderField:keyItem];
        }
    }else{
        //no addtion
    }
    
    request2.timeoutInterval = TIMEOUT_INTERVAL;
    // use any cache
    //request2.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    return request2;
    
}


/*
 * http请求(url 中有需要替换的字段,参数不仅仅是字典，也有可能是数组,参数里也有需要替换的字段)
 */
-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *)params extendToJsonParams:(id) extParams replaceUrlWith:(NSArray<MGUrlReplacementField *> *)replacements{
    
    if(self.requestType == RequestTypePostJson){
        //service name
        if (self.isMockAccess) {
            MGMockAccess *mock = [[MGMockAccess alloc]init];
            return [mock doHttpRequestWithJsonFileNamed:self.localJsonName];
        }
        
        NSMutableString *requestUrl = [[NSMutableString alloc] initWithString:requestUrlString];
        NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
        NSLog(@"requestUrl原地址：%@",requestUrl);
        for (MGUrlReplacementField *replacementItem in replacements) {
            NSLog(@"requestUrl将要替换的字段：%@,替换成%@",replacementItem.originField,replacementItem.replaceField);
            [requestUrl replaceOccurrencesOfString:replacementItem.originField withString:replacementItem.replaceField options:NSCaseInsensitiveSearch range:NSMakeRange(0, requestUrl.length)];
            NSLog(@"requestUrl替换后变成了%@",requestUrl);
            [requestParams removeObjectForKey:replacementItem.relatedParamKey];
        }
        return [self doHttpRequest:requestUrl params:extParams];
    }
    return nil;
}


-(NSMutableURLRequest *)commonHandleOfRequestString:(NSString *) urlString{
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    request2.timeoutInterval = TIMEOUT_INTERVAL;
    // use any cache
    request2.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    return request2;
}


-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *)params{
    NSMutableURLRequest *request = nil;
    /**
     * Judge if it is mock access
     */
    if ([_host isEqualToString:HOST_MOCK] ) {
        MGMockAccess *mock = [[MGMockAccess alloc]init];
        return [mock doHttpRequestWithJsonFileNamed:self.localJsonName];
    }
    request = [self generateHttpRequest:requestUrlString params:params];
    MGNetwokResponse *response = [self doHttpRequestAndGetResponse:request];
    return response;
}



-(MGNetwokResponse *)doHttpRequestAndGetResponse:(NSURLRequest *)request {
    //show the network activity indicator
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *inProcessSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [inProcessSession dataTaskWithRequest:request];
    [dataTask resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    ////请求结束后，获得结束的信号，以下代码开始对结果进行处理
    
    NSString *receivedString = [[NSString alloc] initWithData:self.mResponseData encoding:NSUTF8StringEncoding];
    MGNetwokResponse *tempResponse = [[MGNetwokResponse alloc] init];
    tempResponse.rawJson = receivedString;
    
    NSError *tempError = self.mError;
    if (tempError) {
        if (NSURLErrorCannotConnectToHost == tempError.code ) {
            tempResponse.errorMessage = @"连接服务器失败，请稍后再试";
            tempResponse.errorCode = NSURLErrorCannotConnectToHost;
        }else if (NSURLErrorTimedOut == tempError.code){
            tempResponse.errorMessage = @"超时，请稍后再试";
            tempResponse.errorCode = NSURLErrorTimedOut;
        }else if(NSURLErrorNotConnectedToInternet == tempError.code){
            tempResponse.errorCode = NSURLErrorNotConnectedToInternet;
            tempResponse.errorMessage = @"当前网络不可用，请检查网络";
        }else{
            //do nothing
            //            response.errorCode = 89898989;
            //            response.errorMessage = @"服务器被连接失败";
        }
        NSLog(@"error : %@",tempError.description);
    }else{
        if ([self.mURLResponse isMemberOfClass:[NSHTTPURLResponse class]]) {
            tempResponse.statusCode = ((NSHTTPURLResponse *)self.mURLResponse).statusCode;
        }else{
            //do nothing
        }
        
        [MGJsonHandler convertToErrorResponse:&tempResponse];
        
        
        NSLog(@"\n###########\n request url:%@\n ###########\n http header:%@ \n ###########\n HTTPBody:%@ \n result:%@ \n ###########\n error code :%li",request.URL.absoluteString,request.allHTTPHeaderFields,[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding],tempResponse.rawJson,(long)tempResponse.errorCode);
    }
    [inProcessSession finishTasksAndInvalidate];
    
    return tempResponse;
}



- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSString *method = challenge.protectionSpace.authenticationMethod;
    NSLog(@"%@", method);
    
    if([method isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        NSString *host = challenge.protectionSpace.host;
        NSLog(@"%@", host);
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        return;
    }
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(PKCS12Data);
    SecIdentityRef identity;
    
    // 读取p12证书中的内容
    OSStatus result = [self extractP12Data:inPKCS12Data toIdentity:&identity];
    if(result != errSecSuccess){
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }
    
    SecCertificateRef certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    
    const void *certs[] = {certificate};
    CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
    
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(NSArray*)CFBridgingRelease(certArray) persistence:NSURLCredentialPersistencePermanent];
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

-(OSStatus) extractP12Data:(CFDataRef)inP12Data toIdentity:(SecIdentityRef*)identity {
    
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR("the_password");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}


// 接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"didReceiveResponse");
    self.mURLResponse = response;
    
    completionHandler(NSURLSessionResponseAllow);
}
// 接收到服务器返回的数据(可能多次调用)
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    [self.mResponseData appendData:data];
}


// 请求完毕
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"didCompleteWithError");
    self.mError = error;
    
    dispatch_semaphore_signal(semaphore);
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler{
    
}

-(NSMutableData *)mResponseData{
    if (!_mResponseData) {
        _mResponseData = [NSMutableData data];
    }
    
    return _mResponseData;
}

- (void)dealloc {
    
}

@end

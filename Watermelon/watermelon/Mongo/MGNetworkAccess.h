//
//  MGNetworkAccess.h
//  Angejia
//
//  Created by kyson on 15/11/26.
//  Copyright © 2015年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MGNetwokResponse.h"
#import "MGProtocolHandler.h"

#define TIMEOUT_INTERVAL 16.0

typedef enum _RequestType{
    RequestTypePost,
    RequestTypePostMap = RequestTypePost,
    RequestTypePostJson,
    RequestTypeGet,
    RequestTypeNone,
}RequestType;

@interface MGUrlReplacementField : NSObject
/*
 * url 的 原字段
 */
@property (nonatomic, copy) NSString *originField;
/*
 * url 需要替换成的字段
 */
@property (nonatomic, copy) NSString *replaceField;
/*
 * 对应的请求参数的键
 */
@property (nonatomic, copy) NSString *relatedParamKey;

/*
 * 对应的请求参数的键
 */
+(MGUrlReplacementField *) fieldWithOrigin:(NSString *)origin :(NSString *)replace :(NSString *)relatedParamKey;

@end

/**
 * @brief As the name implies,NetworkAccess is used to dealing with network request,now it can dealing with request such as get,post and so on.
 */

@interface MGNetworkAccess : NSObject

#define HOST_MOCK @"HOST_MOCK"


@property (nonatomic,strong) MGProtocolHandler *protocolHandler;

/**
 * 当 RequestType 指定为RequestTypeNone时，可以自己指定request
 */
@property (nonatomic, strong) NSURLRequest *request;
/*
 *服务器主机名
 *
 *
 */

@property (nonatomic, copy) NSString *host;


/*
 * 模块路径
 */
@property (nonatomic, copy) NSString *modulePath;

/*
 * 请求方式
 */
@property (nonatomic, assign) RequestType requestType;

/*
 * 初始化
 */
-(instancetype)initWithHost:(NSString *) host modulePath:(NSString *) path;

/**
 * 本地json，当HOST地址为Mock的时候，可以指明要加载的本地JSON文件
 */
@property (nonatomic, copy) NSString *localJsonName;

/*
 * http请求(url 中有需要替换的字段)
 */
-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *) params replaceUrlWith:(NSArray<MGUrlReplacementField *> *)replacements;


/*
 * http请求(url 中有需要替换的字段,参数不仅仅是字典，也有可能是数组,参数里也有需要替换的字段,extParams 用于转json的参数)
 */
-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *)params extendToJsonParams:(id) extParams replaceUrlWith:(NSArray<MGUrlReplacementField *> *)replacements;

/*
 * http请求
 */
-(MGNetwokResponse *)doHttpRequest:(NSString *)requestUrlString params:(NSDictionary *) params;



@end

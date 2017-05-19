//
//  MGJsonHandler.m
//  Angejia
//
//  Created by kyson on 15/11/26.
//  Copyright © 2015年 Plan B Inc. All rights reserved.
//

#import "MGJsonHandler.h"
#import "MGNetwokResponse.h"


@implementation MGJsonHandler



+(MGNetwokResponse *)convertToErrorResponse:(MGNetwokResponse **)responseAddr{
    MGNetwokResponse *response = (*responseAddr);
    NSString *jsonString = response.rawJson;
    if (!jsonString || jsonString.length == 0) {
        NSLog(@"response raw string is null");
        
        response.errorMessage = SERVICE_RESPONSE_NORESPONSE_DESC;
        return response;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    //judge if the raw json is json,if is not json error will not be nil,then return directly
    if (error) {
        response.errorCode = ERRORCODE_JSONPARSER;
        response.errorMessage = @"服务器异常，请稍后再试";
        return response;
    }
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDictionary = (NSDictionary *) jsonObject;
        if (YES != [jsonDictionary[@"isSuccess"] boolValue]) {
            NSInteger errorcode = [jsonDictionary[@"code"] integerValue];
            response.errorCode = errorcode;
        }else{
            //do nothing
            response.errorCode = ERRORCODE_NOERROR;
        }
        
        if (nil != jsonDictionary[@"errorMsg"]) {
            NSString *errorMessage = jsonDictionary[@"errorMsg"];
            response.errorMessage = errorMessage;
        }else{
            //do nothing
        }
        
        response.rawResponseDictionary = jsonDictionary;
        
        id data = jsonDictionary[@"data"];
        if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]] ) {
            response.responseObject = data;
        }else{
            NSLog(@"error object：%s",__func__);
        }
        
    }else if ([jsonObject isKindOfClass:[NSArray class]]){
        NSArray *objArray = (NSArray *) jsonObject;
        response.rawResponseArray = objArray;
        
    }
    return response;
}


+(MGNetwokResponse *)handleDemandJsonWithResponse:(MGNetwokResponse **)responseAddr{
    return nil;
}


@end

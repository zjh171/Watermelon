//
//  MDSUpdateLoginConfigModel.h
//  Watermelon
//
//  Created by kyson on 2017/3/19.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "MDSModel.h"

@interface MDSUpdateLoginConfigModel : MDSModel


/**
 
 {
 "pushKey":"推送的key",
 "memberId":"医生的memberId",
 "portrait":"头像",
 "doctorType":"1",
 "id":"医生id",
 "tagName":"XXXX",
 "callback":"xxxx_back_随机数"
 }
 
 */


CREATE_STRING_PROPERTY(pushKey)
CREATE_STRING_PROPERTY(memberId)
CREATE_STRING_PROPERTY(portrait)
CREATE_STRING_PROPERTY(doctorType)
CREATE_STRING_PROPERTY(id)
CREATE_STRING_PROPERTY(tagName)
CREATE_STRING_PROPERTY(callback)




@end

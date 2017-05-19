//
//  MDSAlertView.h
//  Watermelon
//
//  Created by zhujinhui on 17/3/15.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "MDSModel.h"
#import "MDSAlertViewButtonModel.h"

@interface MDSAlertViewModel : MDSModel

CREATE_STRING_PROPERTY(title)
CREATE_STRING_PROPERTY(message)
CREATE_STRING_PROPERTY(isCancel)
CREATE_STRING_PROPERTY(isShowFork)


@property (nonatomic, strong) MDSAlertViewButtonModel *left;

@property (nonatomic, strong) MDSAlertViewButtonModel *right;

@end

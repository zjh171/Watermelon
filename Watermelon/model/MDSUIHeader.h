//
//  MDSUIHeader.h
//  Watermelon
//
//  Created by zhujinhui on 17/3/3.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import <MDSModel.h>


#import "MDSNavLeft.h"
#import "MDSNavRight.h"
#import "MDSNavTitle.h"


@interface MDSUIHeader : MDSModel


@property (nonatomic, strong) NSArray<MDSNavLeft*> *left;
@property (nonatomic, strong) NSArray<MDSNavRight *> *right;
@property (nonatomic, strong) MDSNavTitle *title;




@end

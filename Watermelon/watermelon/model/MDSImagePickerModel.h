//
//  MDSImagePickerModel.h
//  Watermelon
//
//  Created by kyson on 2017/3/17.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "MDSModel.h"

@interface MDSImagePickerModel : MDSModel

CREATE_STRING_PROPERTY(sizeType)
CREATE_STRING_PROPERTY(sourceType)
CREATE_STRING_PROPERTY(imageSource)
CREATE_STRING_PROPERTY(extend)
CREATE_STRING_PROPERTY(tagName)
CREATE_STRING_PROPERTY(callback)


@end

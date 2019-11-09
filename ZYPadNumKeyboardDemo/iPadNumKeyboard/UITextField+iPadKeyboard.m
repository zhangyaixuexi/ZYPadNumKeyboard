//
//  UITextField+iPadKeyboard.m
//  iPadNumKeyboard
//
//  Created by zhangyi on 2017/11/4.
//  Copyright © 2017年 Jiri Zachar. All rights reserved.
//

#import "UITextField+iPadKeyboard.h"
#import <objc/runtime.h>
#import "ZYiPadNumkeyboard.h"

#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

@implementation UITextField (iPadKeyboard)

@dynamic padKeyboardType;
static char charKey;

- (void)setPadKeyboardType:(PadKeyboardType)padKeyboardType
{
    if (IS_PAD && padKeyboardType == PadKeyboardTypeNum) {
        self.inputView = [ZYiPadNumkeyboard numkeyboard];
    }
    objc_setAssociatedObject(self, &charKey, @(padKeyboardType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (PadKeyboardType)padKeyboardType
{
    NSNumber * type = objc_getAssociatedObject(self, &charKey);
    if (type.integerValue == 0) {
        return PadKeyboardTypePhone;
    }else if (type.integerValue == 1){
        return PadKeyboardTypeNum;
    }
    return PadKeyboardTypePhone;
}



@end

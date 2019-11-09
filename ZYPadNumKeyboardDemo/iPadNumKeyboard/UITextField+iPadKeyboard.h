//
//  UITextField+iPadKeyboard.h
//  iPadNumKeyboard
//
//  Created by zhangyi on 2017/11/4.
//  Copyright © 2017年 Jiri Zachar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PAD_EDITING_CHANGE @"padEditingChangeNotif"

typedef NS_ENUM(NSInteger,PadKeyboardType){
    PadKeyboardTypePhone = 0,
    PadKeyboardTypeNum
};

@interface UITextField (iPadKeyboard)

@property (nonatomic, assign) PadKeyboardType  padKeyboardType;

@end

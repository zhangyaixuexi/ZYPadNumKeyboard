//
//  ZYiPadNumkeyboard.m
//  iPadNumKeyboard
//
//  Created by zhangyi on 2017/11/3.
//  Copyright © 2017年 Jiri Zachar. All rights reserved.
//

#import "ZYiPadNumkeyboard.h"
#import "UITextField+iPadKeyboard.h"

/* 系统控件常量 */
#define KEY_H       280
#define KEY_W       [UIScreen mainScreen].bounds.size.width

#define SCR_H       [UIScreen mainScreen].bounds.size.height
#define KEY_BOR_H   (KEY_H + 60)

#define KEY_COR_BG  [UIColor colorWithRed:210/255.0 green:212/255.0 blue:220/255.0 alpha:1/1.0]
#define KEY_COR_SEL [UIColor colorWithRed:183/255.0 green:197/255.0 blue:210/255.0 alpha:1/1.0]
#define KEY_COR_BGO [UIColor colorWithRed:198/255.0 green:212/255.0 blue:220/255.0 alpha:1/1.0]
#define KEY_COR_BUT [UIColor colorWithRed:161/255.0 green:167/255.0 blue:178/255.0 alpha:1/1.0]

#define KEY_TAG 555

#define TOPBAR_H       ([UIApplication sharedApplication].statusBarFrame.size.height + 44)      //statusBar + navBar


@interface ZYiPadNumkeyboard ()

@property (nonatomic, weak) UIResponder <UITextInput> *targetTextInput;

@property (nonatomic, strong) UIImage       * selectImage;
@property (nonatomic, strong) UIButton      * pointBut;
@property (nonatomic, strong) UIButton      * rightBut;

@property (nonatomic, assign) CGFloat       old_Y;

@end

@implementation ZYiPadNumkeyboard

+ (ZYiPadNumkeyboard *)numkeyboard
{
    static ZYiPadNumkeyboard *keyboard = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        keyboard = [[ZYiPadNumkeyboard alloc] init];
        [keyboard initializeUserInterface];
        [keyboard addObservers];
    });
    return keyboard;
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)initializeUserInterface
{
    self.frame = CGRectMake(0, 0, KEY_W, KEY_H);
    
    self.backgroundColor = KEY_COR_BG;
    
    CGFloat numBut_W = 140;
    CGFloat sep = 10;
    CGFloat numBut_H = KEY_H / 4.0 - sep;
    
    for (int i = 1; i < 13; i ++) {
        UIButton * numBut = [self createKeyNumButWithNum:i];
        numBut.bounds = CGRectMake(0, 0, numBut_W, numBut_H);
        
        CGFloat center_X = KEY_W / 2.0;
        CGFloat center_Y = numBut_H / 2.0 + (numBut_H + sep) * ((i - 1) / 3);
        
        if (i % 3 == 1) {
            center_X -= numBut_W + sep;
        }else if (i % 3 == 0){
            center_X += numBut_W + sep;
        }
        numBut.center = CGPointMake(center_X, center_Y);
        
        //特殊处理
        if (i == 10 || i == 12) {
            NSString * butImageName = (i == 10) ? @"ipadPoint":@"ipadDel";
            numBut.backgroundColor = KEY_COR_BGO;
            [numBut setTitle:@"" forState:UIControlStateNormal];
            [numBut setImage:[UIImage imageNamed:butImageName] forState:UIControlStateNormal];
            [numBut setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
            
        }else{
            if (!_selectImage) {
                _selectImage = [self createImageWithColor:KEY_COR_SEL];
            }
            [numBut setBackgroundImage:_selectImage forState:UIControlStateHighlighted];
            if (i == 11){
                [numBut setTitle:@"0" forState:UIControlStateNormal];
            }
        }
        
        if (i == 12) {
            [numBut addTarget:self action:@selector(removeButPressed:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [numBut addTarget:self action:@selector(numButPressed:) forControlEvents:UIControlEventTouchUpInside];
            numBut.tag = KEY_TAG + i;
        }
        
        if (i == 10) {
            _pointBut = numBut;
        }
    }
    
    CGFloat leftSep = (KEY_W - numBut_W * 3 - sep * 2) / 2.0;
    CGFloat leftBut_W = leftSep - 40;
    if (leftBut_W > 150) {
        leftBut_W = 150;
    }
    
    CGFloat leftBut_H = leftBut_W * 0.7;
    
    //左侧按钮 收起键盘
    UIButton * leftBut = [self createKeyNumButWithNum:-1];
    [leftBut setImage:[UIImage imageNamed:@"ipadKeyboard"] forState:UIControlStateNormal];
    leftBut.bounds = CGRectMake(0, 0, leftBut_W, leftBut_H);
    leftBut.center = CGPointMake(leftSep / 2.0, KEY_H / 2.0);
    leftBut.backgroundColor = KEY_COR_BUT;
    [leftBut addTarget:self action:@selector(hideKeyboardAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBut setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    
    //右侧功能键
    UIButton * rightBut = [self createKeyNumButWithNum:-1];
    [rightBut setTitle:@"完成" forState:UIControlStateNormal];
    rightBut.bounds = CGRectMake(0, 0, leftBut_W, leftBut_H);
    rightBut.center = CGPointMake(KEY_W - leftSep / 2.0, KEY_H / 2.0);
    rightBut.backgroundColor = KEY_COR_BUT;
    rightBut.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    [rightBut setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _rightBut = rightBut;
}


#pragma mark -- create view
- (UIButton *)createKeyNumButWithNum:(int)num
{
    UIButton * numberBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [numberBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (num > -1) {
        [numberBut setTitle:[NSString stringWithFormat:@"%d",num] forState:UIControlStateNormal];
        numberBut.titleLabel.font = [UIFont boldSystemFontOfSize:35];
    }
    numberBut.imageView.contentMode = UIViewContentModeScaleAspectFit;
    numberBut.backgroundColor = [UIColor whiteColor];
    numberBut.layer.cornerRadius = 5;
    numberBut.clipsToBounds = YES;
    [self addSubview:numberBut];
    return numberBut;
}

#pragma mark -- button pressed

/**
 数字键点击 包括.
 */
- (void)numButPressed:(UIButton *)sender
{
    NSInteger num= sender.tag - KEY_TAG;
    if (num == 11) {
        num = 0;
    }
    NSString * numString = [NSString stringWithFormat:@"%ld",num];
    if (num == 10) {
        numString = @".";
    }
    
    if (self.targetTextInput) {
        NSString * str;
        
        if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
            UITextField *temp = (UITextField *)self.targetTextInput;
            NSRange selectRange = [self selectedRange:temp];
            if (selectRange.length > 0) {
                temp.text = [temp.text stringByReplacingCharactersInRange:selectRange withString:numString];
                str = temp.text;
            }else{
                temp.text = [temp.text stringByAppendingString:numString];
                str = temp.text;
            }

            [self textFieldEditingChanged:temp];
            
        }else if ([self.targetTextInput isKindOfClass:[UITextView class]]) {
            UITextView *temp = (UITextView *)self.targetTextInput;
            temp.text = [temp.text stringByAppendingString:numString];
            str = temp.text;
        }
    }
}


/**
 删除输入
 */
- (void)removeButPressed:(UIButton *)sender
{
    if (self.targetTextInput) {
        NSString * str;
        if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
            UITextField *temp = (UITextField *)self.targetTextInput;
            if ([temp.text length]) {
                NSRange selectRange = [self selectedRange:temp];
                if (selectRange.length > 0) {
                   temp.text = [temp.text stringByReplacingCharactersInRange:selectRange withString:@""];
                    str = temp.text;
                }else{
                    temp.text = [temp.text substringToIndex:[temp.text length]-1];
                    str = temp.text;
                }
            }
            [self textFieldEditingChanged:temp];
            
        }else if ([self.targetTextInput isKindOfClass:[UITextView class]]) {
            UITextView *temp = (UITextView *)self.targetTextInput;
            if ([temp.text length]) {
                temp.text = [temp.text substringToIndex:[temp.text length]-1];
                str = temp.text;
            }
        }
    }
}


/**
 获取textFiled的选中区域
 */
- (NSRange)selectedRange:(UITextField *)textField
{
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextRange* selectedRange = textField.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

/**
 收起键盘
 */
-(void)hideKeyboardAction
{
    [self.targetTextInput resignFirstResponder];
}


/**
 右侧功能键点击
 */
- (void)rightButtonAction
{
    if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
        UITextField *temp = (UITextField *)self.targetTextInput;
        if (temp.returnKeyType == UIReturnKeyNext) {
            if ([temp.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
                [temp.delegate textFieldShouldReturn:temp];
            }
        }else{
            [self hideKeyboardAction];
        }
    }
}


#pragma mark -- textfield 输入改变
- (void)textFieldEditingChanged:(UITextField *)textField
{
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark -- notif
//开始输入
- (void)editingDidBegin:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UITextView class]] || [notification.object isKindOfClass:[UITextField class]]) {
        self.targetTextInput = notification.object;
        
        if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
            UITextField *temp = (UITextField *)self.targetTextInput;
            if (![temp.inputView isKindOfClass:[ZYiPadNumkeyboard class]]) {
                if (!_autoKeyboardTooBar) {
                    return;
                }
                if ((temp.keyboardType == UIKeyboardTypePhonePad || temp.keyboardType == UIKeyboardTypeNumberPad || temp.keyboardType == UIKeyboardTypeDecimalPad)) {
                    [self setToolBarEnable:YES];
                }else{
                    [self setToolBarEnable:NO];
                }
                return;
            }
            
            if (temp.padKeyboardType == PadKeyboardTypePhone) {
                _pointBut.hidden = YES;
            }else{
                _pointBut.hidden = NO;
            }
            
            [self setRightButTitleWithTextField:temp];
            [self handleFrameWithInputView:temp];
        }

    }else{
        self.targetTextInput = nil;
    }
}

- (void)editingDidEnd:(NSNotification *)notif
{
     if (self.targetTextInput && [self.targetTextInput isKindOfClass:[UITextField class]]) {
        UITextField *temp = (UITextField *)self.targetTextInput;
        if ([temp.inputView isKindOfClass:[ZYiPadNumkeyboard class]]) {
            [self keyboardHiden];
        }else{
            if (!_autoKeyboardTooBar) {
                return;
            }
           [self setToolBarEnable:NO];
        }
    }
}

#pragma mark -- keyboard toolbar
- (void)setToolBarEnable:(BOOL)enable
{
//    [IQKeyboardManager sharedManager].enableAutoToolbar = enable;
}


#pragma mark -- 设置右侧按钮标题
- (void)setRightButTitleWithTextField:(UITextField *)tep
{
    if (tep.returnKeyType == UIReturnKeyDone) {
        [_rightBut setTitle:@"完成" forState:UIControlStateNormal];
        
    }else if (tep.returnKeyType == UIReturnKeyNext){
        [_rightBut setTitle:@"下一项" forState:UIControlStateNormal];
        
    }else{
        [_rightBut setTitle:@"完成" forState:UIControlStateNormal];
    }
}


#pragma mark -- 开始输入时，判断输入框位置，移动view
- (void)handleFrameWithInputView:(UITextField *)inputView
{
    CGRect rect = [inputView convertRect:inputView.bounds toView:self.window];
    CGFloat max_Y = rect.origin.y + rect.size.height;
    CGFloat less_H = SCR_H - max_Y;
    if (less_H < KEY_BOR_H) {
        UIView * superView = [self getSuperViewWithObject:inputView.delegate];
        
        NSLog(@"fuck -- %f",_old_Y);
        CGRect oldFrame = superView.frame;
        CGFloat less = less_H - KEY_BOR_H + oldFrame.origin.y;
        [UIView animateWithDuration:0.3 animations:^{
            superView.frame = CGRectMake(oldFrame.origin.x, less, oldFrame.size.width, oldFrame.size.height);
        }];
    }
}

#pragma mark -- 收起键盘
- (void)keyboardHiden
{
    if ([self.targetTextInput isKindOfClass:[UITextField class]]) {
        UITextField *temp = (UITextField *)self.targetTextInput;
        
        UIView * superView = [self getSuperViewWithObject:temp.delegate];
        CGRect oldFrame = superView.frame;
        
        [UIView animateWithDuration:0.3 animations:^{
            superView.frame = CGRectMake(0, _old_Y, oldFrame.size.width, oldFrame.size.height);
        }];
    }
}

- (UIView *)getSuperViewWithObject:(id)object
{
    if ([object isKindOfClass:[UIWindow class]]) {
        UIView * tepView = object;
        _old_Y = 0;
        return [self getCurrentVCWithView:tepView].view;
        
    }else if ([object isKindOfClass:[UIView class]]) {
        UIView * tepView = object;
        _old_Y = TOPBAR_H;
        return [self getCurrentVCWithView:tepView].view;
        
    }else if ([object isKindOfClass:[UIViewController class]]){
        _old_Y = TOPBAR_H;
        UIViewController * tepVC = object;
        return tepVC.view;
    }
    return nil;
}


#pragma mark -- create image
- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/** 获取当前View的控制器对象 */
-(UIViewController *)getCurrentVCWithView:(UIView *)view
{
    UIResponder *next = [view nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

@end

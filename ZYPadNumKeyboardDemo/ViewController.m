//
//  ViewController.m
//  ZYPadNumKeyboardDemo
//
//  Created by zhangyi on 2019/11/9.
//  Copyright © 2019年 zy. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+iPadKeyboard.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 40)];
    textField.padKeyboardType = PadKeyboardTypeNum;
    textField.backgroundColor = [UIColor yellowColor];
    textField.placeholder = @"请输入";
    [self.view addSubview:textField];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

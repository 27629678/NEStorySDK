//
//  ViewController.m
//  SDKDemo
//
//  Created by H-YXH on 14-4-17.
//  Copyright (c) 2014年 NetEase. All rights reserved.
//

#import "ViewController.h"
#import "NEStoryAPI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RefreshTextViewContentAction:(id)sender {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"提示"
                                                 message:@"需要版本号3.1.0\n(如果版本太低，会造成无法完成请求，请检查网易识字版本号)"
                                                delegate:self
                                       cancelButtonTitle:@"确定" otherButtonTitles:@"如何查看版本号", nil];
    [av show];
    [av release];
}
@end

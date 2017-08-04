//
//  ViewController.m
//  DiyCameraDemo
//
//  Created by 花花 on 2017/8/4.
//  Copyright © 2017年 花花. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "DiyCameraTakeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setTitle:@"拍照"];
    
    CGFloat wdtButton = 100;
    UIButton *takeButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2.0-wdtButton/2.0, 150, wdtButton, wdtButton/2.0)];
    takeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    takeButton.layer.borderWidth = 1;
    takeButton.layer.cornerRadius = 5;
    [takeButton setTitle:@"拍照" forState:UIControlStateNormal];
    takeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    takeButton.backgroundColor = [UIColor redColor];
    [takeButton addTarget:self
                   action:@selector(takePhoto)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeButton];
    
}

#pragma mark -- 拍摄照片
- (void)takePhoto {
    DiyCameraTakeViewController *cameraTake = [[DiyCameraTakeViewController alloc]init];
    [self.navigationController pushViewController:cameraTake animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

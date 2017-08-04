//
//  DiyCameraTakeViewController.h
//  BeStudent_Teacher
//
//  Created by 花花 on 2017/7/31.
//  Copyright © 2017年 花花. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiyCameraTakeViewController : UIViewController

@property (nonatomic, assign) BOOL fromInstallment;
@property (nonatomic, copy) void(^TakePhotoBlock)(UIImage *curImage);

@end


//
//  DiyCameraTakeViewController.m
//  BeStudent_Teacher
//
//  Created by 花花 on 2017/7/31.
//  Copyright © 2017年 花花. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "DiyCameraTakeViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface DiyCameraTakeViewController () <AVCapturePhotoCaptureDelegate>
{
    BOOL _isTake;//是否已拍摄
    UIButton *_leftBtn;
    UIButton *_rightBtn;
    UIButton *_takeBtn;
    AVCaptureDevice *_device;//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入)
    AVCaptureDeviceInput *_input;//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
    AVCaptureStillImageOutput *_imageOutput;//输出图片
    AVCaptureSession *_session;//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
    AVCaptureVideoPreviewLayer *_previewLayer;//图像预览层，实时显示捕获的图像
}

@property (nonatomic, strong) UIImage *image;
@end

@implementation DiyCameraTakeViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self cameraDistrict];
}

//初始化各个对象
- (void)cameraDistrict {
    
    //AVMediaTypeVideo
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _imageOutput = [[AVCaptureStillImageOutput alloc]init];
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_imageOutput]) {
        [_session addOutput:_imageOutput];
    }
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
    
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    
    //拍摄按钮
    CGFloat takeHgt = 66;
    _takeBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2.0-takeHgt/2.0, kScreenHeight-30-takeHgt, takeHgt, takeHgt)];
    [_takeBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
    [_takeBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_takeBtn];
    
    
    _leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _takeBtn.frame.origin.y, 75, _takeBtn.frame.size.height)];
    
    [_leftBtn addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_leftBtn];
    
    
    _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-75-25, _takeBtn.frame.origin.y, 75, _takeBtn.frame.size.height)];
    
    [_rightBtn addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    _rightBtn.hidden = YES;
    [self.view addSubview:_rightBtn];
    
    [_session startRunning];
    
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    //先进行判断是否支持控制对焦
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error =nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [_device lockForConfiguration:&error];
        [_device setFocusMode:AVCaptureFocusModeAutoFocus];
//        [self focusAtPoint:self.center];
        //操作完成后，记得进行unlock。
        [_device unlockForConfiguration];
    }
    
}

#pragma mark -- 左侧按钮点击方法
- (void)leftButtonClick {
    if (_isTake) {
        //重拍
        _isTake = NO;
        [_session startRunning];
        _takeBtn.hidden = NO;
        _rightBtn.hidden = YES;
        [_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- 拍摄
- (void)takePhoto:(UIButton *)btn {
    
    AVCaptureConnection *connect = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (!connect) {
        NSLog(@"拍照失败!");
        return;
    }
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connect completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        [_session stopRunning];
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        
        [_leftBtn setTitle:@"重拍" forState:UIControlStateNormal];
        _rightBtn.hidden = NO;
        _takeBtn.hidden = YES;
        _isTake = YES;
    }];
    
}

#pragma mark -- 右侧按钮点击
- (void)rightButtonClick {
    if (self.TakePhotoBlock) {
        self.TakePhotoBlock(self.image);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    NSLog(@"-------------------remove %@",self);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

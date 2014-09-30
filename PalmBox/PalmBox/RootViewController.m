//
//  RootViewController.m
//  PalmBox
//
//  Created by Devil on 14-9-29.
//  Copyright (c) 2014年 Devil. All rights reserved.
//

#import "RootViewController.h"
#import <AudioToolbox/AudioToolbox.h>
static SystemSoundID shake_sound_male_id = 0;


@interface RootViewController ()
{
    UIImageView * _upImage;
    UIImageView * _downImage;
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //layoutPlam
    [self layoutPalm];
}

#pragma mark - 设置摄像头
- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [_session startRunning];

}


- (void)layoutPalm
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"palmPrint-568@2x"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 24)];
    _line.image = [UIImage imageNamed:@"scanninglineW"];
    [self.view addSubview:_line];
    
    //打开摄像头
    [self setupCamera];
    //布局启动页
    [self layoutLaunchImage];
}

#pragma mark - 扫描线上下动画
- (void)upDownAnimation
{
    if (upOrdown == NO)
    {
        num ++;
        _line.frame = CGRectMake(0, 2*num, 320, 24);
        if (2*num == 510)
        {
            upOrdown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(0, 2*num, 320, 24);
        if (num == 0)
        {
            upOrdown = NO;
        }
    }
}

#pragma mark - 布局启动页面
- (void)layoutLaunchImage
{
    _upImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _downImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    //setImage
    _upImage.image = [UIImage imageNamed:@"toppart-568h"];
    _downImage.image = [UIImage imageNamed:@"bompart-568h"];
    
    [self.view addSubview:_upImage];
    [self.view addSubview:_downImage];
    
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:1.f];
}


- (void)startAnimation
{
   [UIView animateWithDuration:2.f animations:^{
       //change frame
       _upImage.frame = CGRectMake(0, -self.view.bounds.size.height, _upImage.frame.size.width, _upImage.frame.size.height);
       _downImage.frame =  CGRectMake(0, self.view.bounds.size.height, _downImage.frame.size.width, _downImage.frame.size.height);
         [self lightUp];
       
       [self playSound];
       
   } completion:^(BOOL finished) {
       //TODO
   }];

}


#pragma mark - 设置并且开启手电筒
- (void)lightUp
{
     //开启定时器
      timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(upDownAnimation) userInfo:nil repeats:YES];
    //开启手电筒 间接性对焦
    if([_device hasTorch] && [_device hasFlash])
    {
        if(_device.torchMode == AVCaptureTorchModeOff)
        {
            [_session beginConfiguration];
            [_device lockForConfiguration:nil];
            [_device setTorchMode:AVCaptureTorchModeOn];
            /*
             设置对焦模式 一共三种
             AVCaptureFocusModeLocked              = 0,
             AVCaptureFocusModeAutoFocus           = 1,
             AVCaptureFocusModeContinuousAutoFocus = 2,
             */
            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [_device unlockForConfiguration];
            [_session commitConfiguration];
        }
    }
    
}



#pragma mark - 播放声音
- (void)playSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"open" ofType:@"wav"];
    if (path)
    {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

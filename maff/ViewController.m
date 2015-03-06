//
//  ViewController.m
//  maff
//
//  Created by 奥野遼 on 2015/03/06.
//  Copyright (c) 2015年 奥野遼. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController ()

@end

@implementation ViewController

CFURLRef soundURL;
SystemSoundID soundID;
SystemSoundID soundID2;
SystemSoundID soundID3;
SystemSoundID soundBGM;

bool soundSet = false;
bool soundSet_gun = false;
bool soundSet_saberu = false;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //加速度センサーを定義
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    //更新間隔を設定
    accelerometer.updateInterval = 0.1;
    //デリゲートを selfに指定
    accelerometer.delegate = self;
    
    //BGM設定
    NSURL* path = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"newtype" ofType:@"mp3"]];
    NSURL* path2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"saberu" ofType:@"wav"]];
    NSURL* path3 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"rifle" ofType:@"wav"]];
        NSURL* path_bgm = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"bgm" ofType:@"mp3"]];

    //効果音登録
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path, &soundID);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path2, &soundID2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path3, &soundID3);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path_bgm, &soundBGM);
    
    //BGM関係 うまく行かん
//    NSURL* path_bgm = [NSURL fileURLWithPath:[[NSBundle mainBundle]
//                                              pathForResource:@"bgm" ofType:@"mp3"]];
//    AVAudioPlayer* player = [[AVAudioPlayer alloc]initWithContentsOfURL:path_bgm error:nil];
//    [player play];
    
    
    //再生
    AudioServicesPlaySystemSound(soundBGM);
    
    
    
}

-(void)soundreset{
    soundSet_saberu = false;
    soundSet_gun = false;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    //傾き度合いをラベルに表示
    self.xLabel.text = [NSString stringWithFormat:@"x=%f", acceleration.x];
    self.yLabel.text = [NSString stringWithFormat:@"y=%f", acceleration.y];
    self.zLabel.text = [NSString stringWithFormat:@"z=%f", acceleration.z];
    
    //ニュータイプ検知
    if (acceleration.z > 0.95 && soundSet == false) {
        AudioServicesPlaySystemSound(soundID);
        soundSet = true;
    }
    //ビームライフル
    if (acceleration.y > 0.1){
        soundSet_gun = true;
    }else if (acceleration.y < -0.3 && soundSet_gun == true){
        AudioServicesPlaySystemSound(soundID3);
//        sleep(1);
        [self soundreset];
    }
    //ベームサーベル
    if (acceleration.y < -0.9){
        soundSet_saberu = true;
    }else if(acceleration.y > 0.3 && soundSet_saberu == true){
        AudioServicesPlaySystemSound(soundID2);
        soundSet_saberu = false;
        sleep(1);
        [self soundreset];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

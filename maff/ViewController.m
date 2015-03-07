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


@interface ViewController()
- (IBAction)chnge_page2:(UIButton *)sender;
- (IBAction)change_page3:(UIButton *)sender;
- (IBAction)change_page1:(UIButton *)sender;
@end

@implementation ViewController

CFURLRef soundURL;
SystemSoundID soundID;
SystemSoundID soundID2;
SystemSoundID soundID3;
SystemSoundID soundID_gstart;
SystemSoundID soundID_d1;
SystemSoundID soundID_d2;
SystemSoundID soundID_other;
SystemSoundID soundID_other1;
SystemSoundID soundID_other2;
SystemSoundID soundID_other3;

bool soundSet = false;
bool soundSet_gun = false;
bool soundSet_saberu = false;
bool soundSet_d2 = false;
bool soundSet_o1 = false;
int soundSet_gun_pre = 0;

int channel = 1;
int dartsCount = 0;
int score;
int score_sum;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //加速度センサーを定義
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    //更新間隔を設定
    accelerometer.updateInterval = 0.1;
    //デリゲートを selfに指定
    accelerometer.delegate = self;
    
    //BGM設定
    NSURL* path_gs = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"start" ofType:@"wav"]];
    NSURL* path = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"newtype" ofType:@"mp3"]];
    NSURL* path2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"saberu" ofType:@"wav"]];
    NSURL* path3 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                          pathForResource:@"rifle" ofType:@"wav"]];
    NSURL* drive1 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                           pathForResource:@"drive_start" ofType:@"mp3"]];
    NSURL* drive2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"nsx" ofType:@"mp3"]];
    NSURL* other = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"cartridge" ofType:@"mp3"]];
    NSURL* other1 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"gunset" ofType:@"mp3"]];
    NSURL* other2 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"fire" ofType:@"mp3"]];
    NSURL* other3 = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                            pathForResource:@"machinegun" ofType:@"mp3"]];

    //効果音登録
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path_gs, &soundID_gstart);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path, &soundID);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path2, &soundID2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)path3, &soundID3);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)drive1, &soundID_d1);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)drive2, &soundID_d2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other, &soundID_other);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other1, &soundID_other1);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other2, &soundID_other2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)other3, &soundID_other3);


    //再生
    AudioServicesPlaySystemSound(soundID_gstart);
}


//サインド初期化
-(void)soundreset{
    soundSet_saberu = false;
    soundSet_gun = false;
    soundID_d2 = false;
    soundSet_o1 = true;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    //傾き度合いをラベルに表示
    self.xLabel.text = [NSString stringWithFormat:@"x=%f", acceleration.x];
    self.yLabel.text = [NSString stringWithFormat:@"y=%f", acceleration.y];
    self.zLabel.text = [NSString stringWithFormat:@"z=%f", acceleration.z];
    NSLog(@"x=%f", acceleration.x);
    NSLog(@"y=%f", acceleration.y);
    NSLog(@"z=%f", acceleration.z);
    
    switch (channel) {
        case 1:
            NSLog(@"%d",channel);

    //ニュータイプ検知
    if (acceleration.z > 0.95 && soundSet == false) {
        AudioServicesPlaySystemSound(soundID);
        soundSet = true;
    }
    //ビームライフル
    if (acceleration.y > 0.3){
        soundSet_gun = true;
    }else if (acceleration.y < -0.3 && soundSet_gun == true){
        AudioServicesPlaySystemSound(soundID3);
        // sleep(1);
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
        break;
            
            
        case 2:
            NSLog(@"%d",channel);
            if (acceleration.z < 0.4){
                soundSet_d2 = true;
                NSLog(@"set");
            }else if(acceleration.z > 0.9 && soundSet_d2 == true){
                NSLog(@"go");
                AudioServicesPlaySystemSound(soundID_d2);
                soundSet_d2 = false;
                sleep(2);
                [self soundreset];
            }
            break;
            
        //銃
        case 3:
            NSLog(@"%d",channel);
            
            if(acceleration.x < -0.5){
                //ハンドガン
                if (acceleration.y > 0.3 && soundSet_gun_pre == 0){
                
                    soundSet_gun = true;
                    AudioServicesPlaySystemSound(soundID_other1);
                    soundSet_gun_pre = 1;
                
                }else if (acceleration.y < -0.3 && soundSet_gun == true){
                    AudioServicesPlaySystemSound(soundID_other2);
                    sleep(1);
                    AudioServicesPlaySystemSound(soundID_other);
                    soundSet_gun_pre = 0;
                    [self soundreset];
                }
            }
            if (acceleration.x > 0.8){
                AudioServicesPlaySystemSound(soundID_other3);
                AudioServicesPlaySystemSound(soundID_other);
            }
                
            break;
            //
            }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//画面遷移アクション
- (IBAction)change_page1:(UIButton *)sender {
    NSLog(@"changed page1");
    channel = 1;
    AudioServicesPlaySystemSound(soundID_gstart);
}

- (IBAction)chnge_page2:(UIButton *)sender {
    NSLog(@"changed page3");
    channel = 2;
    AudioServicesPlaySystemSound(soundID_d1);
}

- (IBAction)change_page3:(UIButton *)sender {
    NSLog(@"changed page3");
    channel = 3;
//    AudioServicesPlaySystemSound(soundID_other);
}


@end

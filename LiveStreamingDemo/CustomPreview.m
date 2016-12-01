//
//  CustomPreview.m
//  LiveStreamingDemo
//
//  Created by reborn on 16/11/21.
//  Copyright © 2016年 reborn. All rights reserved.
//

#import "CustomPreview.h"
#import "LFLiveSession.h"
#import "UIView+YYAdd.h"
#define SCREEN_WIDTH                      ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_HEIGHT                     ([[UIScreen mainScreen]bounds].size.height)

@interface CustomPreview ()<LFLiveSessionDelegate>
@property (nonatomic, strong) UILabel       *stateLabel;
@property (nonatomic, strong) UIButton      *beautyButton;
@property (nonatomic, strong) UIButton      *cameraButton;
@property (nonatomic, strong) UIButton      *closeButton;
@property (nonatomic, strong) UIButton      *startLiveButton;
@property (nonatomic, strong) UIView        *backView;

@property (nonatomic, strong) LFLiveDebug   *debugInfo;
@property (nonatomic, strong) LFLiveSession *liveSession;
@end

@implementation CustomPreview

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        
        [self checkVideoStatus];
        [self checkAudioStatus];
        
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    [self addSubview:self.backView];
    [_backView addSubview:self.stateLabel];
    [_backView addSubview:self.closeButton];
    [_backView addSubview:self.cameraButton];
    [_backView addSubview:self.beautyButton];
    [_backView addSubview:self.startLiveButton];
}

#pragma mark - Action

- (void)changeCapture:(id)sender
{
    AVCaptureDevicePosition devicePositon = _liveSession.captureDevicePosition;
    _liveSession.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)beautyAction:(id)sender
{
    _liveSession.beautyFace = !_liveSession.beautyFace;
    _beautyButton.selected = !_liveSession.beautyFace;
}

- (void)startLiveButton:(id)sender
{
    UIButton *startButton = (UIButton *)sender;
    startButton.selected = !startButton.selected;
    
    if(startButton.selected){
        [_startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        stream.url = @"rtmp://192.168.1.178:1935/rtmplive/room";
        
        [_liveSession startLive:stream];
    }else{
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_liveSession stopLive];
    }
}

- (void)closeAction:(id)sender
{
    [_startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
    [_liveSession stopLive];
}

#pragma mark - checkPrivateAuthority
- (void)checkVideoStatus
{
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.liveSession setRunning:YES];
                    });
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized:
            
            [weakSelf.liveSession setRunning:YES];
            break;
            
        case AVAuthorizationStatusDenied:
            break;
            
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            break;
            
        default:
            break;
    }
    
}

- (void)checkAudioStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}


#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
        case LFLiveReady:
            _stateLabel.text = @"未连接";
            break;
        case LFLivePending:
            _stateLabel.text = @"连接中";
            break;
        case LFLiveStart:
            _stateLabel.text = @"已连接";
            break;
        case LFLiveError:
            _stateLabel.text = @"连接错误";
            break;
        case LFLiveStop:
            _stateLabel.text = @"未连接";
            break;
        default:
            break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo{
    NSLog(@"debugInfo: %lf", debugInfo.dataFlow);
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession*)liveSession{
    if(!_liveSession){
        
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2]];
        
//        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
        
        
        /**    1.自己定制单声道  */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 1;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */
        
        /**    2.自己定制高质量音频96K */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */
        
        /**    3.自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */
        
         /*
//        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
//        audioConfiguration.numberOfChannels = 2;
//        audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
//        audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
//        
//        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
//        videoConfiguration.videoSize = CGSizeMake(540, 960);
//        videoConfiguration.videoBitRate = 800*1024;
//        videoConfiguration.videoMaxBitRate = 1000*1024;
//        videoConfiguration.videoMinBitRate = 500*1024;
//        videoConfiguration.videoFrameRate = 24;
//        videoConfiguration.videoMaxKeyframeInterval = 48;
//        //         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
//        videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
//        
//        _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */
        
        
        /**    4.自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
//         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */
        
        
        /**    5.自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */
        
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(1280, 720);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */
        
        _liveSession.delegate = self;
        _liveSession.preView = self;
    }
    return _liveSession;
}

- (UIView*)backView{
    if(!_backView){
        _backView = [UIView new];
        _backView.frame = self.bounds;
        _backView.backgroundColor = [UIColor clearColor];
        _backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backView;
}

- (UILabel*)stateLabel{
    if(!_stateLabel){
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

- (UIButton*)closeButton{
    if(!_closeButton){
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = 20;
        [_closeButton setImage:[UIImage imageNamed:@"close_preview"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _closeButton;
}

- (UIButton*)cameraButton{
    if(!_cameraButton){
        _cameraButton = [UIButton new];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(changeCapture:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cameraButton;
}

- (UIButton*)beautyButton{
    if(!_beautyButton){
        _beautyButton = [UIButton new];
        _beautyButton.size = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width,20);
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateSelected];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateNormal];
        [_beautyButton addTarget:self action:@selector(beautyAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _beautyButton;
}

- (UIButton*)startLiveButton{
    if(!_startLiveButton){
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.width - 60, 44);
        _startLiveButton.left = 30;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        [_startLiveButton addTarget:self action:@selector(startLiveButton:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _startLiveButton;
}
@end

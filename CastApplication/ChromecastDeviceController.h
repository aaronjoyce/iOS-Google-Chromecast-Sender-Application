//
//  ChromeCastDeviceController.h
//  CastApplication
//
//  Created by Aaron Joyce on 03/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>
#import "MediaItem.h"
@import UIKit;
@import AVKit;
@import AVFoundation;


@interface ChromeCastDeviceController : NSObject<GCKDeviceScannerListener,
    GCKDeviceManagerDelegate,
    GCKMediaControlChannelDelegate>
@property(nonatomic, strong) GCKDeviceManager* deviceManager;
@property(nonatomic, strong) GCKDevice *selectedDevice;
@property(nonatomic, strong) GCKMediaControlChannel * mediaControlChannel;
@property(nonatomic, strong) GCKDeviceScanner* deviceScanner;
-(void)transmitMedia:(MediaItem *)mediaItem to:(GCKDevice *)destDevice;
-(void)scanForDevices;
-(NSMutableArray *)getDetectedDevices;
-(NSInteger)getMediaStatus;
-(BOOL)connectTo:(GCKDevice *)selectedDevice;
-(BOOL)isConnected;
-(void)setConnectedDeviceVolume:(float)volume;
-(void)disconnectFromConnectedDevice;
-(float)getConnectedDeviceVolume;
-(void)seekToTime:(NSTimeInterval)timeInterval;
-(void)loadMedia:(NSURL *)url
    thumbnailURL:(NSURL *)thumbnailURL
           title:(NSString *)title
        subtitle:(NSString *)subtitle
        mimeType:(NSString *)mimeType
        metadata:(NSString *)metaData
          tracks:(NSArray *)tracks
       startTime:(NSTimeInterval)startTime
        autoPlay:(BOOL)autoPlay;
-(NSInteger)playPlayback;
-(NSInteger)pausePlayback;
-(NSInteger)stopPlayback;
-(NSString *)deviceStatus;
@end

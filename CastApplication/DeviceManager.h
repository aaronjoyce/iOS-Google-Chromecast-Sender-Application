//
//  DeviceManager.h
//  CastApplication
//
//  Created by Aaron Joyce on 07/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChromeCastDeviceController.h"
#import "MediaItem.h"


@protocol DeviceManagerControllerDelegate<NSObject>

@optional
-(void)devicesFound;
-(void)devicesNotFound;
-(void)deviceDisconnected;
-(void)deviceConnected;
-(void)deviceFailedToConnect;
-(void)presentPlaybackViewController;
-(void)receivedVolumeChangedNotification:(NSNotification *) notification;
-(void)haveAllCastDevicesGoneOffline;
@end


@interface DeviceManager: NSObject<GCKDeviceScannerListener,
    GCKDeviceManagerDelegate,
    GCKMediaControlChannelDelegate>

@property(nonatomic) ChromeCastDeviceController * chromecastDeviceController;
@property(nonatomic, assign) id<DeviceManagerControllerDelegate> delegate;
@property(nonatomic, strong) NSString* connectedDeviceName;
@property(nonatomic) BOOL * isCasting;

-(NSArray *)getDetectedDevices;
-(void)seekToTime:(NSTimeInterval)timeInterval;
-(void)transmitMedia:(MediaItem *)mediaItem to:(NSObject *)destDevice;
-(void)connectTo:(NSObject *)selectedDevice;
-(BOOL)isConnected;
-(float)getConnectedDeviceVolume;
-(void)setConnectedDeviceVolume:(float)volume;
-(NSString *)getConnectedDeviceName;
-(void)disconnect;
-(void)pauseConnectedDevicePlayback;
-(void)playConnectedDevicePlayback;
-(NSString *)getConnectedDeviceStatus;
-(void)transmitMedia:(NSURL *)resourceIdentifier;
-(NSInteger)getMediaStatus;

@end

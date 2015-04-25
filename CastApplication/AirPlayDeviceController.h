//
//  AirPlayDeviceController.h
//  CastApplication
//
//  Created by Aaron Joyce on 05/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>


/* Capture a device: AVCaptureDevice
   Device object: Instance of AVPlayer
 */
@interface AirPlayDeviceController : NSObject
-(void)transmitMedia:(NSURL *)resourceIdentifier to:(NSObject *)destDevice;
-(void)scanForDevices;
-(NSArray *)getDetectedDevices;
-(void)connectTo:(NSObject *)selectedDevice;
-(BOOL)isConnected;
-(void)pausePlayback;
-(void)playPlayback;
-(void)stopPlayback;
-(void)disconnectFrom:(NSObject *)connectedDevice;

@end

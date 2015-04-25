//
//  AirPlayDeviceController.m
//  CastApplication
//
//  Created by Aaron Joyce on 05/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "AirPlayDeviceController.h"

@implementation AirPlayDeviceController

-(void)transmitMedia:(NSURL *)resourceIdentifier to:(AVPlayer *)destDevice
{
    // Implement
}
-(void)scanForDevices
{
    // Implement
}
-(NSMutableArray *)getDetectedDevices{
    return nil;
}

-(void)connectTo:(AVPlayer *)selectedDevice
{
    // Implement
}

-(BOOL)isConnected
{
  return NO;
}

-(void)pausePlayback
{
    // Implement
}
-(void)playPlayback
{
    // Implement
}
-(void)stopPlayback
{
    // Implement
}
-(void)disconnectFrom:(NSObject *)connectedDevice
{
    // Implement
}
@end

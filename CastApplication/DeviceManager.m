//
//  DeviceManager.m
//  CastApplication
//
//  Created by Aaron Joyce on 07/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@interface DeviceManager()
{
    __weak ViewController * _mainViewController;
    __weak DeviceListTableViewController * _deviceListViewController;

}
// 'Private' method declarations
-(void)devicesFound;
-(void)devicesNotFound;
-(void)deviceDisconnected;
-(void)deviceConnected;
-(void)deviceFailedToConnect;
@end
// Store a reference to the device to which the iOS application is currently connected.
@implementation DeviceManager

/*
-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
 */

-(ChromeCastDeviceController *) cc {
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}


-(id)init
{

    // Instantiate Chrome Cast and Air Player device controllers
    self.chromecastDeviceController = [[ChromeCastDeviceController alloc] init];
    // Begin scanning for Chrome Cast and Air Player external devices over
    // existing Wi-Fi network.
    //[self scanForDevices];

    // Register notifiers
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesFound) name:(NSString *)CastDevicesHaveComeOnlineNotification object:nil];
    // Only notified if, having detected devices over the connected network, those
    // devices are no longer detectable. This is likely raised by a device controller
    // 'manager'.
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chromecastDevicesNotFound)name:(NSString *)AllGoogleCastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(haveAllCastDevicesGoneOffline)name:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesNotFound)name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFailedToConnect) name:(NSString *)CastDeviceSelectedFailedToConnectNotification object:nil];
    return self;
}

// 'Public' methods
-(void)scanForDevices
{
    // Only if not currently scanning for devices.
    [self.chromecastDeviceController scanForDevices];
}

-(NSArray *)getDetectedDevices
{
    //NSArray *allDevices=[self.chromecastDeviceController.getDetectedDevices arrayByAddingObjectsFromArray:self.airPlayerDeviceController.getDetectedDevices];
    NSArray *allDevices = [self.chromecastDeviceController getDetectedDevices];
    return allDevices;
}


-(void)transmitMedia:(NSURL *)resourceIdentifier
{
    NSLog(@"This one is called\n");
}

-(NSInteger)getMediaStatus
{
    return [self.chromecastDeviceController.mediaControlChannel requestStatus];
}


// Called, as a result of user interaction, which is handled by the Device List View Controller.
-(void)transmitMedia:(MediaItem *)mediaItem to:(NSObject *)destDevice;
{
    // Requires:
    // - Necessary conditions: A properly-formed URI;
    // - A detected Google Cast or Air Player device, which must be connected to.
    printf("General transmission\n");
    if ([mediaItem isKindOfClass:[MediaItem class]])
    {
      printf("is URL (DeviceManager)\n");
    }
    else
    {
      printf("is not URL (DeviceManager)\n");
    }
    if([destDevice isKindOfClass:[GCKDevice class]])
    {
        [self.chromecastDeviceController transmitMedia:(MediaItem *)mediaItem to:(GCKDevice *)destDevice];
        printf("Chrome Cast submission\n");
    }
    else{
        // Raise an exception.
    }
}

-(void)disconnect
{
    if ([self.chromecastDeviceController selectedDevice] != nil)
    {
        [self.chromecastDeviceController disconnectFromConnectedDevice];
    }
}

-(void)connectTo:(NSObject *)selectedDevice
{
    if ([selectedDevice isKindOfClass:[GCKDevice class]])
    {
        [self.chromecastDeviceController connectTo:(GCKDevice *) selectedDevice];
    }

}

-(BOOL)isConnected
{
  return (self.chromecastDeviceController.isConnected);
}

-(void)haveAllCastDevicesGoneOffline
{
    printf("haveAllCastDevicesGoneOffline invoked\n");
    /*
     if ([[[self deviceManager] getDetectedDevices] count] == 0)
     {
     [self devicesNotFound];
     }
     */
    
}


// 'Private' methods
-(void)devicesFound
{
    // Send message to relevant view, informing it to highlight cast button on UI, and transition to device list if pressed
    printf("DeviceManager's devicesFound\n");
    if ([self.delegate respondsToSelector:@selector(devicesFound)])
    {
        [self.delegate devicesFound];
    }
}
-(void)devicesNotFound
{
    // Send message to re=levant view, informing it to display grayed out cast button, and do not transition to device list if pressed
    if([self.chromecastDeviceController.getDetectedDevices count] == 0)
    {
        if ([self.delegate respondsToSelector:@selector(devicesNotFound)]) {
            [self.delegate devicesNotFound];
        }
    }
}
-(void)deviceDisconnected
{
    // Send message to relevant view, informing it to display notification to the user, alerting them that casting to the selected device has been interrupted.
    if ([self.delegate respondsToSelector:@selector(deviceDisconnected)])
    {
        [self.delegate deviceDisconnected];
    }
}
-(void)deviceConnected
{
    // Send message to relevant view, informing it to display notification to the user, alerting them of successful connection and casting.
    printf("Device connected notification");
    if ([self.delegate respondsToSelector:@selector(deviceConnected)])
    {
        [self.delegate deviceConnected];
    }
}

-(void)deviceFailedToConnect
{
    // Send message to relevant view, informing it Display notification to the user, alerting them that the connection attempt was unsuccesful.
    if ([self.delegate respondsToSelector:@selector(deviceFailedToConnect)])
    {
        [self.delegate deviceFailedToConnect];
    }
}


-(NSString *)getConnectedDeviceName
{
  if (self.chromecastDeviceController.isConnected)
  {
    return self.chromecastDeviceController.selectedDevice.friendlyName;
  }
  else
  {
    // Configure 'name' attribute for AirPlay device, and allow
    // it to be retrieved.
  }
  return nil;
}
-(float)getConnectedDeviceVolume
{
    // Need to implement
    return 0;
}

-(void)setConnectedDeviceVolume:(float)volume
{
    if ([self.chromecastDeviceController selectedDevice] != nil)
    {
        [self.chromecastDeviceController setConnectedDeviceVolume:volume];
    }
}

-(void)seekToTime:(NSTimeInterval)timeInterval
{
    if ([self.chromecastDeviceController selectedDevice] != nil &&
        [self.chromecastDeviceController isConnected])
    {
        [self.chromecastDeviceController seekToTime:timeInterval];
    }
}
-(void)pauseConnectedDevicePlayback
{
    printf("Pause connected device playback\n");
    if ([self.chromecastDeviceController selectedDevice] != nil &&
        [self.chromecastDeviceController isConnected])
    {
        [self.chromecastDeviceController pausePlayback];
    }
}
-(void)playConnectedDevicePlayback
{
    printf("Play connected device playback\n");
    if ([self.chromecastDeviceController selectedDevice] != nil &&
        [self.chromecastDeviceController isConnected])
    {
        [self.chromecastDeviceController playPlayback];
    }
}
-(void)stopConnectedDevicePlayback
{
    printf("Stop connected device playback\n");
    if ([self.chromecastDeviceController selectedDevice] != nil &&
        [self.chromecastDeviceController isConnected])
    {
        [self.chromecastDeviceController stopPlayback];
    }
}

-(NSString *)getConnectedDeviceStatus
{
    if([self.chromecastDeviceController isConnected])
    {
        return [self.chromecastDeviceController deviceStatus];
    }
    return @"Not connected";
}
@end

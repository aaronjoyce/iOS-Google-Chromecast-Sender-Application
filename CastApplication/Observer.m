//
//  Observer.m
//  AnotherTest
//
//  Created by Aaron Joyce on 22/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

@import AVKit;
@import AVFoundation;

#import "DeviceManager.h"
#import "Observer.h"
#import "ChromecastDeviceController.h"
#import "AppDelegate.h"
@implementation Observer
{
    DeviceManager * dm;
}

-(ChromeCastDeviceController *) chromecastDeviceController {
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rate"])
    {
        AVPlayer * player = (AVPlayer *)object;
        if ([object isKindOfClass:[AVPlayer class]])
        {
            NSTimeInterval timeInterval = CMTimeGetSeconds([player currentTime]);
            [[self chromecastDeviceController] seekToTime:timeInterval];
 
            if (player.rate == 0.0)
            {
                [[self chromecastDeviceController] pausePlayback];
                printf("pause\n");
            }
            else if (player.rate == 1.0)
            {
                [[self chromecastDeviceController] playPlayback];
                printf("play\n");
            }
        }
        
    }
    // Listen out for changes to the iOS device's
    // AVSystemController system volume, and
    // communicate such changes to the
    // ChromecastDeviceController.
    if ([keyPath isEqualToString:@"volume"])
    {
        if ([object isKindOfClass:[AVPlayer class]])
        {
            AVPlayer * player = (AVPlayer *)object;
            float deviceVolume = player.volume;
            [[self chromecastDeviceController] setConnectedDeviceVolume:deviceVolume];
        }
        //[[self deviceManager] setConnectedDeviceVolume:];
    	// Acquire reference to connected device. 
    	// Adjust the connected device's associated property. 
    }
}


@end

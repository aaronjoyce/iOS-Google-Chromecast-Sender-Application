//
//  AppDelegate.h
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import "ChromecastDeviceController.h"
#import "PlaybackViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) Observer * observer;


// Creating an instance of the Chromecast Controller here.
@property(strong, nonatomic) ChromeCastDeviceController * chromecastDeviceController;
@property(strong, nonatomic) AVPlayerViewController * playbackViewController;
@property(strong, nonatomic) MediaItem * selectedMediaItem;

@end

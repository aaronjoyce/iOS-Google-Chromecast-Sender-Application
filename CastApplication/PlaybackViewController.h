//
//  PlaybackViewController.h
//  OT
//
//  Created by Aaron Joyce on 24/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import "MediaItem.h"
#import "Observer.h"
#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ChromecastDeviceController.h"
#import "ChromecastDeviceListTableViewController.h"
#import "AppDelegate.h"
#import "ImageUtility.h"
@import AVKit;
@import AVFoundation;
@import UIKit;



@interface PlaybackViewController : AVPlayerViewController<GCKDeviceScannerListener,
    GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *castButton;
@property (strong, nonatomic) MediaItem * selectedMediaItem;
@property (nonatomic) BOOL loadMedia;

@end

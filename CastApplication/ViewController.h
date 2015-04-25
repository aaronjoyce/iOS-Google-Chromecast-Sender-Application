//
//  ViewController.h
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"
#import "ChromecastDeviceListTableViewController.h"
#import "PlaybackViewController.h"
#import <GoogleCast/GCKMediaTrack.h>



static const NSString *CastDevicesHaveComeOnlineNotification = @"CastDeviceHasComeOnlineNotification";
static const NSString *CastDevicesHaveGoneOfflineNotification =
    @"CastDevicesHaveGoneOfflineNotification";
static const NSString *CastDeviceSelectedHasDisconnectedNotification =
    @"CastDeviceSelectedHasDisconnectedNotification";
static const NSString *CastDeviceSelectedHasConnectedNotification = @"CastDeviceSelectedHasConnectedNotification";
static const NSString *CastDeviceSelectedFailedToConnectNotification = @"CastDeviceSelectedFailedToConenctNotification";
static const NSString *HaveAllCastDevicesHaveGoneOfflineNotification = @"HaveAllCastDevicesHaveGoneOfflineNotification";
static const NSString *DidCompleteMediaLoad = @"DidCompleteMediaLoad";
static const NSString *RequestToLoadMediaFailedNotification = @"RequestToLoadMediaFailedNotification";
static const NSString *ShowLoadAttemptFailureAlert = @"ShowLoadAttemptFailureAlert";
static const NSString *SuccessfullyLoadedMediaNotification = @"SuccessfullyLoadedMediaNotification";
 


//@interface ViewController : UITableViewController<DeviceManagerControllerDelegate>
@interface ViewController : UITableViewController<GCKDeviceScannerListener,
GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate>
- (IBAction)showMediaPlayer:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *toMediaPlayer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *castButton;
@property (strong, nonatomic) MediaItem * selectedMediaItem;
@property (nonatomic) BOOL itemSet;
@property NSURL * currentMediaItem;

@property Observer * observer;
@end

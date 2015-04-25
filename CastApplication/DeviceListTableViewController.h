//
//  DeviceListTableViewController.h
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GoogleCast/GoogleCast.h>
#import "DeviceManager.h"
#import "MediaItem.h"
#import "Observer.h"
#import "AppDelegate.h"
#import "ImageUtility.h"

@interface DeviceListTableViewController : UITableViewController<UITableViewDelegate,DeviceManagerControllerDelegate, GCKMediaControlChannelDelegate>
- (IBAction)volumeChanged:(id)sender;
- (IBAction)disconnectFromDevice:(id)sender;

-(void)setCastMediaItem:(MediaItem *)castItem;
@property (nonatomic, strong) MediaItem * castItem;
//@property (weak, nonatomic) IBOutlet UISlider *volumeControlSlider;
- (IBAction)toMediaPlayer:(id)sender;
@property (nonatomic, strong) Observer * observer;
@property (nonatomic, strong) AVPlayer * mediaPlayer;
@end

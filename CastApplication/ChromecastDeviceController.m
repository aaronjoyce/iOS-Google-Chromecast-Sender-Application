//
//  ChromeCastDeviceController.m
//  CastApplication
//
//  Created by Aaron Joyce on 03/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "ChromecastDeviceController.h"
#import "ViewController.h"
#import "AppDelegate.h"

static NSString * const receiverApplicationID = @"OT";

@interface ChromeCastDeviceController()
@property (nonatomic, strong) MediaItem * selectedMediaItem;
@property (nonatomic) int numLoadAttempts;
@end

@implementation ChromeCastDeviceController

-(AVPlayerViewController *) playbackViewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.playbackViewController;
}


-(id)init {
    self.numLoadAttempts = 0;
    self = [super init];
    if (self)
    {
        // Initialise device scanner
        self.deviceScanner = [[GCKDeviceScanner alloc] init];
        GCKFilterCriteria * filterCriteria = [[GCKFilterCriteria alloc] init];
        filterCriteria = [GCKFilterCriteria criteriaForAvailableApplicationWithID:(NSString *)kGCKMediaDefaultReceiverApplicationID];
        
        // Set filter criteria
        self.deviceScanner.filterCriteria = filterCriteria;
        
        // Register notifiers
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesFound) name:(NSString *)CastDevicesHaveComeOnlineNotification object:nil];
        
        // Only notified if, having detected devices over the connected network, those
        // devices are no longer detectable. This is likely raised by a device controller
        // 'manager'.
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(haveAllCastDevicesGoneOffline)name:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesNotFound)name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedToCastMedia) name:(NSString *)RequestToLoadMediaFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(successfullyLoadedMedia) name:(NSString *)SuccessfullyLoadedMediaNotification object:nil];
        
        [self.deviceScanner addListener:self];
        [self.deviceScanner startScan];
    }
    return self;
}

-(void)scanForDevices
{
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
}

-(NSArray *)getDetectedDevices
{
    NSMutableArray * devicesFound = [[NSMutableArray alloc] init];

    for (GCKDevice * device in _deviceScanner.devices)
    {
        [devicesFound addObject:device];
    }
    return devicesFound;
}

-(BOOL)connectTo:(GCKDevice *)selectedDevice
{
    self.selectedDevice = selectedDevice;
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
cellForRowAtIndexPath:
    _deviceManager = [[GCKDeviceManager alloc] initWithDevice:self.selectedDevice clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    _deviceManager.delegate = self;
    [_deviceManager connect];
    return [_deviceManager isConnected];
}
-(BOOL)isConnected
{
    return _deviceManager.isConnected;
}

-(BOOL)isConnectedTo:(GCKDevice *)device
{
    BOOL connectedToADevice = [_deviceManager isConnected];
    return self.selectedDevice.friendlyName == device.friendlyName && connectedToADevice;
}

/*
 @param NSURL * resourceIdentifier represents the URL of the media resource (soundtrack or
 video) being transmitted from the receiver device (iOS) to an external Google Cast device.
 @param GCKDevice * destDevice represents the device to which the media resource is
 to be casted to.
 */
-(void)transmitMedia:(MediaItem *)mediaItem to:(GCKDevice *)destDevice;
{
    self.numLoadAttempts++;
    // Requires:
    // - A detected Google Cast device, which must be connected to.
    if (destDevice != nil)
    {
        [self connectTo:destDevice];
    }
    self.selectedMediaItem = mediaItem;
    self.selectedDevice = destDevice;
}

-(NSInteger)getMediaStatus
{
    return [self.mediaControlChannel requestStatus];
}

-(float)getConnectedDeviceVolume
{
    return self.deviceManager.deviceVolume;
}


#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected!!");
    [self playbackViewController].player.muted = YES;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:(NSString *)CastDeviceSelectedHasConnectedNotification
     object:self];
    [deviceManager launchApplication:kGCKMediaDefaultReceiverApplicationID];
}
- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:(NSString *)CastDeviceSelectedHasDisconnectedNotification
     object:self];
}


- (void)deviceManager:(GCKDeviceManager *)deviceManager didFailToConnectWithError:(NSError *) error
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:(NSString *)CastDeviceSelectedFailedToConnectNotification
     object:self];
}

    
    
// Playback control
#pragma mark - GCKDeviceManagerDelegate
-(void)deviceManager:(GCKDeviceManager *)deviceManager
    didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
                      sessionID:(NSString *)sessionID
            launchedApplication:(BOOL)launchedApp {

    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
    [_deviceManager addChannel:self.mediaControlChannel];
    [self sendNotification:(NSString *)CastDeviceSelectedHasConnectedNotification];
    NSTimeInterval timeInterval = CMTimeGetSeconds([[self playbackViewController].player currentTime]);

    NSURL * url = self.selectedMediaItem.itemURI;
    [self loadMedia:(NSURL *)url thumbnailURL:self.selectedMediaItem.artworkURL title:self.selectedMediaItem.itemTitle subtitle:self.selectedMediaItem.itemSubtitle mimeType:self.selectedMediaItem.mimeType metadata:nil tracks:nil startTime:([self.selectedMediaItem.mimeType isEqualToString:@"audio/mp3"]) ? timeInterval: 0.0 autoPlay:YES];

}
#pragma mark - GCKMediaControlChannelDelegate

- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
    didCompleteLoadWithSessionID:(NSInteger)sessionID {
    printf("didCompleteLoad\n");
    self.mediaControlChannel = mediaControlChannel;
    NSTimeInterval timeInterval = CMTimeGetSeconds([[self playbackViewController].player currentTime]);
    [self.mediaControlChannel seekToTimeInterval:timeInterval];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:(NSString *)SuccessfullyLoadedMediaNotification
     object:self];
}

-(void)successfullyLoadedMedia
{
    NSLog(@"Successfully loaded media (Chromceast Device Controller)");
}

- (void) mediaControlChannel:(GCKMediaControlChannel *) 	mediaControlChannel didFailToLoadMediaWithError:(NSError *) error
{
    [self sendNotification:(NSString *)
     RequestToLoadMediaFailedNotification];
}
-(void) failedToCastMedia
{
    // Re-attempt to transmit media
    if ([self isConnected])
    {
        self.numLoadAttempts++;
        if (self.numLoadAttempts > 3)
        {
            [self sendNotification:(NSString *)
             ShowLoadAttemptFailureAlert];
        }
        NSTimeInterval timeInterval = CMTimeGetSeconds([[self playbackViewController].player currentTime]);
        [self loadMedia:(NSURL *)self.selectedMediaItem.itemURI thumbnailURL:self.selectedMediaItem.artworkURL title:self.selectedMediaItem.itemTitle subtitle:self.selectedMediaItem.itemSubtitle mimeType:self.selectedMediaItem.mimeType metadata:nil tracks:nil startTime:timeInterval autoPlay:YES];
    }
    else{
        // Attempt to re-establish a connection with the selected external device, and re-transmit..
        [self transmitMedia:(MediaItem *)self.selectedMediaItem to:(GCKDevice *)self.selectedDevice];
    }
}


/*
 @returns a Boolean true value if media playback has been
 successfully paused on the Google Cast device. Otherwise, it
 returns false.
 */
-(NSInteger)pausePlayback
{
    NSInteger requestID = self.mediaControlChannel.pause;
    return requestID;
}

-(NSInteger)playPlayback
{
    NSInteger requestID = self.mediaControlChannel.play;
    return requestID;
}

-(NSInteger)stopPlayback
{
    NSInteger requestID = self.mediaControlChannel.stop;
    return requestID;
}

#pragma mark - GCKMediaControlChannelDelegate
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel requestDidCompleteWithID:(NSInteger) requestID
{
    // I guess that, when the DeviceManager invokes a media control request upon the connected
    // Google Cast, the device manager is notified of its success, which, in
    // some way, notifies the DeviceListTableController.
}

- (void)mediaControlChannel:(GCKMediaControlChannel *) mediaControlChannel requestDidFailWithID:(NSInteger) requestID error:(NSError *) error
{
    // I guess that, when the DeviceManager invokes a media control request upon the connected
    // Google Cast, the device manager is notified of its failure, which, in
    // some way, notifies the DeviceListTableController.
}

-(void)loadMedia:(NSURL *)url
    thumbnailURL:(NSURL *)thumbnailURL
           title:(NSString *)title
        subtitle:(NSString *)subtitle
        mimeType:(NSString *)mimeType
        metadata:(NSString *)metaData
          tracks:(NSArray *)tracks
       startTime:(NSTimeInterval)startTime
        autoPlay:(BOOL)autoPlay
{
    // Unsure whether this should be executed once, or everytime
    // a URI is send to the Google Cast device:
    // START
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    [metadata setString:title forKey:kGCKMetadataKeyTitle];
    [metadata setString:subtitle forKey:kGCKMetadataKeySubtitle];
    [metadata addImage:[[GCKImage alloc] initWithURL:thumbnailURL width:200 height:100]];
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:mimeType
                                          metadata:metadata
                                    streamDuration:0
                                    mediaTracks:tracks textTrackStyle:[GCKMediaTextTrackStyle createDefault]
                                        customData:nil];

    [self.mediaControlChannel loadMedia:mediaInformation autoplay:autoPlay playPosition:startTime];
    [self.mediaControlChannel play];

}

-(void)disconnectFromConnectedDevice
{
    [self.deviceManager disconnect];
}
-(void)devicesFound
{
    // Display message to user (to be determined during integation with Sleeve).
}
-(void)devicesNotFound
{
    // Display message to user (to be determined during integation with Sleeve).
}
-(void)deviceDisconnected
{
    // Display message to user (to be determined during integation with Sleeve).
}
-(void)deviceConnected
{
    // Display message to user (to be determined during integation with Sleeve).
}
-(void)deviceFailedToConnect
{
    // Display message to user (to be determined during integation with Sleeve).
}

-(void)receivedVolumeChangedNotification:(NSNotification *) notification
{
    // Display message to user (to be determined during integation with Sleeve).
}

-(void)setConnectedDeviceVolume:(float)volume
{
    [self.deviceManager setVolume:volume];
}

-(void)seekToTime:(NSTimeInterval)timeInterval
{
    [self.mediaControlChannel seekToTimeInterval:timeInterval];
}


-(void)haveAllCastDevicesGoneOffline
{
    // Display message to user (to be determined during integation with Sleeve).
}
-(NSString *)deviceStatus
{
    return self.selectedDevice.statusText;
}

#pragma mark - Notify
-(void)sendNotification:(NSString *)notification
{
    // Sends notifications to device manager, which in turns updates
    // the relevant view controllers.
}
#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device found!!!");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:(NSString *)CastDevicesHaveComeOnlineNotification
     object:self];
    // Notify device manager, and add device to the
    // list of available devices shown to the user.
}


- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"device disappeared!!!");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification
        object:self];
    // Notify device manager, and remove device from the list
    // of available devices shown to the user.
}


@end

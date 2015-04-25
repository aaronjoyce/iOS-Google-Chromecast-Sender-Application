//
//  PlaybackViewController.m
//  OT
//
//  Created by Aaron Joyce on 24/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "PlaybackViewController.h"

@interface PlaybackViewController ()
@property (strong, nonatomic) MPVolumeView * playerVolumeView;
@property (strong, nonatomic) UIBarButtonItem * airPlayButton;
@property (nonatomic) CGRect playerVolumeViewBounds;

@end

@implementation PlaybackViewController

@synthesize selectedMediaItem = _selectedMediaItem;
@synthesize loadMedia = _loadMedia;

-(ChromeCastDeviceController *)chromecaseDeviceController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}

-(void) setPlaybackViewController:(PlaybackViewController *)playbackViewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.playbackViewController = playbackViewController;
}

-(AVPlayerViewController *) playbackViewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.playbackViewController;
}

-(Observer *) observer
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.observer;
}

-(void)setObserver:(Observer *)observer
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.observer = observer;
}

-(MediaItem *)selectedPersistentMediaItem
{
    AppDelegate * delegeate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegeate.selectedMediaItem;
}

-(void)setSelectedPersistentMediaItem:(MediaItem *)selectedMediaItem
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.selectedMediaItem = selectedMediaItem;
}


-(void) configurePlayerVolumeController
{
    self.playerVolumeViewBounds = CGRectMake(0, 0, 20, 30);
    self.playerVolumeView = [[MPVolumeView alloc] initWithFrame:self.playerVolumeViewBounds];
    self.airPlayButton = [[UIBarButtonItem alloc] initWithCustomView:self.playerVolumeView];
    [self.playerVolumeView setShowsVolumeSlider:NO];
    [self.playerVolumeView sizeToFit];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configurePlayerVolumeController];
    
    if ([[[self chromecaseDeviceController] getDetectedDevices] count] == 0)
    {
        [self devicesNotFound];
    }
    else{
        [self devicesFound];
    }
    
    // Hide default 'back' button
    self.navigationItem.hidesBackButton = YES;
    
    // Add listener for device volume control buttons.
    // This can be disabled if it is not an OT-desired feature.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    // Listeners for the selected Chromecast device
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesFound) name:(NSString *)CastDevicesHaveComeOnlineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(haveAllCastDevicesGoneOffline)name:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesNotFound)name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFailedToConnect) name:(NSString *)CastDeviceSelectedFailedToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showLoadAttemptFailureAlert) name:(NSString *)ShowLoadAttemptFailureAlert object:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    [self configureNavigationBar];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
    if (_loadMedia)
    {
        [self loadSelectedMediaItem];
        [self setSelectedPersistentMediaItem:self.selectedMediaItem];
        _loadMedia = NO;
    }
    else{
        self.player = [self playbackViewController].player;
    }
    // Do any additional setup after loading the view.
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MediaItem *) selectedMediaItem
{
    return _selectedMediaItem;
}

-(void) setSelectedMediaItem:(MediaItem *) selectedItem
{
    _selectedMediaItem = selectedItem;
}

-(BOOL) loadMedia
{
    return _loadMedia;
}

-(void) setLoadMedia:(BOOL)loadMedia
{
    _loadMedia = loadMedia;
}


-(void) loadSelectedMediaItem
{
    // Initialise AVPlayer
    if ([self playbackViewController] == nil)
    {
        self.player = [AVPlayer playerWithURL:self.selectedMediaItem.itemURI];
        self.player.allowsExternalPlayback = YES;
    
        // Associated an observer with the AVPlayer instance, listening out
        // for the AVPlayer instance's volume and rate, used for controlling
        // Google Chromecast playback.
        Observer * observer = [Observer new];
        [self setObserver:observer];
        [self.player addObserver:[self observer] forKeyPath:@"rate" options:0 context:nil];
        [self.player addObserver:[self observer] forKeyPath:@"volume" options:0 context:nil];
    }
    else{
        AVPlayerItem * replacementItem = [[AVPlayerItem alloc] initWithURL:self.selectedMediaItem.itemURI];
        [[self playbackViewController ].player replaceCurrentItemWithPlayerItem:replacementItem];
        self.player = [self playbackViewController].player;
        [self setPlaybackViewController:self];
    }
    
    // Make the default navigation bar non-translucent.
    self.navigationController.navigationBar.translucent = NO;
    
    // Associated AirPlay device selection with AVPlayer instance
    [self configureNavigationBar];
    
    // Set BOOL 'loadMedia' to 'NO', as the selected media item
    // has been set for the AVPlayer instance
    //self.loadMedia = NO;
    [self setPlaybackViewController:self];
    if([[self chromecaseDeviceController] isConnected])
    {
        [[self chromecaseDeviceController] loadMedia:(NSURL *)self.selectedMediaItem.itemURI thumbnailURL:self.selectedMediaItem.artworkURL title:self.selectedMediaItem.itemTitle subtitle:self.selectedMediaItem.itemSubtitle mimeType:self.selectedMediaItem.mimeType metadata:nil tracks:nil startTime:0.0 autoPlay:YES];
    }
}

// If 'cast' button is pressed, then transmit media to the external Google Cast device.
// ChromecastDeviceListener should be instantiated, and its listeners should be called,
// within the AppDelegate class.

-(void) configureNavigationBar
{
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:3];
    [buttons addObject:self.navigationItem.rightBarButtonItem];
    [buttons addObject:self.airPlayButton];
    
    [toolbar setItems:buttons animated:YES];
    
    UIImage * chromecastIcon = [UIImage imageNamed:@"ic_cast_black_24dp.png"];
    ImageUtility * imageUtil = [[ImageUtility alloc] init];
    chromecastIcon = [imageUtil imageWithImage:chromecastIcon scaledToSize:CGSizeMake(20, 20)];
    [self.navigationItem.rightBarButtonItem setImage:chromecastIcon];
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, self.airPlayButton];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"toMediaItemSelectionViewController"])
    {
        // Send selectedMediaItem to ChromecastDeviceTableViewController instance,
        // whenever a new item has been selected, or the existing item has
        // been re-selected.
        
    }
    else if ([segue.identifier isEqualToString:@"toCastViewController"])
    {
        // Do any set-up work associated with transitioning to the media item
        // selection view contoller; i.e., ViewController.
        
        DeviceListTableViewController * deviceListTableViewController = (DeviceListTableViewController *)[segue destinationViewController];
        if ([self selectedPersistentMediaItem] != nil)
        {
            deviceListTableViewController.selectedCastMediaItem = [self selectedPersistentMediaItem];
            printf("selectedCastMediaItem set for ChromecastDeviceListTableViewController\n");
        }
    }
}

// Notification action methods
// System-specific notification:
- (void) volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    [[self chromecaseDeviceController] setConnectedDeviceVolume:volume];
}

// Chromecast-specific device notifications:
#pragma mark - DeviceManagerControllerDelegate
-(void) devicesFound
{
    if (self.castButton.enabled == NO)
    {
        self.castButton.enabled = YES;
        self.castButton.tintColor = [UIColor blackColor];
    }
}

-(void) devicesNotFound
{
    self.castButton.enabled = NO;
    self.castButton.tintColor = [UIColor lightGrayColor];
}

-(void) deviceConnected
{
    // Mute on-device playback, once a Chromecast device has been connected to.
    printf("device connected\n");
    self.player.muted = YES;
}

-(void) deviceFailedToConnect
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failure"
                                                       message:@"Failed to connect to the specified device."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}


-(void) haveAllCastDevicesGoneOffline
{
    // This method may be redundant, but there may be a
    // useful response/action that I haven't fully considered.
}

#pragma mark GCKMediaControlChannelDelegate
- (void) mediaControlChannel:		(GCKMediaControlChannel *) 	mediaControlChannel
didCompleteLoadWithSessionID:		(NSInteger) 	sessionID
{
    printf("didCompleteLoadWithSessionID\n");
}

-(void) failedToCastMedia
{
    
}

-(void) showLoadAttemptFailureAlert
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Failed to cast media"
                                                       message:@"Unable to stream media on Google Cast device."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    [[self view] setNeedsDisplay];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString *)CastDeviceSelectedFailedToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedToCastMedia) name:(NSString *)RequestToLoadMediaFailedNotification object:nil];
}
@end

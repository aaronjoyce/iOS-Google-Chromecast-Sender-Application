//
//  DeviceListTableViewController.m
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "ChromecastDeviceListTableViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "ChromeCastDeviceController.h"

@import AVKit;
@import AVFoundation;


@interface

DeviceListTableViewController ()
@property (strong, nonatomic) IBOutlet UISlider *vslider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshCast;
@end

@implementation DeviceListTableViewController
{
    BOOL _isManualVolumeChange;
}
@synthesize selectedCastMediaItem = _selectedCastMediaItem;
@synthesize tableView = _tableView;
BOOL firstTime = YES;


-(AVPlayerViewController *) playbackViewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.playbackViewController;
}

-(ChromeCastDeviceController *) chromecastDeviceController {
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}

-(void)setSelectedCastMediaItem:(MediaItem *)selectedCastMediaItem
{
    _selectedCastMediaItem = selectedCastMediaItem;
}
-(MediaItem *)selectedCastMediaItem
{
    return _selectedCastMediaItem;
}


#pragma mark - button handling
-(void)navNextButtonPressed
{
    NSLog(@"Next pressed");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44;
    if (self.observer == nil)
    {
      self.observer = [Observer new];
    }

    if (firstTime == YES)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesFound) name:(NSString *)CastDevicesHaveComeOnlineNotification object:nil];
        // Only notified if, having detected devices over the connected network, those
        // devices are no longer detectable. This is likely raised by a device controller
        // 'manager'.
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesNotFound)name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFailedToConnect) name:(NSString *)CastDeviceSelectedFailedToConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedToCastMedia) name:(NSString *)RequestToLoadMediaFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showLoadAttemptFailureAlert) name:(NSString *)ShowLoadAttemptFailureAlert object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(successfullyLoadedMedia) name:(NSString *)SuccessfullyLoadedMediaNotification object:nil];
        firstTime = NO;
    }
    if (self.view.window == nil)
    {
        NSLog(@"self.window == nil");
    }
    else{
        NSLog(@"self.window != nil");
    }
    // Display devices, if found
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Device List";
}



-(NSInteger)numDevicesFound
{
    return [[[self chromecastDeviceController] getDetectedDevices] count];
}


- (IBAction)volumeChanged:(id)sender {
    NSLog(@"Device volume adjusted");
    UISlider * slider = (UISlider *) sender;
    _isManualVolumeChange = YES;
    [[self chromecastDeviceController]   setConnectedDeviceVolume:slider.value];
    _isManualVolumeChange = NO;
    [[self view] setNeedsDisplay];
}

- (IBAction)disconnectFromDevice:(id)sender
{
    [[self chromecastDeviceController] disconnectFromConnectedDevice];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DeviceManagerControllerDelegate

-(void)devicesFound
{
    // Notify user
}
-(void)devicesNotFound
{
    // Notify user
}

-(void)deviceFailedToConnect
{
    // Send message to relevant view, informing it Display notification to the user, alerting them that the connection attempt was unsuccesful.
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failure"
                                                       message:@"Failed to connect to the specified device."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([self numDevicesFound] == 0)
    {
        return 1;
    }
    if ([self chromecastDeviceController].isConnected == NO)
    {
        self.title =@"Select device";
        return [self numDevicesFound];
    }
    else {
        self.title = [self chromecastDeviceController].selectedDevice.friendlyName;
        return 3;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView deviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForDeviceName = @"deviceName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceName
                                                            forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdForDeviceName];
    }
    NSArray * externalDevices = [[NSArray alloc] init];

    externalDevices = [[self chromecastDeviceController] getDetectedDevices];

    if ([[externalDevices objectAtIndex:indexPath.row] isKindOfClass:[GCKDevice class]])
    {
        GCKDevice * externalDevice = [externalDevices objectAtIndex:indexPath.row];
        cell.textLabel.text = externalDevice.friendlyName;
    }
    return cell;
}


-(UITableViewCell *)tableView:(UITableView *)tableView volumeControlCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdForVolumeControl = @"volumeController";
    VolumeControlllerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdForVolumeControl forIndexPath:indexPath];
    [self.volumeControlSlider setValue:[self playbackViewController].player.volume animated:YES];
    cell.controlSlider.value = [[self chromecastDeviceController] getConnectedDeviceVolume];
    return cell;

}

-(UITableViewCell *)tableView:(UITableView *)tableView disconnectControlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdForDeviceDisconnect = @"deviceDisconnect";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceDisconnect forIndexPath:indexPath];
    return cell;
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView castDeviceStatusForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdForDeviceStatus = @"deviceStatus";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceStatus
                                                             forIndexPath:indexPath];

    if ([[self chromecastDeviceController] getMediaStatus] != kGCKInvalidRequestID)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Status: %@", [[self chromecastDeviceController] deviceStatus]];
    }
    else{
        cell.textLabel.text = [NSString stringWithFormat:@"Status: %@", @"Status currently unavailable"];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForNoDevicesFound = @"noDevicesFound";
    UITableViewCell *cell;
    NSLog(@"cellForRowAtIndexPath called");
    if (([[self chromecastDeviceController] isConnected] == NO) &&
        [[[self chromecastDeviceController] getDetectedDevices] count] != 0)
    {
        // Display list of detected devices.
        cell = [self tableView:tableView deviceCellForRowAtIndexPath:indexPath];
    }
    else if ([[self chromecastDeviceController] isConnected] == YES){
        // Display display media and device controller cells.
        if (indexPath.row == 0)
        {
            cell = [self tableView:tableView castDeviceStatusForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == 1)
        {
            cell = [self tableView:tableView volumeControlCellForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == 2){
            cell = [self tableView:tableView disconnectControlForRowAtIndexPath:indexPath];
        }

    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdForNoDevicesFound
                                               forIndexPath:indexPath];
    }
    return cell;
}


#pragma mark - Navigation
-(void) successfullyLoadedMedia
{
    NSLog(@"successfullyLoadedMedia - ChromecastControllerView");
    [self reloadData];
    [self redrawWindow];
}


-(void) failedToCastMedia
{
    // Display message to user (to be determined during integation with Sleeve).     
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
// Percept a device being selected by the user for media transfer.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * externalDevices = [[NSArray alloc] init];
    externalDevices = [[self chromecastDeviceController] getDetectedDevices];
    if ([[self chromecastDeviceController] isConnected] == NO)
    {
        NSLog(@"Device is not connected");
      if ([externalDevices count] > 0)
      {
          NSLog(@"External devices' count > 0");
          if([[externalDevices objectAtIndex:indexPath.row] isKindOfClass:[GCKDevice class]])
          {
              NSLog(@"Is of type GCKDevice");
              GCKDevice * selectedDevice = [externalDevices objectAtIndex:indexPath.row];
              if (self.selectedCastMediaItem != nil)
              {
                  NSLog(@"selectedCastMediaItem != nil");
                  // Should not transmit media, but should instead make the selected media
                  // available to a Google Cast device, should it require it.
                  [[self chromecastDeviceController] transmitMedia:self.selectedCastMediaItem to:selectedDevice];
                  [tableView reloadData];
                  [tableView setNeedsDisplay];

                  
              }
          }
      }
    }
     NSLog(@"did select row");

    // Display a message to the user, informing them that the resource transfer
    // is "in process".
    // May need to "dismiss" the view.
}

-(void)reloadData
{
    NSLog(@"reloadData invoked");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

- (void)deviceConnected{
    [self.tableView reloadData];
}


-(void)haveAllCastDevicesGoneOffline
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failure"
                                                       message:@"Device has gone offline."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    [[self view] setNeedsDisplay];
    
}

-(void)redrawWindow
{
    [[self view] setNeedsDisplay];
}

-(void)deviceDisconnected
{
    // Send message to relevant view, informing it to display notification to the user, alerting them that casting to the selected device has been interrupted.

    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                       message:@"Cast device has disconnected from your network."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    printf("deviceDisconnected called. Should reload in ChromecastDeviceListTab.\n");
    
    [_tableView reloadData];
    [_tableView setNeedsDisplay];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    if (self.view.window != nil)
    {
        NSLog(@"self.view.window != nil");
    }
    else{
        NSLog(@"self.view.window == nil");
    }
}

# pragma mark - volume
-(void)receivedVolumeChangedNotification:(NSNotification *) notification
{
    printf("receivedVolumeChangedNotification (external)\n");
  if (!_isManualVolumeChange)
  {
      printf("receivedVolumeChangedNotfication (internal(\n");
   self.volumeControlSlider.value = [self chromecastDeviceController].getConnectedDeviceVolume;

  }
}

-(void)mediaControlChannelDidUpdateStatus
{
    NSLog(@"mediaControlChannelDidUpdateStatus");
    [self reloadData];
}

- (IBAction)toMediaPlayer:(id)sender {
    [self performSegueWithIdentifier:@"showMediaPlayer" sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([self isKindOfClass:[UITableViewController class]])
    {
        NSLog(@"self isKindOfClass UITableViewController");
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
}
@end

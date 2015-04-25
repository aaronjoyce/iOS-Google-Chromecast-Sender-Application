//
//  DeviceListTableViewController.m
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "DeviceListTableViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "ChromeCastDeviceController.h"
#import "DeviceManager.h"

@import AVKit;
@import AVFoundation;

@interface

DeviceListTableViewController (){

__weak DeviceManager * _deviceManager;

// Alt. within @implementation (in which case, all _deviceManager within file would have to be modified)
/* -(DeviceManager *) deviceManager {
 *     AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
 *     return delegate.deviceManager;
 */
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshCast;
@end

@implementation DeviceListTableViewController
{
    BOOL _isManualVolumeChange;
    DeviceManager * dm;
}
BOOL firstTime = YES;
@synthesize castItem = _castItem;

-(DeviceManager *) deviceManager {
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    dm = delegate.deviceManager;
    return delegate.deviceManager;
}
-(ChromeCastDeviceController *) cc {
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.cc;
}


-(AVPlayerViewController *)playerViewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.playerViewController;
}
-(void)setPlayerViewController:(AVPlayerViewController *)viewController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.playerViewController = viewController;
}

- (IBAction)toList:(UIStoryboardSegue *)segue {
    ViewController * source = [segue sourceViewController];
}

#pragma mark - button handling
-(void)navNextButtonPressed
{
    NSLog(@"Next pressed");
}
/*
-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    AVAsset * currentlyPlayingAsset = [self playerViewController].player.currentItem.asset;
    NSURL * urlAssetEquivalent;
    if ([currentlyPlayingAsset isKindOfClass:AVURLAsset.class])
    {
      urlAssetEquivalent = [(AVURLAsset *)currentlyPlayingAsset URL];
      if ([urlAssetEquivalent isKindOfClass:NSURL.class])
      {
        printf("Is of type NSURL\n");
      }
    }
    MediaItem * item1 = [[MediaItem alloc] init];
    _castItem = item1;
    _castItem.itemURI = urlAssetEquivalent;
    
    
    self.tableView.rowHeight = 44;
    if (self.observer == nil)
    {
      self.observer = [Observer new];
    }
    printf("Num devices\n");
    NSInteger numDev = [[[self deviceManager] getDetectedDevices] count];
    if (numDev == 0)
    {
        printf("numDev == 0");
    }
    else
    {
        printf("numDev != 0");
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
        firstTime = NO;
    }

    // Display devices, if found

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Device List";
    printf("DeviceListTableViewControler viewDidLoad\n");
}


-(NSInteger)numDevicesFound
{
    return [[dm getDetectedDevices] count];
}


- (IBAction)volumeChanged:(id)sender {
    NSLog(@"Device volume adjusted");
    UISlider * slider = (UISlider *) sender;
    _isManualVolumeChange = YES;
    [[self deviceManager]   setConnectedDeviceVolume:slider.value];
    _isManualVolumeChange = NO;
}

- (IBAction)disconnectFromDevice:(id)sender
{
    [[self deviceManager] disconnect];
}

-(void)setCastMediaItem:(MediaItem *)castItem;
{
    printf("Media item about to be set");
    self.castItem = castItem;
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
        printf("1 cell returned\n");
        return 1;
    }
    if ([self deviceManager].isConnected == NO)
    {
        self.title =@"Select device";
        printf("n cells returned\n");
        return [self numDevicesFound];
    }
    else {
        printf("3 cells returned\n");
        self.title = [[self deviceManager] getConnectedDeviceName];
        return 3;
    }
}

/*
-(UITableViewCell *)tableView:(UITableView *)tableView deviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForDeviceName = @"deviceName";

    UITableViewCell *cell;
    cell.textLabel.text = @"Device title";
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdForDeviceName];
    }

    NSArray * externalDevices = [[NSArray alloc] init];
    externalDevices = [dm getDetectedDevices];
    NSInteger num = [externalDevices count];
    printf("num: %d\n", num);
    printf("num 1: %d\n", [[self cc].getDetectedDevices count]);
    if (num > 0)
    {
        if ([[externalDevices objectAtIndex:indexPath.row] isKindOfClass:[GCKDevice class]])
        {
            GCKDevice * externalDevice = [externalDevices objectAtIndex:indexPath.row];
            cell.textLabel.text = externalDevice.friendlyName;
        }
        else{
            // If an AirPlay device, perform cell necessary configuration
            BOOL deviceStatus = [[externalDevices objectAtIndex:indexPath.row] isConnected];
            cell.textLabel.text = @"Device Name";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Status: %s", deviceStatus ? "Connected" : "Not connected" ];
            //cell.detailTextLabel.text = @"Status: %c", [[externalDevices objectAtIndex:indexPath.row] isConnected ] ? @"Connected" : @"Not connected";
        }
    }

    return cell;
}
 */

-(UITableViewCell *)tableView:(UITableView *)tableView deviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForDeviceName = @"deviceName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceName
                                                            forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdForDeviceName];
    }

    NSArray * externalDevices = [[NSArray alloc] init];


    externalDevices = [[self deviceManager] getDetectedDevices];

    if ([[externalDevices objectAtIndex:indexPath.row] isKindOfClass:[GCKDevice class]])
    {
        GCKDevice * externalDevice = [externalDevices objectAtIndex:indexPath.row];
        cell.textLabel.text = externalDevice.friendlyName;
    }
    else{
        // If an AirPlay device, perform cell necessary configuration
        cell.textLabel.text = @"static";
    }

    return cell;
}


-(UITableViewCell *)tableView:(UITableView *)tableView volumeControlCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdForVolumeControl = @"volumeController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdForVolumeControl forIndexPath:indexPath];
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
    static NSString *NowCasting = @"Now Casting";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceStatus
                                                             forIndexPath:indexPath];

    if ([[self deviceManager] getMediaStatus] != kGCKInvalidRequestID)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"Status: %@", [[self deviceManager] getConnectedDeviceStatus]];
    }
    else{
        cell.textLabel.text = [NSString stringWithFormat:@"Status: %@", [[self deviceManager] getConnectedDeviceStatus]];
        /*
        if ([[[self deviceManager] getConnectedDeviceStatus] isEqualToString:NowCasting])
        {
            cell.textLabel.textColor = [self darkerColorForColor:[UIColor  greenColor]];
        }
        */
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceSelectionCell" forIndexPath:indexPath];
    static NSString *CellIdForNoDevicesFound = @"noDevicesFound";
    UITableViewCell *cell;
    if (([[self deviceManager] isConnected] == NO) &&
        [[[self deviceManager] getDetectedDevices] count] != 0)
    //if ([[self deviceManager] isConnected] == NO)
    {
        // Display list of detected devices.
        
        cell = [self tableView:tableView deviceCellForRowAtIndexPath:indexPath];
    }
    else if ([[self deviceManager] isConnected] == YES){
        //cell = [self tableView:tableView volumeControlCellForRowAtIndexPath:indexPath];
        // Display display media and device controller cells.
        if (indexPath.row == 0)
        {
            cell = [self tableView:tableView castDeviceStatusForRowAtIndexPath:indexPath];
            //cell = [self tableView:tableView volumeControlCellForRowAtIndexPath:indexPath];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showMediaPlayer"])
    {
        NSURL * itemURL = [NSURL
                           URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
        AVPlayerViewController * playerViewController = segue.destinationViewController;
        playerViewController.player = [self playerViewController].player;
        
        playerViewController.navigationController.navigationBar.translucent = NO;
        CGRect someBounds = CGRectMake(0, 0, 20, 30);
        MPVolumeView *myVolumeView =
        [[MPVolumeView alloc] initWithFrame:someBounds];
        //[[[self playerViewController] view] addSubview: myVolumeView]; // Not sure whether this matters..
        UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithCustomView: myVolumeView];
        [myVolumeView setShowsVolumeSlider:NO];
        [myVolumeView sizeToFit];
        
        UIToolbar * tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 50.0)];
        NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:3];
        [buttons addObject:playerViewController.navigationItem.rightBarButtonItem];
        [buttons addObject:b];
        
        [tools setItems:buttons animated:YES];
        //UIBarButtonItem* rightButtonBar = [[UIBarButtonItem alloc] initWithCustomView:tools];
        UIImage *gcIcon = [UIImage imageNamed:@"ic_cast_black_24dp.png"];
        ImageUtility * imgUtil = [[ImageUtility alloc] init];
        gcIcon = [imgUtil imageWithImage:gcIcon scaledToSize:CGSizeMake(20, 20)];
        //UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
        //face.bounds = CGRectMake(0, 0, 70, 50);
        //[face setImage:gcIcon forState:UIControlStateNormal];
        [playerViewController.navigationItem.rightBarButtonItem setImage:gcIcon];
        //UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:face];
        playerViewController.navigationItem.rightBarButtonItems = @[[self playerViewController].navigationItem.rightBarButtonItem,b];
        printf("showMediaplayer called\n");
    }
    
}
// Percept a device being selected by the user for media transfer.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * externalDevices = [[NSArray alloc] init];
    externalDevices = [[self deviceManager] getDetectedDevices];
    // Will need to be changed to a generic device object, in order to take
    // into account the possibility of it being an Air Play device.
    if ([[self deviceManager] isConnected] == NO)
    {
      printf("1\n");
      if ([externalDevices count] > 0)
      {
          printf("2\n");
          if([[externalDevices objectAtIndex:indexPath.row] isKindOfClass:[GCKDevice class]])
          {
              printf("3\n");
              GCKDevice * selectedDevice = [externalDevices objectAtIndex:indexPath.row];
              if (_castItem != nil)
              {
                  printf("4\n");
                  NSLog(_castItem.itemName);
                  if ([_castItem.itemURI isKindOfClass:[NSURL class]])
                  {
                    printf("is NSURL (DeviceListTableViewController)\n");
                  }
                  else
                  {
                    printf("is not a NSURL (DeviceListTableViewController)\n");
                  }
                  // Should not transmit media, but should instead make the selected media
                  // available to a Google Cast device, should it require it.
                  /*
                  [[self deviceManager] transmitMedia:(NSURL*)_castItem.itemURI to:selectedDevice]; // I guess that transmitMedia should establish the connection, too
                  */
                  AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                  [[self deviceManager] transmitMedia:[delegate getMediaItem] to:selectedDevice];
                  
              }
          }
          else
          {
              // If an AirPlay device, perform necessary view configuration
              // Uncomment if-statement, once code for AirPlay has been written.
              /*
              if (self.castItem != nil)
              {
                  // Validate that type of selected device is of one of the types required.
                  [_deviceManager transmitMedia:self.castItem.itemURI to:selectedDevice];
              }
              */
          }
      }
    }
    /*
    else if ([[self deviceManager] isCasting])
    {
      // Need to implement presentPlaybackViewController and its corresponding view controller (and associated scence)
      if ([_deviceManager.delegate respondToSelector:@selector(presentPlaybackViewController)])
      {
        [_deviceManager.delegate presentPlaybackViewController];
      }
    }
    */
    else if ([self.deviceManager isConnected])
    {
      // Display View 2

    }

    // Display a message to the user, informing them that the resource transfer
    // is "in process".
    // May need to "dismiss" the view.
    // Uncomment this again.
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}




-(void)reloadData
{
    printf("Called\n");
    [self.tableView reloadData];
}

- (void)deviceConnected{
    printf("devicesNotFound notifier (DeviceListTableViewController)");
    [self.tableView reloadData];
}


-(void)haveAllCastDevicesGoneOffline
{
    printf("haveAllCastDevicesGoneOffline invoked\n");
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failure"
                                                       message:@"Device has gone offline."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    /*
     if ([[[self deviceManager] getDetectedDevices] count] == 0)
     {
     [self devicesNotFound];
     }
     */
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
    printf("deviceDisconnected called. Should reload\n");
    
    [self reloadData];
    [[self view] setNeedsDisplay];
}

# pragma mark - volume
-(void)receivedVolumeChangedNotification:(NSNotification *) notification
{
  if (!_isManualVolumeChange)
  {
    DeviceManager * deviceManager = (DeviceManager *) notification.object;
    //_volumeControlSlider.value = [self deviceManager].getConnectedDeviceVolume;

  }
}

-(void)mediaControlChannelDidUpdateStatus
{
    [self reloadData];
}

/*
-(IBAction)sliderValueChanged:(id)sender
{
  NSLog(@"Device volume adjusted");
  UISlider * slider = (UISlider *) sender;
  _isManualVolumeChange = YES;
    [[self deviceManager]   setConnectedDeviceVolume:slider.value];
  _isManualVolumeChange = NO;
}
 */
- (IBAction)toMediaPlayer:(id)sender {
    [self performSegueWithIdentifier:@"showMediaPlayer" sender:self];
}
@end

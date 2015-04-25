//
//  ViewController.m
//  CastApplication
//
//  Created by Aaron Joyce on 24/02/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "ViewController.h"
#import "ImageUtility.h"
@import AVKit;
@import AVFoundation;
#import "AppDelegate.h"
@import UIKit;

@class AVPlayerItem;


@interface ViewController ()
@property BOOL castButtonEnabled;
@property NSMutableArray * mediaItems;
@property MediaItem * selectedItem;


@end

@implementation ViewController

-(Observer *)observer
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.observer;
}

-(void)setObserver:(Observer *)observer
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.observer = observer;
}

-(ChromeCastDeviceController *) chromecastDeviceController
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}

-(id)init{
    [self devicesNotFound];
    self.itemSet = NO;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesFound) name:(NSString *)CastDevicesHaveComeOnlineNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    // Only notified if, having detected devices over the connected network, those
    // devices are no longer detectable. This is likely raised by a device controller
    // 'manager'.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(haveAllCastDevicesGoneOffline)name:(NSString *)HaveAllCastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesNotFound)name:(NSString *)CastDevicesHaveGoneOfflineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString *)CastDeviceSelectedHasDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString *)CastDeviceSelectedHasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFailedToConnect) name:(NSString *)CastDeviceSelectedFailedToConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedToCastMedia) name:(NSString *)RequestToLoadMediaFailedNotification object:nil];
    self.mediaItems = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showLoadAttemptFailureAlert) name:(NSString *)ShowLoadAttemptFailureAlert object:nil];
    
    [self loadMediaItems];
    self.title = @"Media List";
    // Do any additional setup after loading the view, typically from a nib.
    [[self toMediaPlayer] setTintColor:[UIColor whiteColor]]; // Modify button's aesthetic attributes
    [[self navigationController].navigationBar setTintColor:[UIColor whiteColor]];
    [[self navigationController].navigationBar setBarTintColor:[UIColor orangeColor]];

    self.navigationController.navigationBar.translucent = NO;
    [[self view] setTag:1];
}


-(void)loadMediaItems
{

    MediaItem * item1 = [[MediaItem alloc] init];
    NSURL *mediaURL = [NSURL URLWithString:@"https://www.googleapis.com/youtube/v3/videos?id=uKboLTwzFTs&key=AIzaSyCHM9EWfrPyhghlhVmnkwqbiojb1SBV2l8"];
    item1.itemTitle = @"Come Wander With Me";
    item1.itemURI = mediaURL;    item1.mimeType = @"video/mp4";
    item1.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item1];
    
    MediaItem * item2 = [[MediaItem alloc] init];
    item2.itemTitle = @"Metal Heart";
    item2.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item2.mimeType = @"audio/mp3";
    item2.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item2];
    
    MediaItem * item3 = [[MediaItem alloc] init];
    item3.itemTitle = @"Are You With Me";
    item3.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item3.mimeType = @"audio/mp3";
    item3.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item3];
    
    
    MediaItem * item4 = [[MediaItem alloc] init];
    item4.itemTitle = @"Staying The Night";
    item4.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item4.mimeType = @"audio/mp3";
    item4.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item4];
    
    
    MediaItem * item5 = [[MediaItem alloc] init];
    item5.itemTitle = @"Legacy - Vicetone Remix";
    item5.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item5.mimeType = @"audio/mp3";
    item5.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item5];
    
    
    MediaItem * item6 = [[MediaItem alloc] init];
    item6.itemTitle = @"Ah Yeah - TJR Edit";
    item6.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item6.mimeType = @"audio/mp3";
    item6.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item6];
    
    
    MediaItem * item7 = [[MediaItem alloc] init];
    item7.itemTitle = @"Where We Belong";
    item7.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item7.mimeType = @"audio/mp3";
    item7.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item7];
    
    MediaItem * item8 = [[MediaItem alloc] init];
    item8.itemTitle = @"Red Lights";
    item8.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item8.mimeType = @"audio/mp3";
    item8.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item8];
    
    
    MediaItem * item9 = [[MediaItem alloc] init];
    item9.itemTitle = @"We Are Alone";
    item9.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item9.mimeType = @"audio/mp3";
    item9.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item9];
    
    
    MediaItem * item10 = [[MediaItem alloc] init];
    item10.itemTitle = @"Snake - Original Mix";
    item10.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item10.mimeType = @"audio/mp3";
    item10.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item10];
    
    
    MediaItem * item11 = [[MediaItem alloc] init];
    item11.itemTitle = @"Summer";
    item11.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item11.mimeType = @"audio/mp3";
    item11.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item11];
    
    
    MediaItem * item12 = [[MediaItem alloc] init];
    item12.itemTitle = @"Faith - Radio Edit";
    item12.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item12.mimeType = @"audio/mp3";
    item12.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item12];
    
    MediaItem * item13 = [[MediaItem alloc] init];
    item13.itemTitle = @"Turn It Up - Original Remix";
    item13.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item13.mimeType = @"audio/mp3";
    item13.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item13];
    
    
    MediaItem * item14 = [[MediaItem alloc] init];
    item14.itemTitle = @"Another Love";
    item14.itemURI = [NSURL URLWithString:@"http://api.soundcloud.com/tracks/38299495/stream?consumer_key=901e01074ad2017aa1dd612402d83681"];
    item14.mimeType = @"audio/mp3";
    item14.artworkURL = [NSURL URLWithString:@"https://i1.sndcdn.com/artworks-000019208156-rrdpfk-large.jpg"];
    [self.mediaItems addObject:item14];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];

    [[self chromecastDeviceController] setConnectedDeviceVolume:volume];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"showMediaPlayer"])
    {
        PlaybackViewController * playbackViewController = (PlaybackViewController *)[
                                                                                      segue destinationViewController];
        playbackViewController.selectedMediaItem = self.selectedMediaItem;
        
        if (self.itemSet)
        {
            playbackViewController.loadMedia = YES;
            self.itemSet = NO;
        }
        else
        {
            playbackViewController.loadMedia = NO;
        }
    }
}

#pragma mark - DeviceManagerControllerDelegate

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

-(void)deviceConnected
{
    // Display message to user (to be determined during integation with Sleeve).
}

-(void)haveAllCastDevicesGoneOffline
{}

#pragma mark - Table view data source
// Tells the table how many sections to display
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.mediaItems count];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMovie" sender:self];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaListPrototypeCell" forIndexPath:indexPath];
    // Configure the cell...
    MediaItem * mediaItem = [self.mediaItems objectAtIndex:indexPath.row];
    cell.textLabel.text = mediaItem.itemTitle;
    if (mediaItem.selected)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark GCKMediaControlChannelDelegate
- (void) mediaControlChannel:		(GCKMediaControlChannel *) 	mediaControlChannel
didCompleteLoadWithSessionID:		(NSInteger) 	sessionID
{
    printf("didCompleteLoadWithSessionID\n");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectedMediaItem = [self.mediaItems objectAtIndex:indexPath.row];
    self.selectedMediaItem.selected = !self.selectedMediaItem.selected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    self.itemSet = YES;
    [self performSegueWithIdentifier:@"showMediaPlayer" sender:self];
}


- (IBAction)showMediaPlayer:(id)sender {
    [self performSegueWithIdentifier:@"showMediaPlayer" sender:self];
}
@end

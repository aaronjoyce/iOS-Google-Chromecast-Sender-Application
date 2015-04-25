//
//  MediaItem.h
//  CastApplication
//
//  Created by Aaron Joyce on 08/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GCKMediaTrack.h>

@interface MediaItem : NSObject

@property NSString * itemTitle;
@property NSURL * itemURI;
@property BOOL selected;
@property NSString * mimeType;
@property NSString * itemSubtitle;
@property NSURL * artworkURL;
@property GCKMediaTrack *track;
@end

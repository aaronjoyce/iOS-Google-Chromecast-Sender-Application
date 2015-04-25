//
//  MediaItem.m
//  CastApplication
//
//  Created by Aaron Joyce on 08/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import "MediaItem.h"

@interface MediaItem()

@end

@implementation MediaItem
-(NSString *)getName
{
    return self.itemTitle;
}
-(NSURL *)getURI
{
    return self.itemURI;
}
-(NSString *)getMimeType
{
    return self.mimeType;
}
@end

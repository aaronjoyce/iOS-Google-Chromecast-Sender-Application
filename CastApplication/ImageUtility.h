//
//  ImageUtility.h
//  OT
//
//  Created by Aaron Joyce on 26/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVKit;
@import AVFoundation;
@import UIKit;

@interface ImageUtility : NSObject
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

//
//  Observer.h
//  AnotherTest
//
//  Created by Aaron Joyce on 22/03/2015.
//  Copyright (c) 2015 Aaron Joyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Observer : NSObject
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end

//
//  MusicAppDelegate.h
//  ParldForMac
//
//  Created by sohunjug on 3/2/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPMediaKeyTap.h"

@interface MusicAppDelegate : NSObject <NSApplicationDelegate>
{
    SPMediaKeyTap *keyTap;
}
@property (assign) IBOutlet NSPanel *panel;

@end

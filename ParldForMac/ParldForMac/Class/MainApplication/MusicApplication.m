//
//  MusicNSApplication.m
//  ParldForMac
//
//  Created by sohunjug on 2/27/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicApplication.h"

@implementation MusicApplication

- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}

@end

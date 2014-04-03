//
//  MusicAppDelegate.m
//  ParldForMac
//
//  Created by sohunjug on 3/2/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MusicControl.h"
#import "JSON.h"

@implementation MusicAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.panel setViewsNeedDisplay:YES];
    [self.panel.contentView setWantsLayer:YES];
    self.panel.backgroundColor = [NSColor clearColor];
    [self.panel setOpaque:NO];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
    
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		NSString *debugString;
        debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				[[MusicControl shareMusicControl] playOrPause];
				break;
				
			case NX_KEYTYPE_FAST:
				[[MusicControl shareMusicControl] next];
				break;
				
			case NX_KEYTYPE_REWIND:
                [[MusicControl shareMusicControl] last];
				break;
			default:
                break;
                // More cases defined in hidsystem/ev_keymap.h
                
		}
	}
}

@end

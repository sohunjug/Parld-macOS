//
//  MusicAppDelegate.m
//  ParldForMac
//
//  Created by sohunjug on 3/2/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuList.h"
#import "JSON.h"
#import "ParldInterface.h"
#import "InterfaceAnimation.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation MusicAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //ProcessSerialNumber psn = { 0, kCurrentProcess };
    //TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    //SetFrontProcess(&psn);
    
    [self.panel setViewsNeedDisplay:YES];
    [self.panel.contentView setWantsLayer:YES];
    self.panel.backgroundColor = [NSColor clearColor];
    [self.panel setOpaque:NO];
    [NSApp activateIgnoringOtherApps:YES];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithContentsOfFile:
      [[NSBundle mainBundle] pathForResource:@"ParldConfig" ofType:@"plist"]]];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
    
    [[InterfaceAnimation shareInstance] setParentView:_imageView];
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

- (void)menuAction:(NSMenuItem*)item
{
    if ([item tag] == MenuAbout) {
        [self.about center];
        [self.about makeKeyAndOrderFront:nil];
    }
    else {
        [[MenuList shareInstance] menuAction:item];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    return [[MenuList shareInstance] validateMenuItem:item];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"displaySuspension"])
    {
        [[MenuList shareInstance] displaySuspension] ? [self.panel orderOut:nil] : [self.panel makeKeyAndOrderFront:nil];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

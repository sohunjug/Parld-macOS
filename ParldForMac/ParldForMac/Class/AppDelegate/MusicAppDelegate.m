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
#import "MusicProgressPanel.h"

@implementation MusicAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //ProcessSerialNumber psn = { 0, kCurrentProcess };
    //TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    //SetFrontProcess(&psn);
    
    //[self.panel setViewsNeedDisplay:YES];
    [self.panel.contentView setWantsLayer:YES];
    self.panel.backgroundColor = [NSColor clearColor];
    [self.panel setOpaque:NO];
    [NSApp activateIgnoringOtherApps:YES];
    
    //[[NSUserDefaults standardUserDefaults] registerDefaults:
     //[NSDictionary dictionaryWithContentsOfFile:
      //[[NSBundle mainBundle] pathForResource:@"ParldConfig" ofType:@"plist"]]];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
    
    [[InterfaceAnimation shareInstance] setParentView:_imageView];
    showProgress = NO;
    
    [[MusicProgressPanel shareInstance] addObserver:self forKeyPath:@"usedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[MusicControl shareMusicControl] performSelectorInBackground:@selector(checkUpdate) withObject:nil];
    [self observeValueForKeyPath:@"displaySuspension" ofObject:nil change:nil context:nil];
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

- (void)dragDropFileList:(NSArray *)fileList
{
    [self performSelector:@selector(uploadFileList:) withObject:fileList afterDelay:0];
}

- (void)uploadFileList:(NSArray *)fileList
{
    if(!fileList || [fileList count] <= 0) return;
    
    //while ([[MusicProgressPanel shareInstance] initDone] == NO) {
    //    [[MusicProgressPanel shareInstance] initDic];
    //}
    //[self.progress makeKeyAndOrderFront:nil];
    [self showProgressPanel];
    
    [[[MusicProgressPanel shareInstance] waiting] addObjectsFromArray:fileList];
    for (NSString* temp in [[MusicProgressPanel shareInstance] waiting]) {
        [[[[MusicProgressPanel shareInstance] progressPopUpButton] objectForKey:@"Waiting"] addItemWithTitle:[temp lastPathComponent]];//action:@selector(openInFinder:) keyEquivalent:@""];
        [[[MusicProgressPanel shareInstance] filePath] setObject:temp forKey:[temp lastPathComponent]];
    }
    if ([[MusicProgressPanel shareInstance] usedProgress] < 4) {
        [[ParldInterface shareInstance] uploadMusic:[[[MusicProgressPanel shareInstance] waiting] objectAtIndex:0]];
        [[[[MusicProgressPanel shareInstance] progressPopUpButton] objectForKey:@"Waiting"] removeItemWithTitle:[[[MusicProgressPanel shareInstance] waiting] objectAtIndex:0]];
        [[[MusicProgressPanel shareInstance] waiting] removeObjectAtIndex:0];
    }
}

- (void)initProgressPanel
{
    if (!attachedWindow) {
        [[MusicProgressPanel shareInstance] initDic];
        NSPoint buttonPoint = NSMakePoint(NSMidX([self.imageView frame]),
                                          NSMidY([self.imageView frame]));
        attachedWindow = [[MAAttachedWindow alloc] initWithView:self.progress
                                                attachedToPoint:buttonPoint
                                                       inWindow:[self.imageView window]
                                                         onSide:12
                                                     atDistance:WC+WO*2];
        [attachedWindow setBorderColor:[NSColor whiteColor]];
        [attachedWindow setHasArrow:YES];
        [attachedWindow setDrawsRoundCornerBesideArrow:YES];
        [attachedWindow setArrowBaseWidth:5.0];
    }
}

- (void)showProgressPanel
{
    [self initProgressPanel];
    [[self.imageView window] addChildWindow:attachedWindow ordered:NSWindowAbove];
}

- (void)hideProgressPanel
{
    [[self.imageView window] removeChildWindow:attachedWindow];
    [attachedWindow orderOut:self];
}

- (void)menuAction:(NSMenuItem*)item
{
    if ([item tag] == MenuAbout) {
        [self.about center];
        [self.about makeKeyAndOrderFront:nil];
    }
    else if ([item tag] == MenuUpload) {
        [self showProgressPanel];
    }
    else if ([item tag] == MenuHelp) {
        [[MusicControl shareMusicControl] sendNotification];
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
    if ([keyPath isEqualToString:@"displaySuspension"]) {
        [[MenuList shareInstance] displaySuspension] ? [self.panel orderOut:nil] : [self.panel makeKeyAndOrderFront:nil];
    }
    else if ([keyPath isEqualToString:@"usedProgress"]) {
        if ([[MusicProgressPanel shareInstance] usedProgress] < 4 && [[[MusicProgressPanel shareInstance] waiting] count] > 0) {
            [[ParldInterface shareInstance] uploadMusic:[[[MusicProgressPanel shareInstance] waiting] objectAtIndex:0]];
            [[[[MusicProgressPanel shareInstance] progressPopUpButton] objectForKey:@"Waiting"] removeItemWithTitle:[[[[MusicProgressPanel shareInstance] waiting] objectAtIndex:0] lastPathComponent]];
            [[[MusicProgressPanel shareInstance] waiting] removeObjectAtIndex:0];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)openInFinder:(NSMenuItem*)item
{
    NSString *exepath = [NSString stringWithFormat:@"/usr/bin/open -R %@", [[[MusicProgressPanel shareInstance] filePath] objectForKey:[item title]]];
    execl([exepath UTF8String], NULL);
}

@end

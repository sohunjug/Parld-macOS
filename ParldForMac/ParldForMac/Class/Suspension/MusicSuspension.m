//
//  MusicSuspension.m
//  ParldForMac
//
//  Created by sohunjug on 2/27/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicSuspension.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuList.h"
#import "ParldInterface.h"
#import "InterfaceAnimation.h"

@implementation MusicSuspension

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSURLPboardType, nil]];
        self.image.backgroundColor = [NSColor clearColor];
    }
    [self.window setLevel:NSFloatingWindowLevel];
    [self setMenu:[[MenuList shareInstance] suspensionMenu]];
    return self;
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
    
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
	}
    
	return NSDragOperationNone;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    if(self.musicControl && [self.musicControl respondsToSelector:@selector(dragDropFileList:)])
        [self.musicControl dragDropFileList:list];
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CAKeyframeAnimation *pulse = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    pulse.duration = 0.2;
    pulse.repeatCount = 1;
    pulse.autoreverses = YES;
    
    pulse.values = [NSArray arrayWithObjects:[NSImage imageNamed:@"B.png"],nil];
    [self.layer addAnimation:pulse forKey:nil];
    [[MusicControl shareMusicControl] playOrPause];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[[ParldInterface shareInstance] LOCK] lock];
    [[InterfaceAnimation shareInstance] setIsDisplay:YES];
    [[[ParldInterface shareInstance] LOCK] unlock];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[[ParldInterface shareInstance] LOCK] lock];
    [[InterfaceAnimation shareInstance] setIsDisplay:NO];
    [[[ParldInterface shareInstance] LOCK] unlock];
}

- (void)createTrackingArea
{
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveAlways;
    focusTrackingAreaOptions |= NSTrackingMouseEnteredAndExited;
    focusTrackingAreaOptions |= NSTrackingAssumeInside;
    focusTrackingAreaOptions |= NSTrackingInVisibleRect;
    
    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                     options:focusTrackingAreaOptions owner:self userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setMenu:[[MenuList shareInstance] suspensionMenu]];
    if ([[MenuList shareInstance] displaySuspension]) {
        [self.window orderOut:nil];
    }
    [self createTrackingArea];
}

@end

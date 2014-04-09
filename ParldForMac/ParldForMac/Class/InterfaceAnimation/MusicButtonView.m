//
//  MusicButtonView.m
//  ParldForMac
//
//  Created by sohunjug on 4/5/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicButtonView.h"
#import "InterfaceAnimation.h"
#import "ParldInterface.h"

@implementation MusicButtonView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.window setLevel:NSFloatingWindowLevel];
        [self createTrackingArea];
        first = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[[ParldInterface shareInstance] LOCK] lock];
    [[InterfaceAnimation shareInstance] setIsDisplay:YES];
    first = YES;
    [[[ParldInterface shareInstance] LOCK] unlock];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[[ParldInterface shareInstance] LOCK] lock];
    if (first) {
        [[InterfaceAnimation shareInstance] setIsDisplay:NO];
        first = NO;
    }
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

@end

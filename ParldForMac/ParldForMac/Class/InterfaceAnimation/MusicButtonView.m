//
//  MusicButtonView.m
//  ParldForMac
//
//  Created by sohunjug on 4/5/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicButtonView.h"
#import "InterfaceAnimation.h"

@implementation MusicButtonView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.window setLevel:NSFloatingWindowLevel];
        [self createTrackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[InterfaceAnimation shareInstance] setIsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[InterfaceAnimation shareInstance] setIsDisplay:NO];
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

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

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    if(self.musicControl && [self.musicControl respondsToSelector:@selector(dragDropFileList:)])
        [self.musicControl dragDropFileList:list];
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CABasicAnimation *FlipAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	FlipAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	FlipAnimation.toValue= [NSNumber numberWithFloat:M_PI];
	FlipAnimation.duration=0.3;
	//FlipAnimation.fillMode=kCAFillModeForwards;
    FlipAnimation.autoreverses = YES;
    
	[self.layer addAnimation:FlipAnimation forKey:nil];
    
    [[MusicControl shareMusicControl] playOrPause];
}

- (CGImageRef)NSImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)CFBridgingRetain(imageData),  NULL);
    
    imageRef = CGImageSourceCreateImageAtIndex(
                                               imageSource, 0, NULL);
    return imageRef;
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
    [self.window.contentView setWantsLayer:YES];
    [self setMenu:[[MenuList shareInstance] suspensionMenu]];
    [[InterfaceAnimation shareInstance] setMainView:self];
    if ([[MenuList shareInstance] displaySuspension]) {
        [self.window orderOut:nil];
    }
    [self createTrackingArea];
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.frame.size.width, self.frame.size.height);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.layer.position = CGPointMake(W, W);
}

@end

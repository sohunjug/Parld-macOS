//
//  MusicMainWindow.m
//  ParldForMac
//
//  Created by sohunjug on 2/27/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicMainPanel.h"
#import <QuartzCore/QuartzCore.h>

@implementation MusicMainPanel

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setStyleMask:NSBorderlessWindowMask | NSNonactivatingPanelMask];
    [self setLevel:NSMainMenuWindowLevel];
    [[self contentView] setWantsLayer:YES];
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}


- (BOOL)canBecomeMainWindow {
    return YES;
}


- (void)handleMoveOrResize:(NSEvent *)event {
    NSWindow *window = self;
    
    //
    // Work out how much the mouse has moved
    //
    NSPoint newMouseLocation = [window convertBaseToScreen:[event locationInWindow]];
    NSPoint delta = NSMakePoint(newMouseLocation.x - mouseDownLocation.x,
                                newMouseLocation.y - mouseDownLocation.y);
    
    NSRect newFrame = mouseDownWindowFrame;
    
    if (!mouseDownInResizeArea) {
        newFrame.origin.x += delta.x;
        newFrame.origin.y += delta.y;
        
    } else {
        NSSize maxSize = [window maxSize];
        NSSize minSize = [window minSize];
        
        newFrame.size.width += delta.x;
        newFrame.size.height -= delta.y;
        
        newFrame.size.width = MIN(MAX(newFrame.size.width, minSize.width), maxSize.width);
        newFrame.size.height = MIN(MAX(newFrame.size.height, minSize.height), maxSize.height);
        newFrame.origin.y -= newFrame.size.height - mouseDownWindowFrame.size.height;
    }
    
    [window setFrame:newFrame display:YES animate:NO];
}


- (void)sendEvent:(NSEvent *)event {
    // 处理单击事件，实现在窗口任意位置移动窗口
    // 判断鼠标点击所在位置的 view，如果是 NSTextView，就不处理，直接继续传递事件
    NSView *targetView = [self.contentView hitTest:[event locationInWindow]];
    if (event.type == NSLeftMouseDown && ![targetView isKindOfClass:[NSTextView class]]) {
        mouseDraggedForMoveOrResize = NO;
        mouseDownLocation = [self convertBaseToScreen:[event locationInWindow]];
        mouseDownWindowFrame = [self frame];
        //mouseDownInResizeArea = NSPointInRect([event locationInWindow], [self resizeAreaRect]);
        
        BOOL keepOn = YES;
        
        while (keepOn) {
            NSEvent *newEvent = [self nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                                  untilDate:[NSDate distantFuture]
                                                     inMode:NSEventTrackingRunLoopMode
                                                    dequeue:NO];
            switch (newEvent.type) {
                case NSLeftMouseDragged:
                    // 处理鼠标移动事件
                    [self handleMoveOrResize:newEvent];
                    // 把事件从队列中删除
                    [self nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
                    mouseDraggedForMoveOrResize = YES;
                    break;
                    
                case NSLeftMouseUp:
                    // 如果不是正在移动窗口或改变窗口大小，就把事件继续分发
                    if (!mouseDraggedForMoveOrResize) {
                        [super sendEvent:event];
                        //[musicButtons changeViews];
                    }
                    keepOn = NO;
                    break;
                    
                default:
                    keepOn = NO;
                    break;
            }
        }
        
    } else {
        [super sendEvent:event];
    }
}

@end

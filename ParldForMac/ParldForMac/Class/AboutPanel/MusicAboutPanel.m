//
//  MusicAboutWindow.m
//  ParldForMac
//
//  Created by sohunjug on 2/28/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicAboutPanel.h"

@implementation MusicAboutPanel

- (BOOL)canBecomeKeyWindow {
    return YES;
}


- (BOOL)canBecomeMainWindow {
    return YES;
}


- (NSRect)resizeAreaRect {
    const CGFloat resizeBoxSize = 20.0;
    
    // 窗口右下角 20x20 的区域为改变窗口的区域
    NSRect frame = [self frame];
    NSRect resizeRect = NSMakeRect(frame.size.width - resizeBoxSize, 0,
                                   resizeBoxSize, resizeBoxSize);
    
    return resizeRect;
}

- (void)sendEvent:(NSEvent *)event {
    // 处理单击事件，实现在窗口任意位置移动窗口
    // 判断鼠标点击所在位置的 view，如果是 NSTextView，就不处理，直接继续传递事件
    NSView *targetView = [self.contentView hitTest:[event locationInWindow]];
    if (event.type == NSLeftMouseDown && ![targetView isKindOfClass:[NSTextView class]]) {
            NSEvent *newEvent = [self nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                                  untilDate:[NSDate distantFuture]
                                                     inMode:NSEventTrackingRunLoopMode
                                                    dequeue:NO];
            switch (newEvent.type) {
                case NSLeftMouseDragged:
                    
                    [self nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
                    break;
                    
                case NSLeftMouseUp:
                    [self orderOut:nil];
                    break;
                    
                default:
                    
                    break;
        }
        
    } else {
        [super sendEvent:event];
    }
}

@end

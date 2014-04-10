//
//  MusicAboutWindow.m
//  ParldForMac
//
//  Created by sohunjug on 2/28/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicAboutPanel.h"

#define	SCROLL_DELAY_SECONDS	0.05
#define SCROLL_AMOUNT_PIXELS	1.60
#define SCROLL_AMOUNT_COUNT     200.00
#define	BLANK_LINE_COUNT		8

@implementation MusicAboutPanel

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setLevel:NSFloatingWindowLevel];
    [self createPanelToDisplay];
    [self displayVersionInfo];
    [self loadTextToScroll];
    [self setScrollAmount: 0.0];
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}


- (BOOL)canBecomeMainWindow {
    return YES;
}


- (NSRect)resizeAreaRect {
    const CGFloat resizeBoxSize = 0.0;
    
    // 窗口右下角 20x20 的区域为改变窗口的区域
    NSRect frame = [self frame];
    NSRect resizeRect = NSMakeRect(frame.size.width - resizeBoxSize, 0,
                                   resizeBoxSize, resizeBoxSize);
    
    return resizeRect;
}

- (void)sendEvent:(NSEvent *)event {
    // 处理单击事件，实现在窗口任意位置移动窗口
    // 判断鼠标点击所在位置的 view，如果是 NSTextView，就不处理，直接继续传递事件
    //NSView *targetView = [self.contentView hitTest:[event locationInWindow]];
    if (event.type == NSLeftMouseDown /*&& ![targetView isKindOfClass:[NSTextView class]]*/) {
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

- (void) createPanelToDisplay
{
    [self setBackgroundColor:[NSColor whiteColor]];
    [self setHasShadow:YES];
}

- (void) displayVersionInfo
{
    NSString *value;
    
    value = [[NSString alloc] initWithFormat:@"%@  v%@ (%@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Application Version Type"],
             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    if (value != nil)
    {
        [shortInfoField setStringValue: value];
    }
    
    value = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (value != nil)
    {
        value = [@"Version " stringByAppendingString:value];
        //[versionField setStringValue: value];
    }
}

#pragma mark -
#pragma mark 跑马灯

- (NSAttributedString *) textToScroll
{
    NSString *path;
    path = [[NSBundle mainBundle] pathForResource: @"Credits" ofType: @"rtf"];
    return [[NSMutableAttributedString alloc] initWithPath:path documentAttributes:NULL];
}

- (void)loadTextToScroll
{
    NSMutableAttributedString *textToScroll = [[NSMutableAttributedString alloc] initWithString:@" "];
    NSAttributedString *newline;
    
    newline = [[NSAttributedString alloc] initWithString: @"\n"];
    
    //for (NSInteger i = 0; i < BLANK_LINE_COUNT; i++)
    //    [textToScroll appendAttributedString:newline];
    
    [textToScroll appendAttributedString:[[self textToScroll] mutableCopy]];
    
    //for (NSInteger i = 0; i < BLANK_LINE_COUNT; i++)
    //    [textToScroll appendAttributedString:newline];
    
    [[textView textStorage] setAttributedString:textToScroll];
}

- (void)setScrollAmount:(float)newAmount
{
    if (newAmount - SCROLL_AMOUNT_COUNT > 0) {
        [self setScrollAmount: 0.0];
    }
    else {
        [[textScrollView documentView] scrollPoint:NSMakePoint(0.0, newAmount)];
    }
    // If anything overlaps the text we just scrolled, it won’t get redraw by the
    // scrolling, so force everything in that part of the panel to redraw.
    {
        NSRect scrollViewFrame;
        
        // Find where the scrollview’s bounds are, then convert to panel’s coordinates
        scrollViewFrame = [textScrollView bounds];
        scrollViewFrame = [[self contentView] convertRect:scrollViewFrame fromView:textScrollView];
        
        // Redraw everything which overlaps it.
        [[self contentView] setNeedsDisplayInRect: scrollViewFrame];
    }
}

// Scroll one frame of animation
- (void)scrollOneUnit
{
    float currentScrollAmount;
    
    // How far have we scrolled so far?
    currentScrollAmount = [textScrollView documentVisibleRect].origin.y;
    
    // Scroll one unit more
    [self setScrollAmount:(currentScrollAmount + SCROLL_AMOUNT_PIXELS)];
}

// If we don't already have a timer, start one messaging us regularly
- (void)startScrollingAnimation
{
    // Already scrolling?
    if (scrollingTimer != nil)
        return;
    
    // Start a timer which will send us a 'scrollOneUnit' message regularly
    scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_DELAY_SECONDS
                                                      target:self
                                                    selector:@selector(scrollOneUnit)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopScrollingAnimation
{
    [scrollingTimer invalidate];
    
    scrollingTimer = nil;
}


@end

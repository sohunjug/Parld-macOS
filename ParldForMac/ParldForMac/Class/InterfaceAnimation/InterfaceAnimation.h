//
//  InterfaceAnimation.h
//  ParldForMac
//
//  Created by sohunjug on 4/4/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicButtonView.h"

@interface InterfaceAnimation : NSObject
{
    MusicButtonView *help;
    MusicButtonView *last;
    MusicButtonView *next;
    MusicButtonView *refresh;
    IBOutlet NSImageView *cdView;
    BOOL _isDisplay;
    BOOL done;
}

@property (retain) NSView* parentView;
@property (retain) NSImageView* mainView;
@property (assign) BOOL isDisplay;
@property (nonatomic) CGAffineTransform cdOriginalTranform;
@property (nonatomic, strong) NSTimer *cdTimer;

+ (InterfaceAnimation*)shareInstance;
- (void)beginTimer;
- (void)restartCDAnimation;
- (void)startCDAnimation;
- (void)stopCDAnimation;
- (void)pauseCDAnimation;
- (void)resumeCDAnimation;
@end

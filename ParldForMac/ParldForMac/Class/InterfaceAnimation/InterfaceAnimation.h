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
    BOOL _isDisplay;
    BOOL done;
}

@property (retain) NSView* parentView;
@property (assign) BOOL isDisplay;

+ (InterfaceAnimation*)shareInstance;
@end

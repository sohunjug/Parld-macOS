//
//  MusicAppDelegate.h
//  ParldForMac
//
//  Created by sohunjug on 3/2/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPMediaKeyTap.h"
#import "MusicSuspension.h"
#import "MusicProgressPanel.h"
#import "MAAttachedWindow.h"

@interface MusicAppDelegate : NSObject <NSApplicationDelegate, DragDropDelegate>
{
    SPMediaKeyTap *keyTap;
    MAAttachedWindow *attachedWindow;
    BOOL showProgress;
}
@property (assign) IBOutlet NSPanel *panel;
@property (assign) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSPanel *about;
@property (assign) IBOutlet NSView *progress;
@property (retain) NSMutableArray* uploadList;

@end

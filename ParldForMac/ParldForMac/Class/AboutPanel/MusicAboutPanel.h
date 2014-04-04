//
//  MusicAboutWindow.h
//  ParldForMac
//
//  Created by sohunjug on 2/28/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MusicAboutPanel : NSPanel
{
    IBOutlet NSScrollView		*textScrollView;
    IBOutlet NSTextView			*textView;
    IBOutlet NSTextField		*versionField;
    IBOutlet NSTextField		*shortInfoField;
    NSTimer						*scrollingTimer;
}
@end

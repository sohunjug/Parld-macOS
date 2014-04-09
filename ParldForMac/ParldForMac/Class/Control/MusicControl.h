//
//  MusicControl.h
//  ParldForMac
//
//  Created by sohunjug on 3/30/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "THUserNotification.h"

typedef enum {
    MusicInit = 0,
    MusicPlaying,
    MusicPause,
    MusicStop
}MusicState;

@interface MusicControlValue : NSObject
{
    NSInteger playIndex;
    AudioStreamer *streamer;
    BOOL _playAtLaunch;
    MusicState nowState;
    MusicState lastState;
    NSArray *musicList;
}

@property(retain) AudioStreamer *streamer;
@property(retain) NSArray *musicList;
@property(assign) NSInteger playIndex;
@property(assign) MusicState nowState;
@property(assign) MusicState lastState;
@property(assign) BOOL playAtLaunch;

+ (MusicControlValue*)shareInstance;
- (void)refresh;

@end

@interface MusicControl : NSObject <THUserNotificationCenterDelegate>

+ (MusicControl *)shareMusicControl;
- (void)playOrPause;
- (void)play;
- (void)pause;
- (void)stop;
- (void)refresh;
- (void)last;
- (void)next;

@end
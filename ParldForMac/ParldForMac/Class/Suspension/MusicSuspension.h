//
//  MusicSuspension.h
//  ParldForMac
//
//  Created by sohunjug on 2/27/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DragDropDelegate <NSObject>

- (void)dragDropFileList:(NSArray*)fileList;

@end

@interface MusicSuspension : NSImageView
{
    NSLock* LOCK;
}

@property (assign) IBOutlet id<DragDropDelegate> musicControl;

@end

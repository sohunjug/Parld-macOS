//
//  MusicMainWindow.h
//  ParldForMac
//
//  Created by sohunjug on 2/27/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MusicMainPanel : NSPanel
{
    BOOL            mouseDraggedForMoveOrResize;
    BOOL            mouseDownInResizeArea;
    NSPoint         mouseDownLocation;
    NSRect          mouseDownWindowFrame;
    BOOL            _isRemove;
}
@end

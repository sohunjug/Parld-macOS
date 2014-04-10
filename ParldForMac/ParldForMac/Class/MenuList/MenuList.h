//
//  MenuList.h
//  ParldForMac
//
//  Created by sohunjug on 4/3/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicControl.h"
#import "LaunchAtLoginController.h"

typedef enum {
    MenuPlay = 56789000,
    MenuPause,
    MenuStop,
    MenuRefresh,
    MenuLast,
    MenuNext,
    MenuCloud,
    MenuDisplaySuspension,
    MenuPlayAtLaunch,
    MenuLaunchAtLogin,
    MenuHelp,
    MenuAbout,
    MenuExit,
    MenuUpload,
    MenuUploadDone,
    MenuUploadFail,
    MenuUploadWaiting,
    MenuTheme,
    MenuSimple,
    MenuCool
}MMenuListAction;

@interface MenuList : NSObject
{
    NSStatusItem *statusItem;
    NSMenu *systemBarMenu;
    NSMenu *suspensionMenu;
    NSDictionary *menuList;
    BOOL _displaySuspension;
    BOOL _playAtLaunch;
    BOOL _launchAtLogin;
    BOOL _theme;
    LaunchAtLoginController *launchAtLoginController;
}

@property (retain) NSMenu *systemBarMenu;
@property (retain) NSMenu *suspensionMenu;
@property (assign) BOOL displaySuspension;
@property (assign) BOOL playAtLaunch;
@property (assign) BOOL launchAtLogin;
@property (assign) BOOL theme;

+ (MenuList*)shareInstance;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (void)menuAction:(NSMenuItem*)item;

@end

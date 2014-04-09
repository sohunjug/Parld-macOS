//
//  MenuList.m
//  ParldForMac
//
//  Created by sohunjug on 4/3/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MenuList.h"
#import "ParldInterface.h"

static MenuList * _menuList;

@implementation MenuList

@synthesize systemBarMenu;
@synthesize suspensionMenu;
@synthesize displaySuspension = _displaySuspension;
@synthesize playAtLaunch = _playAtLaunch;
@synthesize launchAtLogin = _launchAtLogin;

- (id)init
{
    if (self = [super init]) {
        launchAtLoginController = [[LaunchAtLoginController alloc] init];
        [self initStatusItem];
    }
    return self;
}

+ (MenuList*)shareInstance
{
    if (_menuList == nil)
    {
        _menuList = [[MenuList alloc] init];
    }
    return _menuList;
}

- (void)initStatusItem
{
    self.displaySuspension = [[NSUserDefaults standardUserDefaults] boolForKey:@"displaySuspension"];
    self.playAtLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"playAtLaunch"];
    self.launchAtLogin = launchAtLoginController.launchAtLogin;
    
    [self addObserver:self forKeyPath:@"displaySuspension" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:self forKeyPath:@"playAtLaunch" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:self forKeyPath:@"launchAtLogin" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:[[NSApplication sharedApplication] delegate] forKeyPath:@"displaySuspension" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setImage:[NSImage imageNamed:@"systemBar"]];
    [[statusItem image] setScalesWhenResized:NO];
    [statusItem setHighlightMode:NO];
    [statusItem setTitle:@""];
    
    
    systemBarMenu = [[NSMenu alloc] initWithTitle:@"音乐汇聚"];
    suspensionMenu = [[NSMenu alloc] initWithTitle:@"音乐汇聚"];
    NSMenuItem *newItem;
    NSMutableDictionary *listTemp = [NSMutableDictionary dictionaryWithCapacity:12];
    
    unichar chr = NSF8FunctionKey;
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"play", nil) action:@selector(menuAction:) keyEquivalent:[NSString stringWithCharacters:&chr length:1]];
    [newItem setEnabled:YES];
    [newItem setTag:MenuPlay];
    [newItem setKeyEquivalentModifierMask:NSFunctionKeyMask];
    [listTemp setObject:newItem forKey:@"play"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"pause", nil) action:@selector(menuAction:) keyEquivalent:[NSString stringWithCharacters:&chr length:1]];
    [newItem setEnabled:YES];
    [newItem setTag:MenuPause];
    [newItem setKeyEquivalentModifierMask:NSFunctionKeyMask];
    [listTemp setObject:newItem forKey:@"pause"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"stop", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuStop];
    [listTemp setObject:newItem forKey:@"stop"];
    
    chr = NSF7FunctionKey;
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"last", nil) action:@selector(menuAction:) keyEquivalent:[NSString stringWithCharacters:&chr length:1]];
    [newItem setEnabled:YES];
    [newItem setTag:MenuLast];
    [newItem setKeyEquivalentModifierMask:NSFunctionKeyMask];
    [listTemp setObject:newItem forKey:@"last"];
    
    chr = NSF9FunctionKey;
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"next", nil) action:@selector(menuAction:) keyEquivalent:[NSString stringWithCharacters:&chr length:1]];
    [newItem setEnabled:YES];
    [newItem setTag:MenuNext];
    [newItem setKeyEquivalentModifierMask:NSFunctionKeyMask];
    [listTemp setObject:newItem forKey:@"next"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"update music pool", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuRefresh];
    [listTemp setObject:newItem forKey:@"update"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"cloud", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuCloud];
    [listTemp setObject:newItem forKey:@"online"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"upload", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuUpload];
    [listTemp setObject:newItem forKey:@"upload"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"launch at login", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuLaunchAtLogin];
    [listTemp setObject:newItem forKey:@"launchatlogin"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"play at launch", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuPlayAtLaunch];
    [listTemp setObject:newItem forKey:@"playatlaunch"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"appear suspension", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuDisplaySuspension];
    [listTemp setObject:newItem forKey:@"displaySuspension"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"about", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuAbout];
    [listTemp setObject:newItem forKey:@"about"];
    
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"quit", nil) action:@selector(menuAction:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTag:MenuExit];
    [listTemp setObject:newItem forKey:@"exit"];
    
    menuList = [[NSDictionary alloc] initWithDictionary:listTemp];
    [systemBarMenu addItem:[menuList objectForKey:@"play"]];
    [systemBarMenu addItem:[menuList objectForKey:@"pause"]];
    [systemBarMenu addItem:[menuList objectForKey:@"stop"]];
    [systemBarMenu addItem:[menuList objectForKey:@"last"]];
    [systemBarMenu addItem:[menuList objectForKey:@"next"]];
    [systemBarMenu addItem:[NSMenuItem separatorItem]];
    [systemBarMenu addItem:[menuList objectForKey:@"update"]];
    [systemBarMenu addItem:[menuList objectForKey:@"online"]];
    [systemBarMenu addItem:[menuList objectForKey:@"upload"]];
    [systemBarMenu addItem:[NSMenuItem separatorItem]];
    [systemBarMenu addItem:[menuList objectForKey:@"launchatlogin"]];
    [systemBarMenu addItem:[menuList objectForKey:@"playatlaunch"]];
    [systemBarMenu addItem:[menuList objectForKey:@"displaySuspension"]];
    [systemBarMenu addItem:[NSMenuItem separatorItem]];
    [systemBarMenu addItem:[menuList objectForKey:@"about"]];
    [systemBarMenu addItem:[menuList objectForKey:@"exit"]];
    
    [statusItem setMenu:systemBarMenu];
    
    [suspensionMenu addItem:[[menuList objectForKey:@"update"] copy]];
    [suspensionMenu addItem:[[menuList objectForKey:@"online"] copy]];
    [suspensionMenu addItem:[[menuList objectForKey:@"upload"] copy]];
    [suspensionMenu addItem:[NSMenuItem separatorItem]];
    [suspensionMenu addItem:[[menuList objectForKey:@"displaySuspension"] copy]];
    [suspensionMenu addItem:[[menuList objectForKey:@"about"] copy]];
    [suspensionMenu addItem:[[menuList objectForKey:@"exit"] copy]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"displaySuspension"]) {
        NSLog(@"%hhd", self.displaySuspension);
        [[NSUserDefaults standardUserDefaults] setBool:self.displaySuspension forKey:@"displaySuspension"];
    }
    else if ([keyPath isEqualToString:@"playAtLaunch"]) {
        NSLog(@"%hhd", self.playAtLaunch);
        [[NSUserDefaults standardUserDefaults] setBool:self.playAtLaunch forKey:@"playAtLaunch"];
    }
    else if ([keyPath isEqualToString:@"launchAtLogin"]) {
        launchAtLoginController.launchAtLogin = self.launchAtLogin;
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playMusic
{
    [[MusicControl shareMusicControl] play];
}

- (void)pauseMusic
{
    [[MusicControl shareMusicControl] pause];
}

- (void)stopMusic
{
    [[MusicControl shareMusicControl] stop];
}

- (void)lastMusic
{
    [[MusicControl shareMusicControl] last];
}

- (void)nextMusic
{
    [[MusicControl shareMusicControl] next];
}

- (void)refreshMusic
{
    [[MusicControl shareMusicControl] refresh];
}

- (void)gotoOnline
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", ParldWebSite]]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if ([item tag] == MenuLaunchAtLogin) {
        [item setState:(self.launchAtLogin ? NSOnState : NSOffState)];
    }
    else if ([item tag] == MenuPlayAtLaunch) {
        [item setState:(self.playAtLaunch ? NSOnState : NSOffState)];
    }
    else if ([item tag] == MenuDisplaySuspension) {
        self.displaySuspension ? [item setTitle:NSLocalizedString(@"appear suspension", nil)] : [item setTitle:NSLocalizedString(@"disappear suspension", nil)];
    }
    else if ([item tag] == MenuPlay) {
        [item setHidden:([[MusicControlValue shareInstance] nowState] == MusicInit
                         || [[MusicControlValue shareInstance] nowState] == MusicStop
                         || [[MusicControlValue shareInstance] nowState] == MusicPause) ? NO : YES];
    }
    else if ([item tag] == MenuPause || [item tag] == MenuStop) {
        [item setHidden:[[MusicControlValue shareInstance] nowState] == MusicPlaying ? NO : YES ];
    }
    else if ([item tag] == MenuNext || [item tag] == MenuLast) {
        [item setHidden:[[MusicControlValue shareInstance] nowState] != MusicInit ? NO : YES ];
    }
    return YES;
}

- (void)menuAction:(NSMenuItem*)item
{
    if ([item tag] == MenuPlay) {
        [self playMusic];
    }
    else if ([item tag] == MenuPause) {
        [self pauseMusic];
    }
    else if ([item tag] == MenuStop) {
        [self stopMusic];
    }
    else if ([item tag] == MenuLast) {
        [self lastMusic];
    }
    else if ([item tag] == MenuNext) {
        [self nextMusic];
    }
    else if ([item tag] == MenuRefresh) {
        [self refreshMusic];
    }
    else if ([item tag] == MenuCloud) {
        [self gotoOnline];
    }
    else if ([item tag] == MenuDisplaySuspension) {
        self.displaySuspension = self.displaySuspension ? NO : YES;
    }
    else if ([item tag] == MenuLaunchAtLogin) {
        self.launchAtLogin = self.launchAtLogin ? NO : YES;
    }
    else if ([item tag] == MenuPlayAtLaunch) {
        self.playAtLaunch = self.playAtLaunch ? NO : YES;
    }
    else if ([item tag] == MenuExit) {
        [NSApp terminate:nil];
    }
}

@end

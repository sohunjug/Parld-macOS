//
//  MusicProcessPanel.m
//  ParldForMac
//
//  Created by sohunjug on 4/5/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MusicProgressPanel.h"
#import "MenuList.h"

static MusicProgressPanel * _Music_Progress_Panel_;

@implementation MusicProgressPanel

@synthesize view;
@synthesize progressDic;
@synthesize progressPopUpButton;
@synthesize waiting;
@synthesize filePath;

- (id)init
{
    if (self = [super init]) {
        waiting = [[NSMutableArray alloc] init];
        filePath = [[NSMutableDictionary alloc] init];
    }
    _Music_Progress_Panel_ = self;
    return self;
}

- (void)initDic
{
    NSTextField* title = [[NSTextField alloc] initWithFrame:NSMakeRect(PROGRESS_X, PROGRESS_Y+PROGRESS_S, PROGRESS_W-PROGRESS_X, PROGRESS_H)];
    
    [title setEditable:NO];
    [title setDrawsBackground:NO];
    [title setBackgroundColor:[NSColor clearColor]];
    [title setAlignment:NSLeftTextAlignment];
    [title setBordered:NO];
    [title setTextColor:[NSColor whiteColor]];
    
    [title setStringValue:@"Upload Music List:"];
    [self.view addSubview:title];
    
    NSMutableDictionary* tempProgressDic = [[NSMutableDictionary alloc] initWithCapacity:4];
    for (NSInteger i = 0; i < 4; i++) {
        NSTextField* titleView = [[NSTextField alloc] initWithFrame:NSMakeRect(PROGRESS_X, PROGRESS_Y-(PROGRESS_S*2)*i, PROGRESS_W-PROGRESS_X, PROGRESS_H)];
        NSProgressIndicator* progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(PROGRESS_X, PROGRESS_Y-PROGRESS_S-(PROGRESS_S*2)*i, PROGRESS_P, PROGRESS_H)];
        NSTextField* progressValue = [[NSTextField alloc] initWithFrame:NSMakeRect(PROGRESS_X+PROGRESS_P+PROGRESS_M, PROGRESS_Y-PROGRESS_S-(PROGRESS_S*2)*i, PROGRESS_W-PROGRESS_M-PROGRESS_X-PROGRESS_P, PROGRESS_H)];
        NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [titleView setEditable:NO];
        [titleView setDrawsBackground:NO];
        [titleView setBackgroundColor:[NSColor clearColor]];
        [titleView setAlignment:NSLeftTextAlignment];
        [titleView setBordered:NO];
        [titleView setTextColor:[NSColor whiteColor]];
        [titleView setHidden:YES];
        
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setHidden:YES];
        
        [progressValue setEditable:NO];
        [progressValue setDrawsBackground:NO];
        [progressValue setBackgroundColor:[NSColor clearColor]];
        [progressValue setAlignment:NSRightTextAlignment];
        [progressValue setBordered:NO];
        [progressValue setTextColor:[NSColor whiteColor]];
        [progressValue setHidden:YES];
        
        [self.view addSubview:titleView];
        [self.view addSubview:progressIndicator];
        [self.view addSubview:progressValue];
        [temp setObject:progressValue forKey:@"progressValue"];
        [temp setObject:titleView forKey:@"title"];
        [temp setObject:progressIndicator forKey:@"progress"];
        [temp setObject:[NSString stringWithFormat:@"NO"] forKey:@"isUsed"];
        [tempProgressDic setObject:temp forKey:[NSString stringWithFormat:@"progress%ld", i]];
        [progressIndicator addObserver:self forKeyPath:@"doubleValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        progressDic = [[NSDictionary alloc] initWithDictionary:tempProgressDic];
    }
    
    tempProgressDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSPopUpButton* temp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(PROGRESS_X, PROGRESS_X, PROGRESS_S*3, PROGRESS_H) pullsDown:YES];
    [temp setBezelStyle:NSRoundedBezelStyle];
    [temp setTag:MenuUploadDone];
    [temp addItemWithTitle:@"Done"];
    [tempProgressDic setObject:temp forKey:@"Done"];
    [self.view addSubview:temp];
    
    temp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect((PROGRESS_W-PROGRESS_X-PROGRESS_S*3)/2+PROGRESS_X, PROGRESS_X, PROGRESS_S*3, PROGRESS_H) pullsDown:YES];
    [temp setBezelStyle:NSRoundedBezelStyle];
    [temp setTag:MenuUploadFail];
    [temp addItemWithTitle:@"Fail"];
    [tempProgressDic setObject:temp forKey:@"Fail"];
    [self.view addSubview:temp];
    
    temp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(PROGRESS_W-PROGRESS_S*3, PROGRESS_X, PROGRESS_S*3, PROGRESS_H) pullsDown:YES];
    [temp setBezelStyle:NSRoundedBezelStyle];
    [temp setTag:MenuUploadWaiting];
    [temp addItemWithTitle:@"Waiting"];
    [tempProgressDic setObject:temp forKey:@"Waiting"];
    [self.view addSubview:temp];
    
    progressPopUpButton = [[NSDictionary alloc] initWithDictionary:tempProgressDic];
}

+ (MusicProgressPanel*)shareInstance
{
    if (_Music_Progress_Panel_ == nil)
    {
        _Music_Progress_Panel_ = [[MusicProgressPanel alloc] init];
    }
    return _Music_Progress_Panel_;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"doubleValue"]) {
        NSEnumerator * enumerator = [progressDic keyEnumerator];
        id obj;
        while (obj = [enumerator nextObject])
        {
            id progressTemp = [progressDic objectForKey:obj];
            if (object == [progressTemp objectForKey:@"progress"]) {
                [[progressTemp objectForKey:@"progressValue"] setStringValue:[NSString stringWithFormat:@"%.1f%%", [object doubleValue]*100]];
                break;
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)openInFinder:(NSMenuItem*)item
{
    
}

@end

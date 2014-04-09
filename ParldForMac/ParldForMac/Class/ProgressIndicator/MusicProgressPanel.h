//
//  MusicProcessPanel.h
//  ParldForMac
//
//  Created by sohunjug on 4/5/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicProgressPanel : NSObject

@property (assign) IBOutlet NSView *view;
@property (assign, nonatomic) NSInteger usedProgress;
@property (retain) NSDictionary* progressDic;
@property (retain) NSDictionary* progressPopUpButton;
@property (retain) NSMutableArray* waiting;
@property (retain) NSMutableDictionary *filePath;

+ (MusicProgressPanel*)shareInstance;
- (void)initDic;

@end

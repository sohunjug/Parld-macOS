//
//  ParldInterface.h
//  ParldForMac
//
//  Created by sohunjug on 3/30/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define ParldWebSite [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]

#define ParldMusicList  [NSString stringWithFormat:@"%@/api?act=musiclist", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldMusicPic   [NSString stringWithFormat:@"%@/api?act=musicpic&key=", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldMusicCount [NSString stringWithFormat:@"%@/api?act=play&key=", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldOnLine     [NSString stringWithFormat:@"%@/api?act=online&type=3&key=", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldOnLineKey  [NSString stringWithFormat:@"%@/api?act=online&type=3", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldOpenAnimation [NSString stringWithFormat:@"%@/api?act=openstar&", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldCheckUpdate [NSString stringWithFormat:@"%@/api?act=update&type=mac&version=", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]
#define ParldUpload     [NSString stringWithFormat:@"%@/api?act=upload", [[ParldInterface shareInstance] webSite] == nil ? parldBaseWebSite : [[ParldInterface shareInstance] webSite]]

extern NSString * const parldBaseWebSite;

@interface ParldInterface : NSObject
{
    NSThread *thread;
    NSArray *musicList;
    NSArray *updateData;
    NSDictionary *musicPic;
    NSString *webSite;
    NSString *onlineKey;
    ASIHTTPRequest *request;
    NSMutableData *recivedata;
}

@property (retain) NSString *webSite;
@property (retain) NSThread *thread;

+ (ParldInterface*)shareInstance;
+ (NSString*)WebSite;
- (id)init;
- (void)initMainThread;
- (NSArray*)getMusicList;
- (void)uploadMusic:(NSString*)fileName;
- (NSData*)getMusicPic:(NSString*)musicKey;
- (NSString*)getOpenAnimationWithWidth:(CGFloat)width withHeight:(CGFloat)height;
- (void)checkMusicCount:(NSString*)musicKey;
- (void)beginOnline;
- (NSArray*)checkUpdate;
- (NSString*)getDownload;
@end

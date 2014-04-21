//
//  ParldInterface.m
//  ParldForMac
//
//  Created by sohunjug on 3/30/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "ParldInterface.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"
#import "MusicProgressPanel.h"

static ParldInterface * parldInterface;
NSString * const parldBaseWebSite = @"http://www.parld.com";

@implementation ParldInterface

@synthesize LOCK = LOCK;
@synthesize thread;
@synthesize webSite;

+ (ParldInterface *)shareInstance
{
    if (parldInterface == nil)
    {
        parldInterface = [[ParldInterface alloc] init];
    }
    return parldInterface;
}

+ (NSString*)WebSite
{
    return [[ParldInterface shareInstance] webSite];
}

- (id)init
{
    if (parldInterface != nil)
        return parldInterface;
    if (self = [super init]) {
        LOCK = [[NSLock alloc] init];
        thread = [[NSThread alloc]
                  initWithTarget:self
                  selector:@selector(initMainThread)
                  object:nil];
        [thread setName:@"ParldInterfaceThread"];
        [thread start];
        [self performSelector:@selector(initWebSite) onThread:thread withObject:nil waitUntilDone:NO];
        //[self initWebSite];
    }
    return self;
}

- (void)initWebSite
{
    NSString *urlString=[NSString stringWithFormat:@"%@/api?act=via", parldBaseWebSite];
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request startSynchronous];
    NSError *error;
    error = [request error];
    if (!error) {
        self.webSite = [request responseString];
    }
    NSLog(@"%@", ParldWebSite);
    [self performSelector:@selector(getMusicList) onThread:thread withObject:nil waitUntilDone:NO];
    NSURL *url = [NSURL URLWithString:ParldOnLineKey];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"%@", ParldOnLineKey);
    [req startSynchronous];
    error = [req error];
    if(error) {
        NSLog(@"init%@\n%@", error, [req responseString]);
    }
    NSLog(@"%@", [req responseString]);
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSArray *dataArray = [NSArray alloc];
    dataArray = [jsonParser objectWithString:[req responseString] error:&error];
    onlineKey = [dataArray valueForKey:@"key"];
    
    NSTimeInterval timeInterval = [(NSNumber*)[dataArray valueForKey:@"time"] longValue];
    //定时器 repeats 表示是否需要重复，NO为只重复一次
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                             target:self
                                           selector:@selector(beginOnline)
                                           userInfo:nil
                                            repeats:YES];
    [self beginOnline];
}

- (void)requestFinished:(ASIHTTPRequest*)theRequest
{
    NSError *error;
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    musicList = [jsonParser objectWithString:[theRequest responseString] error:&error];
    if (musicPicNext != nil) {
        musicPic = musicPicNext;
    }
    [self performSelector:@selector(getAllMusicPicFunction) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)requestFailed:(ASIHTTPRequest*)theRequest
{
    NSError *error = [theRequest error];
    NSLog(@"musicList%@", error);
}

- (void)initMainThread
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (void)beginOnline
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ParldOnLine, onlineKey]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"online%@", error);
    }
}

- (void)checkMusicCount:(NSString *)musicKey
{
    [self performSelector:@selector(checkMusicCountFunction:) onThread:thread withObject:musicKey waitUntilDone:NO];
}

- (void)checkMusicCountFunction:(NSString *)musicKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ParldMusicCount, musicKey]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"%@%@", ParldMusicCount, musicKey);
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"musicCount%@", error);
    }
}

- (NSData*)getMusicPic:(NSString *)musicKey
{
    return [musicPic valueForKey:musicKey];
}

- (void)getAllMusicPicFunction
{
    NSMutableDictionary *tempPic = [NSMutableDictionary dictionaryWithCapacity:[musicList count]];
    for (NSDictionary* musicInfo in musicList) {
        [tempPic setObject:[self getMusicPicFunction:[musicInfo valueForKey:@"hash"]] forKey:[musicInfo valueForKey:@"hash"]];
    }
    musicPicNext = [NSDictionary dictionaryWithDictionary:tempPic];
}

- (NSData*)getMusicPicFunction:(NSString *)musicKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ParldMusicPic, musicKey]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"musicPic%@", error);
    }
    return [req responseData];
}

- (NSArray*)getMusicList
{
    NSArray* temp = nil;
    if (musicList != nil) {
        temp = musicList;
    }
    NSURL *url = [NSURL URLWithString:ParldMusicList];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req setDelegate:self];
    req.defaultResponseEncoding = NSUTF8StringEncoding;
    [req startAsynchronous];
    return temp;
}

- (NSString*)getOpenAnimationWithWidth:(CGFloat)width withHeight:(CGFloat)height
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@width=%f&height=%f", ParldOpenAnimation, width, height]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"openAnimation%@", error);
    }
    return [req responseString];
}

- (NSDictionary*)checkUpdate
{
    if (updateData) {
        return updateData;
    }
    NSBundle *bundle = [ NSBundle mainBundle ];
    //NSString *plistPath = [bundle pathForResource:@"info" ofType:@"plist"];
    NSDictionary *plistData = [bundle infoDictionary];
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@", ParldCheckUpdate, [plistData valueForKey:@"CFBundleVersion"]]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    req.defaultResponseEncoding = NSUTF8StringEncoding;
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"update%@", error);
    }

    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    updateData = [jsonParser objectWithString:[req responseString] error:&error];
    return updateData;
}

- (NSString*)getDownload
{
    return [updateData valueForKey:@"path"];
}

- (void)uploadMusic:(NSString *)fileName
{
    [self performSelector:@selector(uploadMusicFunction:) onThread:thread withObject:fileName waitUntilDone:NO];
}

- (void)uploadMusicFunction:(NSString *)fileName
{
    NSURL *url = [NSURL URLWithString:ParldUpload];
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:url];
    [req addRequestHeader:@"FILENAME" value:[fileName lastPathComponent]];
    [req addRequestHeader:@"FILETYPE" value:[fileName pathExtension]];
    [req addRequestHeader:@"FILESIZE" value:[NSString stringWithFormat:@"%lu", [data length]]];
    [req addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%lu", [data length]]];
    //[req addRequestHeader:@"FILEPATH" value:fileName];

    NSArray *allKeys = [[[MusicProgressPanel shareInstance] progressDic] allKeys];
    NSArray *sortKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    BOOL isDone = YES;
    while (isDone) {
        for (id obj in sortKeys)
        {
            id progressTemp = [[[MusicProgressPanel shareInstance] progressDic] objectForKey:obj];
            NSLog(@"%@", [progressTemp objectForKey:@"isUsed"]);
            if ([[progressTemp objectForKey:@"isUsed"] isEqualToString:@"NO"]) {
                [LOCK lock];
                [progressTemp setObject:@"YES" forKey:@"isUsed"];
                [progressTemp setObject:req forKey:@"request"];
                [[progressTemp objectForKey:@"title"] setStringValue:[fileName lastPathComponent]];
                [[progressTemp objectForKey:@"title"] setHidden:NO];
                [[progressTemp objectForKey:@"progress"] setHidden:NO];
                [[progressTemp objectForKey:@"progressValue"] setHidden:NO];
                [req setUploadProgressDelegate:[progressTemp objectForKey:@"progress"]];
                [[MusicProgressPanel shareInstance] setUsedProgress:[[MusicProgressPanel shareInstance] usedProgress] + 1];
                isDone = NO;
                //sleep(1);
                [LOCK unlock];
                break;
            }
        }
    }
    [req setShowAccurateProgress:YES];
    [req setPostBody:[NSMutableData dataWithData:data]];
    [req setTimeOutSeconds:1200];
    [req setDelegate:self];
    [req setDidFinishSelector:@selector(uploadFinished:)];
    [req setDidFailSelector:@selector(uploadFailed:)];
    [req startAsynchronous];
}

- (void)uploadFailed:(ASIFormDataRequest*)req
{
    [self performSelector:@selector(sendNotification:withNotification:) withObject:[[req requestHeaders] objectForKey:@"FILENAME"] withObject:@"Fail"];
    NSLog(@"%@", [req responseString]);
    [LOCK lock];
    [[MusicProgressPanel shareInstance] setUsedProgress:[[MusicProgressPanel shareInstance] usedProgress] - 1];
    [[[[MusicProgressPanel shareInstance] progressPopUpButton] objectForKey:@"Fail"] addItemWithTitle:[[req requestHeaders] objectForKey:@"FILENAME"]];// action:@selector(openInFinder:) keyEquivalent:@""];
    [self updateProgressState:req];
    [LOCK unlock];
}

- (void)uploadFinished:(ASIFormDataRequest*)req
{
    [self performSelector:@selector(sendNotification:withNotification:) withObject:[[req requestHeaders] objectForKey:@"FILENAME"] withObject:@"Done"];
    NSLog(@"%@", [req responseString]);
    [LOCK lock];
    [[MusicProgressPanel shareInstance] setUsedProgress:[[MusicProgressPanel shareInstance] usedProgress] - 1];
    [[[[MusicProgressPanel shareInstance] progressPopUpButton] objectForKey:@"Done"] addItemWithTitle:[[req requestHeaders] objectForKey:@"FILENAME"]];// action:@selector(openInFinder:) keyEquivalent:@""];
    [self updateProgressState:req];
    [LOCK unlock];
}

- (void)updateProgressState:(ASIFormDataRequest*)req
{
    NSEnumerator * enumerator = [[[MusicProgressPanel shareInstance] progressDic] keyEnumerator];
    id obj;
    while (obj = [enumerator nextObject])
    {
        id progressTemp = [[[MusicProgressPanel shareInstance] progressDic] objectForKey:obj];
        if (req == [progressTemp objectForKey:@"request"]) {
            [progressTemp setObject:@"NO" forKey:@"isUsed"];
            break;
        }
    }
}

- (void)sendNotification:(NSString*)fileName withNotification:(NSString*)notificationString
{
    THUserNotification *notification = [THUserNotification notification];
    notification.title = @"Parld";
    notification.informativeText = [NSString stringWithFormat:@"%@    %@", fileName, notificationString];
    //设置通知提交的时间
    notification.deliveryDate = [NSDate dateWithTimeIntervalSinceNow:1];
    
    THUserNotificationCenter *center = [THUserNotificationCenter notificationCenter];
    if ([center isKindOfClass:[THUserNotificationCenter class]]) {
        center.centerType = THUserNotificationCenterTypeBanner;
    }
    //删除已经显示过的通知(已经存在用户的通知列表中的)
    [center removeAllDeliveredNotifications];
    //递交通知
    [center deliverNotification:notification];
    //设置通知的代理
    [center setDelegate:self];
    
    [self performSelector:@selector(removeNotification:) withObject:notification afterDelay:5.0];
}

- (void)removeNotification:(NSUserNotification *)notification {
    [[THUserNotificationCenter notificationCenter] removeDeliveredNotification:notification];
}

- (void)userNotificationCenter:(THUserNotificationCenter *)center didActivateNotification:(THUserNotification *)notification {
    //    [self showMainWindow:nil];
}


- (void)userNotificationCenter:(THUserNotificationCenter *)center didDeliverNotification:(THUserNotification *)notification {
    // do nothing
}


- (BOOL)userNotificationCenter:(THUserNotificationCenter *)center shouldPresentNotification:(THUserNotification *)notification {
    return YES;
}

- (void)openInFinder:(NSMenuItem*)item{}

@end

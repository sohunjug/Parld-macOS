//
//  ParldInterface.m
//  ParldForMac
//
//  Created by sohunjug on 3/30/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "ParldInterface.h"
#import "SBJson.h"

static ParldInterface * parldInterface;
NSString * const parldBaseWebSite = @"http://www.parld.com";

@implementation ParldInterface

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
        thread = [[NSThread alloc]
                  initWithTarget:self
                  selector:@selector(initMainThread)
                  object:nil];
        [thread setName:@"ParldInterfaceThread"];
        [thread start];
        [self performSelector:@selector(initWebSite) onThread:thread withObject:nil waitUntilDone:NO];

    }
    return self;
}

- (void)initWebSite
{
    NSString *urlString=[NSString stringWithFormat:@"%@/api?act=via", parldBaseWebSite];
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setDelegate:self];
    [request startSynchronous];
    NSError *error;
    self.webSite = [request responseString];
    
    [self performSelector:@selector(getMusicList) onThread:thread withObject:nil waitUntilDone:NO];
    NSURL *url = [NSURL URLWithString:ParldOnLineKey];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    error = [req error];
    if(error) {
        NSLog(@"%@", error);
    }
    
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
    musicList = [jsonParser objectWithString:[theRequest responseString] error:&error];
    [self performSelector:@selector(getAllMusicPicFunction) onThread:thread withObject:nil waitUntilDone:NO];
}

- (void)requestFailed:(ASIHTTPRequest*)theRequest
{
    NSError *error = [theRequest error];
    NSLog(@"%@", error);
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
        NSLog(@"%@", error);
    }
}

- (void)checkMusicCount:(NSString *)musicKey
{
    [self performSelector:@selector(checkMusicCountFunction:) onThread:thread withObject:musicList waitUntilDone:NO];
}

- (void)checkMusicCountFunction:(NSString *)musicKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ParldMusicCount, musicKey]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"%@", error);
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
    musicPic = [NSDictionary dictionaryWithDictionary:tempPic];
}

- (NSData*)getMusicPicFunction:(NSString *)musicKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ParldMusicPic, musicKey]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"%@", error);
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
        NSLog(@"%@", error);
    }
    return [req responseString];
}

- (NSArray*)checkUpdate
{
    NSBundle *bundle = [ NSBundle mainBundle ];
    //NSString *plistPath = [bundle pathForResource:@"info" ofType:@"plist"];
    NSDictionary *plistData = [bundle infoDictionary];
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@", ParldCheckUpdate, [plistData valueForKey:@"CFBundleVersion"]]];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req startSynchronous];
    NSError *error = [req error];
    if(error) {
        NSLog(@"%@", error);
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
    [self performSelector:@selector(uploadMusic:) onThread:thread withObject:fileName waitUntilDone:NO];
}

- (void)uploadMusicFunction:(NSString *)fileName
{
    NSURL *url = [NSURL URLWithString:ParldUpload];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    [req addValue:[fileName lastPathComponent] forHTTPHeaderField:@"HTTP_FILENAME"];
    [req addValue:[fileName pathExtension] forHTTPHeaderField:@"HTTP_FILETYPE"];
    [req addValue:[NSString stringWithFormat:@"%ld", [data length]] forHTTPHeaderField:@"HTTP_FILESIZE"];
    [req setHTTPBody:data];
    NSURLConnection *connection;
    connection = [[NSURLConnection alloc]initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    recivedata = [NSMutableData data];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [recivedata appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:recivedata encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiveStr);
}

-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

@end

//
//  InterfaceAnimation.m
//  ParldForMac
//
//  Created by sohunjug on 4/4/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "InterfaceAnimation.h"
#import "MenuList.h"
#import <QuartzCore/QuartzCore.h>

static InterfaceAnimation * _interface_animation_;
@implementation InterfaceAnimation

@synthesize parentView;
@synthesize isDisplay = _isDisplay;

- (id)init
{
    self = [super init];
    if (self) {
        //[self hideViews];
        help = [[MusicButtonView alloc] initWithFrame:NSMakeRect(W-WO, W+WC, WO*2.3, WO*1.7)];
        [help setImage:[NSImage imageNamed:[NSString stringWithFormat:@"P4_4.png"]]];
        [help setTag:MenuHelp];
        [help setBordered:NO];
        [[help cell] setImageScaling:NSImageScaleAxesIndependently];
        [help setAction:@selector(menuAction:)];
        last = [[MusicButtonView alloc] initWithFrame:NSMakeRect(W-WC-WO*2-3, W-WO, WO*2, WO*2)];
        [last setImage:[NSImage imageNamed:[NSString stringWithFormat:@"P4_2.png"]]];
        [last setTag:MenuLast];
        [last setBordered:NO];
        [[last cell] setImageScaling:NSImageScaleAxesIndependently];
        [last setAction:@selector(menuAction:)];
        next = [[MusicButtonView alloc] initWithFrame:NSMakeRect(W+WC+3, W-WO, WO*2, WO*2)];
        [next setImage:[NSImage imageNamed:[NSString stringWithFormat:@"P4_1.png"]]];
        [next setTag:MenuNext];
        [next setBordered:NO];
        [[next cell] setImageScaling:NSImageScaleAxesIndependently];
        [next setAction:@selector(menuAction:)];
        refresh = [[MusicButtonView alloc] initWithFrame:NSMakeRect(W-WO, W-WC-WO*2, WO*2, WO*2)];
        [refresh setImage:[NSImage imageNamed:[NSString stringWithFormat:@"P4_3.png"]]];
        [refresh setTag:MenuRefresh];
        [refresh setBordered:NO];
        [[refresh cell] setImageScaling:NSImageScaleAxesIndependently];
        [refresh setAction:@selector(menuAction:)];
        
        _isDisplay = NO;
        done = YES;
        
        [self addObserver:self forKeyPath:@"isDisplay" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

+ (InterfaceAnimation*)shareInstance
{
    if (_interface_animation_ == nil)
    {
        _interface_animation_ = [[InterfaceAnimation alloc] init];
    }
    return _interface_animation_;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    @synchronized(self){
        if ([keyPath isEqualToString:@"isDisplay"]) {
            NSLog(@"%hhd", _isDisplay);
            _isDisplay ? [self showMenu] : [self hideMenu];
        }
        else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)showMenu
{
    if (done)
        [self showViews];
    
    [self cancelHide];
}

- (void)hideMenu
{
    [self cancelHide];
    [self checkHide];
}

- (void)cancelHide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)checkHide
{
    [self performSelector:@selector(hideViews) withObject:nil afterDelay:1.5];
}

- (void)hideViews
{
    if (!help) return;
        @synchronized(self){
            [self animationHide:help withPoint:NSMakePoint(W-WO, W+WC) forObject:@"help"];
            [self animationHide:last withPoint:NSMakePoint(W-WC-WO*2-3, W-WO) forObject:@"previous"];
            [self animationHide:refresh withPoint:NSMakePoint(W-WO, W-WC-WO*2) forObject:@"refresh"];
            [self animationHide:next withPoint:NSMakePoint(W+WC+3, W-WO) forObject:@"next"];
            done = YES;
        }
}

- (void)showViews
{
        @synchronized(self){
            [self animationShow:help withPoint:NSMakePoint(W-WC-WO*2-3, W-WO) forObject:@"help"];
            [self animationShow:last withPoint:NSMakePoint(W-WO, W-WC-WO*2) forObject:@"previous"];
            [self animationShow:refresh withPoint:NSMakePoint(W+WC+3, W-WO) forObject:@"refresh"];
            [self animationShow:next withPoint:NSMakePoint(W-WO, W+WC) forObject:@"next"];
            done = NO;
        }
}

- (void)animationShow:(NSView*)view withPoint:(NSPoint)point forObject:(NSString *)name
{
    BOOL custom = [[NSUserDefaults standardUserDefaults] boolForKey:@"cool"];
    NSRect temp = ((NSImageView*)view).frame;
    [self.parentView addSubview:view];
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyframeAnimation.duration = 0.3;
    keyframeAnimation.repeatCount = 1;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 57, 54);
    
    if (custom) {
        CGPathAddLineToPoint(path, NULL, temp.origin.x, temp.origin.y);
    }
    else {
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
        //keyframeAnimation.removedOnCompletion = YES;
        
        if ([name isEqualToString:@"help"])
            CGPathAddArc(path, NULL, 54, 57, 51, M_PI/2, M_PI/2, YES);
        else if ([name isEqualToString:@"previous"])
            CGPathAddArc(path, NULL, 54, 57, 51, M_PI, M_PI, YES);
        else if ([name isEqualToString:@"refresh"])
            CGPathAddArc(path, NULL, 54, 57, 51, -M_PI/2, -M_PI/2, YES);
        else if ([name isEqualToString:@"next"])
            CGPathAddArc(path, NULL, 54, 57, 51, 0, 0, YES);
    }
    keyframeAnimation.path = path;
    CGPathRelease(path);
    keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:0];
    opacityAnim.toValue = [NSNumber numberWithFloat:1];
    opacityAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:keyframeAnimation,opacityAnim, nil];
    animGroup.duration = 0.3;
    [view.layer addAnimation:animGroup forKey:nil];
}

- (void)animationHide:(NSView*)view withPoint:(NSPoint)point  forObject:(NSString *)name
{
    BOOL custom = [[NSUserDefaults standardUserDefaults] boolForKey:@"cool"];
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyframeAnimation.duration = 0.3;
    keyframeAnimation.repeatCount = 1;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    if (!custom) {
        if ([name isEqualToString:@"previous"])
            CGPathAddArc(path, NULL, 54, 57, 51, M_PI/2, M_PI/2, NO);
        else if ([name isEqualToString:@"refresh"])
            CGPathAddArc(path, NULL, 54, 57, 51, M_PI, M_PI, NO);
        else if ([name isEqualToString:@"next"])
            CGPathAddArc(path, NULL, 54, 57, 51, -M_PI/2, -M_PI/2, NO);
        else if ([name isEqualToString:@"help"])
            CGPathAddArc(path, NULL, 54, 57, 51, 0, 0, NO);
    }
    CGPathAddLineToPoint(path, NULL, 57, 54);
    //keyframeAnimation.removedOnCompletion = YES;
    keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    keyframeAnimation.path = path;
    CGPathRelease(path);
    keyframeAnimation.fillMode = kCAFillModeBoth;
    
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"alpha"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.removedOnCompletion = YES;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:keyframeAnimation,opacityAnim, nil];
    animGroup.duration = 0.3;
    animGroup.delegate = self;
    
    [view.layer addAnimation:animGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [help removeFromSuperview];
    [last removeFromSuperview];
    [next removeFromSuperview];
    [refresh removeFromSuperview];
}

@end

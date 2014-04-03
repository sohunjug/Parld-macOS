//
//  MenuList.m
//  ParldForMac
//
//  Created by sohunjug on 4/3/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import "MenuList.h"

static MenuList * _menuList;

@implementation MenuList

@synthesize systemBarMenu;
@synthesize suspensionMenu;

- (id)init
{
    if (self = [super init]) {
        ;
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

- (void)refresh
{
    
}

@end

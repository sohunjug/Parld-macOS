//
//  MenuList.h
//  ParldForMac
//
//  Created by sohunjug on 4/3/14.
//  Copyright (c) 2014 sohunjug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuList : NSObject
{
    NSMenu *systemBarMenu;
    NSMenu *suspensionMenu;
}

@property (retain) NSMenu *systemBarMenu;
@property (retain) NSMenu *suspensionMenu;

+ (MenuList*)shareInstance;

@end

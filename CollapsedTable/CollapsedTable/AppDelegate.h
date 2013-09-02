//
//  AppDelegate.h
//  CollapsedTable
//
//  Created by Ashish Sharma on 31/08/13.
//  Copyright (c) 2013 anonymous. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RootVC *rvc;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@end

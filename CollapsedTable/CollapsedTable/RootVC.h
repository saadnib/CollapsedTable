//
//  RootVC.h
//  CollapsedTable
//
//  Created by Ashish Sharma on 31/08/13.
//  Copyright (c) 2013 anonymous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootVC : UIViewController
{
    NSMutableArray *items;
    
    int level;
}

@property (nonatomic, strong) IBOutlet UITableView *tblView;

@end

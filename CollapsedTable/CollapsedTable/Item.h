//
//  Item.h
//  CollapsedTable
//
//  Created by Ashish Sharma on 31/08/13.
//  Copyright (c) 2013 anonymous. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *parentId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *visibility;
@property (nonatomic, strong) NSString *childVisibility;
@property (nonatomic) int level;

@end

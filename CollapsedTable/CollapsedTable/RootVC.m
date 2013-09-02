//
//  RootVC.m
//  CollapsedTable
//
//  Created by Ashish Sharma on 31/08/13.
//  Copyright (c) 2013 anonymous. All rights reserved.
//

#import "RootVC.h"
#import "Item.h"

@interface RootVC ()

@end

@implementation RootVC

@synthesize tblView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [NSThread detachNewThreadSelector:@selector(fetchItems) toTarget:self withObject:nil];
}

#pragma mark - 
#pragma mark - Messages

- (void) fetchItems
{
    NSString *jsonFile = @"items";
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:jsonFile ofType:@"json"]];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *array = [json objectForKey:@"items"];
    
    items = [[NSMutableArray alloc] init];
    
    level = -1;
    [self iterateItems:array];
    
    NSLog(@"%@",items);
    
    [self.tblView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) iterateItems:(NSArray*) array
{
    level++;
    
    for (int i = 0; i < [array count]; i++)
    {
        NSDictionary *commentInfo = [array objectAtIndex:i];
        
        Item *item = [[Item alloc] init];
        item.Id = [commentInfo objectForKey:@"id"];
        item.parentId = [commentInfo objectForKey:@"parent_id"];
        item.title = [commentInfo objectForKey:@"title"];
        item.level = level;
        item.visibility = @"normal";
        item.childVisibility = @"normal";
        
        [items addObject:item];
        
        [self iterateItems:[commentInfo objectForKey:@"sub_items"]];
    }
    
    level--;
}

- (float) cellHeightForRow:(int) row
{
    Item *item = [items objectAtIndex:row];
    
    if ([item.visibility isEqualToString:@"hidden"])
    {
        return 0.0f;
    }
    else 
    {
        return 50.0f;
    }
}

- (void) hideCompleteNode:(UISwipeGestureRecognizer*) gestureRecognizer
{
    UITableViewCell *cell = (UITableViewCell*) [[gestureRecognizer view] superview];
    NSIndexPath *indexPath = [self.tblView indexPathForCell:cell];
    
    Item *item = [items objectAtIndex:indexPath.row];
    
    if (item.level == 0)
    {
        if ([item.childVisibility isEqualToString:@"normal"])
        {
            [self hideChilds:indexPath];
        }
    }
    else
    {
        int prevIndex = indexPath.row-1;
        
        if (prevIndex >= 0)
        {
            Item *parentItem = [items objectAtIndex:prevIndex];
            
            while (parentItem.level != 0)
            {
                prevIndex--;
                
                if (prevIndex >= 0)
                    parentItem = [items objectAtIndex:prevIndex];
                else
                    break;
            }
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:prevIndex inSection:0];
        
        [self hideChilds:indexPath];
    }
}

- (void) hideChilds:(NSIndexPath*) indexPath
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithObjects:indexPath, nil];
    
    Item *item = [items objectAtIndex:indexPath.row];
    
    BOOL shouldHide = [item.childVisibility isEqualToString:@"hidden"]?NO:YES;
    
    item.childVisibility = shouldHide?@"hidden":@"normal";
    
    int nextIndex = indexPath.row+1;
    
    if (nextIndex < [items count])
    {
        Item *childItem = [items objectAtIndex:nextIndex];
        
        while (childItem.level > item.level)
        {
            childItem.visibility = shouldHide?@"hidden":@"normal";
            childItem.childVisibility = shouldHide?@"hidden":@"normal";
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
            
            nextIndex++;
            
            if (nextIndex < [items count])
                childItem = [items objectAtIndex:nextIndex];
            else
                break;
        }
    }
    
    [self.tblView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 
#pragma mark - UITableView Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellHeightForRow:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"itemCell";
    
    UITableViewCell *cell = [self.tblView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIImageView *arrowImgView = [[UIImageView alloc] init];
        [arrowImgView setBackgroundColor:[UIColor clearColor]];
        [arrowImgView setTag:1];
        [cell.contentView addSubview:arrowImgView];

        
        UILabel *titleLbl = [[UILabel alloc] init];
        [titleLbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
        [titleLbl setTextColor:UIColorFromRedGreenBlue(51.0f, 51.0f, 51.0f)];
        [titleLbl setTag:2];
        [titleLbl setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:titleLbl];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideCompleteNode:)];
        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [cell.contentView addGestureRecognizer:swipeGesture];
    }
    
    Item *item = [items objectAtIndex:indexPath.row];
    
    if (item.level == 0)
    {
        [cell.contentView setBackgroundColor:UIColorFromRedGreenBlue(204.0f, 204.0f, 204.0f)];
    }
    else
    {
        [cell.contentView setBackgroundColor:UIColorFromRedGreenBlue(252.0f,252.0f, 252.0f)];
    }
    
    UIImageView *arrowImgView = (UIImageView*) [cell viewWithTag:1];
    UILabel *titleLbl = (UILabel*) [cell viewWithTag:2];
    
    if ([item.visibility isEqualToString:@"hidden"])
    {
        [titleLbl setFrame:CGRectZero];
        [arrowImgView setFrame:CGRectZero];
    }
    else
    {
        [arrowImgView setFrame:CGRectMake(5.0f+(20.0f*item.level), 20.0f, 10.0f, 10.0f)];
        
        if ([item.childVisibility isEqualToString:@"hidden"])
        {
            [arrowImgView setImage:[UIImage imageNamed:@"closeArrow"]];
        }
        else
        {
            [arrowImgView setImage:[UIImage imageNamed:@"openArrow"]];
        }
        
        [titleLbl setFrame:CGRectMake(20.0f+(20.0f*item.level), 10.0f, 320.0f - (20.0f+(20.0f*item.level)), 30.0f)];
        [titleLbl setText:item.title];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideChilds:indexPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  RootTableViewController.h
//  SecretMood
//
//  Created by XQS on 13-12-29.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@property (nonatomic) BOOL debug;
@end

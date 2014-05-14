//
//  RootTableViewCell.h
//  SecretMood
//
//  Created by XQS on 13-12-30.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mood.h"

@protocol RootTableViewCellDelegate;

@interface RootTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) Mood *mood;

@property (nonatomic) BOOL reuse;

@end


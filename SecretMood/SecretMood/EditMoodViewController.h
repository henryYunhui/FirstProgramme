//
//  EditMoodViewController.h
//  SecretMood
//
//  Created by XQS on 13-12-31.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "AddMoodViewController.h"
#import "Mood.h"

@interface EditMoodViewController : AddMoodViewController

@property (nonatomic, strong) Mood *mood;

@end

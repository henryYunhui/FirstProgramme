//
//  AddMoodViewController.h
//  SecretMood
//
//  Created by XQS on 13-12-26.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mood.h"


@interface AddMoodViewController : UIViewController

// out
@property (nonatomic, strong) Mood *addedMood;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;

@end

//
//  EditMoodViewController.m
//  SecretMood
//
//  Created by XQS on 13-12-31.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "EditMoodViewController.h"
#import "MainAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditMoodViewController ()

@end

@implementation EditMoodViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.textView.text = self.mood.feeling;
    
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.mood.imageURL];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.image = image;
//    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    if (appDelegate.managedObjectContext) NSLog(@"yes!");
}

#pragma mark - Segue Management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Done Edit Mood"]) {
        NSManagedObjectContext *context = self.managedObjectContext;
        Mood *mood = [self fetchMoodOnDate:self.mood.date InManagedObjectContext:context];
        
        //do the delete file stuff
        NSURL *url = [NSURL URLWithString:mood.imageURL];
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:NULL] == YES) NSLog(@"delete imageData success");
        
        mood.feeling = self.textView.text;
        mood.imageURL = [self.imageURL absoluteString];
        [context save:NULL];
    }
}

- (Mood *)fetchMoodOnDate:(NSDate *)moodDate
 InManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mood"];
    request.predicate = [NSPredicate predicateWithFormat:@"date == %@",moodDate];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        NSLog(@"Execute fetchRequest wrong!");
        return nil;
    }else if ([matches count]){
        return [matches firstObject];
    }else{
        NSLog(@"Nothing is found in sqlite.");
        return nil;
    }
}

@end

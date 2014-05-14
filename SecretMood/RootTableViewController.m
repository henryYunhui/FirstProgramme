//
//  RootTableViewController.m
//  SecretMood
//
//  Created by XQS on 13-12-29.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "RootTableViewController.h"
#import <CoreData/CoreData.h>
#import "Mood+Display.h"
#import "AddMoodViewController.h"
#import "RootTableViewCell.h"
#import "EditMoodViewController.h"

@interface RootTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Mood *mood;
@property (nonatomic, strong) UIAlertView *alertView;
@end

@implementation RootTableViewController

#pragma mark - ViewController Lifecycle

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"640_960"]];
//    [self.tableView setBackgroundView:imageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Lazy Instantiation

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mood"];
    request.predicate = nil;
    NSString *sectionKey = [NSString stringWithFormat:@"date"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                              ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:sectionKey
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (void)configureCell:(RootTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Mood *mood = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.mood = mood;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Secret Mood Cell Without P";
    RootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];

    if (cell.reuse == NO) {
        [cell.deleteButton addTarget:self action:@selector(alert:) forControlEvents:UIControlEventTouchUpInside];
        [cell.editButton addTarget:self action:@selector(editMood:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.reuse = YES;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Mood *mood = (Mood *)[[[[self.fetchedResultsController sections] objectAtIndex:section] objects] firstObject];
    NSString *dateRightNow = [mood dateAsString];
    return dateRightNow;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Mood *mood = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:mood.feeling attributes:@{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody] }];
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(320-16, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil].size;
    return textSize.height+16 + 310 + TABLEVIEW_CELL_BUTTON_HEIGHT;
}

#pragma mark - TableViewCell's Buttons' Action

- (void)editMood:(UIButton *)sender
{
    if ([sender.superview.superview isKindOfClass:[RootTableViewCell class]]) {
        //perform modal segue to EditMoodViewController
        RootTableViewCell *cell = (RootTableViewCell *)sender.superview.superview;
        [self performSegueWithIdentifier:@"Edit Mood" sender:cell];
    }
}

- (void)alert:(UIButton *)sender
{
    self.alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete Mood"]
                               message:@"do you want to delete?"
                              delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:@"Yes",@"Cancel", nil];
    [self.alertView show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(RootTableViewCell *)sender.superview.superview];
    self.mood = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

//- (void)deleteMood:(UIButton *)sender
//{
//    if ([sender.superview.superview isKindOfClass:[RootTableViewCell class]]) {
//        RootTableViewCell *cell = (RootTableViewCell *)sender.superview.superview;
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        Mood *mood = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        [self.managedObjectContext deleteObject:mood];
//        [self.managedObjectContext save:NULL];
//    }
//}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSURL *url = [NSURL URLWithString:self.mood.imageURL];
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:NULL] == YES) NSLog(@"delete success!\n");
        [self.managedObjectContext deleteObject:self.mood];
        [self.managedObjectContext save:NULL];
    }else{
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
    }
}

#pragma mark - Segue Management

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifier
                   toEditCell:(RootTableViewCell *)cell
{
    if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Edit Mood"]) {
        if ([vc isKindOfClass:[EditMoodViewController class]]) {
            EditMoodViewController *editMoodViewController = (EditMoodViewController *)vc;
            editMoodViewController.mood = cell.mood;
            editMoodViewController.managedObjectContext = self.managedObjectContext;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EditMoodViewController class]]){
        [self prepareViewController:segue.destinationViewController
                           forSegue:segue.identifier
                         toEditCell:(RootTableViewCell *)sender];
    }else if ([segue.destinationViewController isKindOfClass:[AddMoodViewController class]]) {
        AddMoodViewController *addMoodViewController = (AddMoodViewController *)segue.destinationViewController;
        addMoodViewController.managedObjectContext = self.managedObjectContext;
    }
    
}

- (IBAction)addMood:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[AddMoodViewController class]]
        &&![segue.sourceViewController isKindOfClass:[EditMoodViewController class]])
    {
        AddMoodViewController *addMoodViewController = (AddMoodViewController *)segue.sourceViewController;
        Mood *addedMood = addMoodViewController.addedMood;
        if (addedMood) {
            
        }else{
            NSLog(@"AddMoodViewController unexpectedly did not add a mood! ");
        }
    }
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error = nil;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    }else{
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.tableView reloadData];   // what if not? same below
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(RootTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end

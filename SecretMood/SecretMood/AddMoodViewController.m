//
//  AddMoodViewController.m
//  SecretMood
//
//  Created by XQS on 13-12-26.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "AddMoodViewController.h"
#import "Mood.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AddMoodViewController () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) UILabel *hintLabel;
@property (nonatomic, strong) NSAttributedString *attributedString;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@end

@implementation AddMoodViewController

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Mood"

+ (BOOL)canTakePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.textView becomeFirstResponder];
    [self configTextView];
    [self configHintLabel];
    self.image = [UIImage imageNamed:@"standard"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[self class] canTakePhoto]) {
        [self alert:@"Sorry,this device cannot take a photo!"];
    }
}

- (void)configTextView
{
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textView.textAlignment = NSTextAlignmentCenter;
//    self.textView.backgroundColor = [UIColor lightGrayColor];
}

- (void)configHintLabel
{
    if ([self.textView.text length] > 0) {
        self.hintLabel.hidden = YES;
    }else{
        self.hintLabel.hidden = NO;
    }
}

#pragma mark - Lazy Instantiation

- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-90, 10, 200, 21)];
        [_hintLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        _hintLabel.text = @"Your mood right now...";
        [_hintLabel setTextColor:[UIColor lightGrayColor]];
        [self.textView addSubview:self.hintLabel];
    }
    return _hintLabel;
}

- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f",floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

- (NSURL *)imageURL
{
    if (!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            // save imageData to disk
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (void)setImage:(UIImage *)image
{
    self.photoImageView.image = image;
    
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    self.imageURL = nil;
}

- (UIImage *)image
{
    return self.photoImageView.image;
}

#pragma mark - Segue Management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.managedObjectContext;
        Mood *addedMood = [NSEntityDescription insertNewObjectForEntityForName:@"Mood"
                                                   inManagedObjectContext:context];
        addedMood.date = [NSDate date];
        addedMood.feeling = self.textView.text;
        addedMood.imageURL = [self.imageURL absoluteString];
        
        [context save:NULL];
        
        self.imageURL = nil; // this URL has been used now
        
        self.addedMood = addedMood;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if (![self.textView.text length]) {
            [self alert:@"Mood required!"];
            return NO;
        }else{
            return YES;
        }
    }else{
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Add Mood"
                               message:message
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil] show];
}

#pragma mark - Navigation Action

- (IBAction)cancel
{
    self.image = nil;   // cleans up any temporary files
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addPhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照",@"从手机相册选取", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{
            //get called as soon as viewDidAppear happens
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else if (buttonIndex == 1){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:^{
            //get called as soon as viewDidAppear happens
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    self.image = image;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // save this photo to PHOTO LIBRARY
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary writeImageToSavedPhotosAlbum:[self.image CGImage]
                                        orientation:(ALAssetOrientation)self.image.imageOrientation
                                    completionBlock:NULL];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)done
{
    [self.textView resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 0) {
        self.hintLabel.hidden = YES;
    }else{
        self.hintLabel.hidden = NO;
    }
    [self resetScrollPosition];
}

//调整scrollview的显示位置
- (void)resetScrollPosition
{
    CGRect r = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
    CGFloat caretY = MAX(r.origin.y - self.textView.frame.size.height + r.size.height, 0);
    if (self.textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
        self.textView.contentOffset = CGPointMake(0, caretY);
    }
}

@end

//
//  RootTableViewCell.m
//  SecretMood
//
//  Created by XQS on 13-12-30.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "RootTableViewCell.h"
#import <CoreText/CoreText.h>

@interface RootTableViewCell (){
    CGRect textViewRect;
}
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *bodyOfTextView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation RootTableViewCell

@synthesize imageView = _imageView; // why do i have do synthesize?

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:textViewRect];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self addSubview:_textView];
    }
    return _textView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        CGRect imageViewRect = CGRectMake(0, self.textView.frame.size.height, 320, 310);
        _imageView.frame = imageViewRect;
        _imageView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setFrame:CGRectMake(10, self.textView.frame.size.height + 310, 50, 20)];
        [_editButton setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:0.8f]];
        [_editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        _editButton.opaque = YES;
        [self addSubview:_editButton];
    }
    [_editButton setFrame:CGRectMake(10, self.textView.frame.size.height + 310, 50, 20)];
    return _editButton;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setFrame:CGRectMake(260, self.textView.frame.size.height + self.imageView.frame.size.height, 50, 20)];
        [_deleteButton setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:0.8f]];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _deleteButton.opaque = YES;
        [self addSubview:_deleteButton];
    }
    [_deleteButton setFrame:CGRectMake(260, self.textView.frame.size.height + self.imageView.frame.size.height, 50, 20)];
    return _deleteButton;
}

- (void)setMood:(Mood *)mood
{
    _mood = mood;
    
    //once mood gets seted,change views accordingly
    self.bodyOfTextView = _mood.feeling;
    NSURL *url = [NSURL URLWithString:_mood.imageURL];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.imageView.image = image;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setBodyOfTextView:(NSString *)bodyOfTextView
{
    _bodyOfTextView = bodyOfTextView;
    
    self.textView.text = bodyOfTextView;
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:bodyOfTextView attributes:@{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody] }];
    CGSize size = [attrStr boundingRectWithSize:CGSizeMake(320-16, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    textViewRect.size = CGSizeMake(320, size.height + 18);
    self.textView.frame = textViewRect;
    
    //everytime textView changes,reset the frame of button and imageView
    [self.imageView setFrame:CGRectMake(0, self.textView.frame.size.height, 320, 310)];
    [self.editButton setFrame:CGRectMake(10, self.textView.frame.size.height + 310, 50, 20)];
    [self.deleteButton setFrame:CGRectMake(260, self.textView.frame.size.height + self.imageView.frame.size.height, 50, 20)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

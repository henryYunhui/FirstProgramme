//
//  Mood+Display.m
//  SecretMood
//
//  Created by XQS on 13-12-29.
//  Copyright (c) 2013年 TencentQS. All rights reserved.
//

#import "Mood+Display.h"

@implementation Mood (Display)

- (NSString *)dateAsString
{
    NSDate *date = self.date;
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8*60*60];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateRightNow = [formatter stringFromDate:date];
    //    NSLog(@"%@\n",dateRightNow);
    return dateRightNow;
}

@end

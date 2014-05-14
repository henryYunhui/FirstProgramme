//
//  Mood.h
//  SecretMood
//
//  Created by XQS on 14-1-7.
//  Copyright (c) 2014年 TencentQS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Mood : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * feeling;
@property (nonatomic, retain) NSString * imageURL;

@end

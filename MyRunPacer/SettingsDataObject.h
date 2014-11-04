//
//  SettingsAppDataObject.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/23/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDataObject.h"

@interface SettingsDataObject : AppDataObject
{
    NSManagedObjectContext *managedObjectContext;
    
    // TODO: Settings to implement
    BOOL isMetric;
    BOOL useIntervalTimer;
    NSArray *intervalTimes;
    NSInteger walkInterval;
    NSInteger runInterval;
    NSString *fullname;
    NSDate *dob;
    NSInteger genderInt;
    NSString *genderStr;
    
    
    // examples
    //NSString*	string1;
    //NSData*		data1;
    //NSInteger	int1;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL isMetric;
@property (nonatomic) BOOL useIntervalTimer;
@property (nonatomic) NSArray *intervalTimes;
@property (nonatomic) NSInteger walkInterval;
@property (nonatomic) NSInteger runInterval;
@property (nonatomic, copy) NSString *fullname;
@property (nonatomic) NSDate *dob;
@property (nonatomic) NSInteger genderInt;
@property (nonatomic, copy) NSString *genderStr;

// examples
//@property (nonatomic, copy) NSString* string1;
//@property (nonatomic, retain) NSData* data1;
//@property (nonatomic) float float1;

#pragma mark - Functions
- (void)registerDefaultSettings;
- (void)loadUserSettings;
- (void)saveUserSettings;



@end

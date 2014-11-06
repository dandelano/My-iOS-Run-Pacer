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
    NSArray *distanceUnits_Str;
    BOOL isMetric;
    BOOL useIntervalTimer;
    NSArray *intervalTimes_Int;
    NSArray *intervalTimes_Str;
    NSInteger walkIntervalIndex_Int;
    NSInteger runIntervalIndex_Int;
    NSString *name_Str;
    NSDate *dob_Date;
    NSInteger genderIndex_Int;
    NSArray *genders_Str;
    
    // examples
    //NSString*	string1;
    //NSData*		data1;
    //NSInteger	int1;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSArray *distanceUnits_Str;
@property (nonatomic) BOOL isMetric;
@property (nonatomic) BOOL useIntervalTimer;
@property (nonatomic) NSArray *intervalTimes_Int;
@property (nonatomic) NSArray *intervalTimes_Str;
@property (nonatomic) NSInteger walkIntervalIndex_Int;
@property (nonatomic) NSInteger runIntervalIndex_Int;
@property (nonatomic, copy) NSString *name_Str;
@property (nonatomic) NSDate *dob_Date;
@property (nonatomic) NSInteger genderIndex_Int;
@property (nonatomic) NSArray *genders_Str;

// examples
//@property (nonatomic, copy) NSString* string1;
//@property (nonatomic, retain) NSData* data1;
//@property (nonatomic) float float1;

#pragma mark - Functions
- (void)registerDefaultSettings;
- (void)loadUserSettings;
- (void)saveUserSettings;



@end

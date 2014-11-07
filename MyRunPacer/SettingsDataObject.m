//
//  SettingsAppDataObject.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/23/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "SettingsDataObject.h"

static NSString *const keyDistanceUnit_Str =  @"distanceUnits_Str";

static NSString *const keyIsMetric = @"isMetric";
static NSString *const keyUseIntervalTimer = @"useIntervalTimer";
static NSString *const keyIntervalTimes_Int = @"intervalTimes_Int";
static NSString *const keyIntervalTimes_Str = @"intervalTimes_Str";
static NSString *const keyWalkIntervalIndex_Int = @"walkIntervalIndex_Int";
static NSString *const keyRunIntervalIndex_Int = @"runIntervalIndex_Int";
static NSString *const keyName_Str = @"name_Str";
static NSString *const keyDob_Date = @"dob_Date";
static NSString *const keyGenderIndex_Int = @"genderIndex_Int";
static NSString *const keyGenders_Str = @"genders_Str"; // 0 male, 1 female

@interface SettingsDataObject ()

@end

@implementation SettingsDataObject

#pragma mark - Properties

@synthesize managedObjectContext;
@synthesize distanceUnits_Str;
@synthesize isMetric;
@synthesize useIntervalTimer;
@synthesize intervalTimes_Int;
@synthesize intervalTimes_Str;
@synthesize walkIntervalIndex_Int;
@synthesize runIntervalIndex_Int;
@synthesize name_Str;
@synthesize dob_Date;
@synthesize genderIndex_Int;
@synthesize genders_Str;



// Examples
//@synthesize string1;
//@synthesize data1;
//@synthesize float1;

#pragma mark - Public Functions
- (void)registerDefaultSettings
{
    NSURL *defaultPrefsFile = [[NSBundle mainBundle]
                               URLForResource:@"DefaultSettings" withExtension:@"plist"];
    NSDictionary *defaultPrefs =
    [NSDictionary dictionaryWithContentsOfURL:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
}

- (void)loadUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.distanceUnits_Str = [defaults arrayForKey:keyDistanceUnit_Str];
    self.isMetric = [defaults boolForKey:keyIsMetric];
    self.useIntervalTimer = [defaults boolForKey:keyUseIntervalTimer];
    self.intervalTimes_Int = [defaults arrayForKey:keyIntervalTimes_Int];
    self.intervalTimes_Str = [defaults arrayForKey:keyIntervalTimes_Str];
    self.walkIntervalIndex_Int = [defaults integerForKey:keyWalkIntervalIndex_Int];
    self.runIntervalIndex_Int = [defaults integerForKey:keyRunIntervalIndex_Int];
    self.name_Str = [defaults stringForKey:keyName_Str];
    self.dob_Date = (NSDate*)[defaults objectForKey:keyDob_Date];
    self.genderIndex_Int = [defaults integerForKey:keyGenderIndex_Int];
    self.genders_Str = [defaults arrayForKey:keyGenders_Str]; // 0 male, 1 female
}

- (void)saveUserSettings
{
    NSLog(@"Saving user settings");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:self.isMetric forKey:keyIsMetric];
    [defaults setBool:self.useIntervalTimer forKey:keyUseIntervalTimer];
    [defaults setInteger:self.walkIntervalIndex_Int forKey:keyWalkIntervalIndex_Int];
    [defaults setInteger:self.runIntervalIndex_Int forKey:keyRunIntervalIndex_Int];
    [defaults setObject:self.name_Str forKey:keyName_Str];
    [defaults setObject:self.dob_Date forKey:keyDob_Date];
    [defaults setInteger:self.genderIndex_Int forKey:keyGenderIndex_Int];
    
    // force saving
    [defaults synchronize]; // this method is optional
}

@end

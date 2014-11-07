//
//  SettingsAppDataObject.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/23/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "SettingsDataObject.h"

@interface SettingsDataObject ()

- (void)addSettingForKey:(NSString*)key andValue:(NSString*)value;
- (NSString*)getNSStringSettingForKey:(NSString*)key;

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

#pragma mark - Private Functions

- (void)addSettingForKey:(NSString*)key andValue:(NSString*)value;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //NSString *storedVal = @"This is what you want to save";
    //NSString *key = @"storedVal"; // the key for the data
    
    [defaults setObject:value forKey:key];
    [defaults synchronize]; // this method is optional
}

- (NSString*)getNSStringSettingForKey:(NSString*)key
{
    // Get the results out
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *results = [defaults stringForKey:key];
    return results;
}

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
    self.distanceUnits_Str = [defaults arrayForKey:@"distanceUnits_Str"];
    self.isMetric = [defaults boolForKey:@"isMetric"];
    self.useIntervalTimer = [defaults boolForKey:@"useIntervalTimer"];
    self.intervalTimes_Int = [defaults arrayForKey:@"intervalTimes_Int"];
    self.intervalTimes_Str = [defaults arrayForKey:@"intervalTimes_Str"];
    self.walkIntervalIndex_Int = [defaults integerForKey:@"walkIntervalIndex_Int"];
    self.runIntervalIndex_Int = [defaults integerForKey:@"runIntervalIndex_Int"];
    self.name_Str = [defaults stringForKey:@"name_Str"];
    self.dob_Date = (NSDate*)[defaults objectForKey:@"dob_Date"];
    self.genderIndex_Int = [defaults integerForKey:@"genderIndex_Int"];
    self.genders_Str = [defaults arrayForKey:@"genders_Str"]; // 0 male, 1 female
}

- (void)saveUserSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *storedVal = @"This is what you want to save";
    NSString *key = @"storedVal"; // the key for the data
    
    [defaults setObject:storedVal forKey:key];
    [defaults synchronize]; // this method is optional
}

@end

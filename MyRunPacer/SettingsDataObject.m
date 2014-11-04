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
@synthesize isMetric;
@synthesize useIntervalTimer;
@synthesize intervalTimes;
@synthesize walkInterval;
@synthesize runInterval;
@synthesize fullname;
@synthesize dob;
@synthesize genderInt;
@synthesize genderStr;



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
    self.isMetric = [defaults boolForKey:@"isMetric"];
    self.useIntervalTimer = [defaults boolForKey:@"useIntervalTimer"];
    self.intervalTimes = [defaults arrayForKey:@"intervalTimes"];
    self.walkInterval = [defaults boolForKey:@"walkInterval"];
    self.runInterval = [defaults boolForKey:@"runInterval"];
    self.fullname = [defaults stringForKey:@"name"];
    self.dob = (NSDate*)[defaults objectForKey:@"dob"];
    self.genderInt = [defaults integerForKey:@"gender"];
    self.genderStr = [NSString stringWithFormat:@"%@", self.genderInt ? @"Female" : @"Male"]; // 0 male, 1 female
    
    NSLog(@"Metric: %@", self.isMetric ? @"YES" : @"NO");
    NSLog(@"Int Timer: %@", self.useIntervalTimer ? @"YES" : @"NO");
    
    
}

- (void)saveUserSettings
{
    
}

@end

//
//  SettingsAppDataObject.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/23/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "SettingsDataObject.h"

@implementation SettingsDataObject

#pragma mark - Properties

@synthesize managedObjectContext;

// Examples
//@synthesize string1;
//@synthesize data1;
//@synthesize float1;

#pragma mark - Functions

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

@end

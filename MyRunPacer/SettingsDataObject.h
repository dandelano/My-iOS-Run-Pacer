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
    
    // examples
    //NSString*	string1;
    //NSData*		data1;
    //NSInteger	int1;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


// examples
//@property (nonatomic, copy) NSString* string1;
//@property (nonatomic, retain) NSData* data1;
//@property (nonatomic) float float1;

#pragma mark - Functions

- (void)addSettingForKey:(NSString*)key andValue:(NSString*)value;
- (NSString*)getNSStringSettingForKey:(NSString*)key;

@end

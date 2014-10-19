//
//  Location.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/17/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSManagedObject *run;

@end

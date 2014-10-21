//
//  Run.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/17/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSOrderedSet *locations;
@end

@interface Run (CoreDataGeneratedAccessors)

- (void)insertObject:(Location *)value inLocationAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLocationAtIndex:(NSUInteger)idx;
- (void)insertLocation:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLocationAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLocationAtIndex:(NSUInteger)idx withObject:(Location *)value;
- (void)replaceLocationAtIndexes:(NSIndexSet *)indexes withLocation:(NSArray *)values;
- (void)addLocationObject:(Location *)value;
- (void)removeLocationObject:(Location *)value;
- (void)addLocation:(NSOrderedSet *)values;
- (void)removeLocation:(NSOrderedSet *)values;
@end

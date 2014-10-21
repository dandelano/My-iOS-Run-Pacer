//
//  MathController.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/20/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end

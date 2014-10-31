//
//  HomeViewController.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/19/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DSHomeViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

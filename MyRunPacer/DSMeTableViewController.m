//
//  DSMeTableViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/30/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSMeTableViewController.h"
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"
#import "MathController.h"

// NOTE: This method of caching the formatter does not account for a change in locale
static NSDateFormatter *formatter = nil;

@interface DSMeTableViewController ()

@property (nonatomic, weak) SettingsDataObject *settingsDataObj;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *numOfActivitiesLabel;
@property (nonatomic, weak) IBOutlet UILabel *firstRunDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastRunDateLabel;

@property (nonatomic) NSString *userName;
@property (nonatomic) NSDate *firstRunDate;
@property (nonatomic) NSDate *lastRunDate;
@property (nonatomic) float totalDistance;
@property (nonatomic) int numberOfActivities;

@end

@implementation DSMeTableViewController

- (SettingsDataObject*)settingsDataObject
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (SettingsDataObject*) theDelegate.settingsDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsDataObj = [self settingsDataObject];
    
    // Set the date formatter for the table view
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd yyyy"];
    }
    
    self.totalDistance = 0.0;
    self.numberOfActivities = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchUserInfo];
    NSString *name = [self.settingsDataObj fullname];
    self.nameLabel.text = [name length] == 0 ? @"Not Set" : name;
    self.distanceLabel.text = [MathController stringifyDistance:self.totalDistance];
    self.numOfActivitiesLabel.text = [NSString stringWithFormat:@"%i Activities Logged",self.numberOfActivities];
    
    // format Day,Month day year
    self.firstRunDateLabel.text = [NSString stringWithFormat:@"Active Since: %@", [formatter stringFromDate:self.firstRunDate]];
    self.lastRunDateLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self.lastRunDate]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch activity stats

- (void)fetchUserInfo
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.settingsDataObj.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"timestamp",@"distance",nil]];
    
    NSExpression *timestampPathExpression = [NSExpression expressionForKeyPath:@"timestamp"];
    NSExpression *distancePathExpression = [NSExpression expressionForKeyPath:@"distance"];
    
    // Total activities count
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
                                                              arguments:[NSArray arrayWithObject:timestampPathExpression]];
    
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    [countExpressionDescription setName:@"countTotal"];
    [countExpressionDescription setExpression:countExpression];
    [countExpressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    // Total distance
    NSExpression *totalDistanceExpression = [NSExpression expressionForFunction:@"sum:"
                                                                      arguments:[NSArray arrayWithObject:distancePathExpression]];
    
    NSExpressionDescription *totalDistanceExpressionDescription = [[NSExpressionDescription alloc] init];
    [totalDistanceExpressionDescription setName:@"distanceTotal"];
    [totalDistanceExpressionDescription setExpression:totalDistanceExpression];
    [totalDistanceExpressionDescription setExpressionResultType:NSFloatAttributeType];
    
    // earliest date
    NSExpression *earliestExpression = [NSExpression expressionForFunction:@"min:"
                                                                 arguments:[NSArray arrayWithObject:timestampPathExpression]];
    
    NSExpressionDescription *earliestExpressionDescription = [[NSExpressionDescription alloc] init];
    [earliestExpressionDescription setName:@"firstRunDate"];
    [earliestExpressionDescription setExpression:earliestExpression];
    [earliestExpressionDescription setExpressionResultType:NSDateAttributeType];
    
    // Last date active
    NSExpression *latestExpression = [NSExpression expressionForFunction:@"max:"
                                                               arguments:[NSArray arrayWithObject:timestampPathExpression]];
    
    NSExpressionDescription *latestExpressionDescription = [[NSExpressionDescription alloc] init];
    [latestExpressionDescription setName:@"lastRunDate"];
    [latestExpressionDescription setExpression:latestExpression];
    [latestExpressionDescription setExpressionResultType:NSDateAttributeType];
    
    // set fetchrequest properties
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: countExpressionDescription, totalDistanceExpressionDescription, earliestExpressionDescription, latestExpressionDescription, nil]];
    
    // do the fetch
    NSError *error = nil;
    NSArray *fetchResults = [self.settingsDataObj.managedObjectContext
                             executeFetchRequest:fetchRequest
                             error:&error];
    // get the results
    NSNumber *count = [[fetchResults lastObject] valueForKey:@"countTotal"];
    NSNumber *distanceTotal = [[fetchResults lastObject] valueForKey:@"distanceTotal"];
    NSDate *firstRunDate = [[fetchResults lastObject] valueForKey:@"firstRunDate"];
    NSDate *lastRunDate = [[fetchResults lastObject] valueForKey:@"lastRunDate"];
    
    // Update the class values
    self.numberOfActivities = count.intValue;
    self.totalDistance = distanceTotal.floatValue;
    self.firstRunDate = firstRunDate;
    self.lastRunDate = lastRunDate;
}

@end

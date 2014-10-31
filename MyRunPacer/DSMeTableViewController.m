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

@interface DSMeTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfActivitiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstRunDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastRunDateLabel;


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
    self.userName = @"Full Name";
    self.totalDistance = 0.0;
    self.numberOfActivities = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchUserInfo];
    self.nameLabel.text = self.userName;
    self.distanceLabel.text = [MathController stringifyDistance:self.totalDistance];
    self.numOfActivitiesLabel.text = [NSString stringWithFormat:@"%i Activities Logged",self.numberOfActivities];
    self.firstRunDateLabel.text = @"Active Since: Oct, 10 2014";
    self.lastRunDateLabel.text = @"Oct, 10 2014";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch activity stats

- (void)fetchUserInfo
{
    SettingsDataObject *settingsDataObject = [self settingsDataObject];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:settingsDataObject.managedObjectContext];
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
    NSArray *fetchResults = [settingsDataObject.managedObjectContext
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

#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

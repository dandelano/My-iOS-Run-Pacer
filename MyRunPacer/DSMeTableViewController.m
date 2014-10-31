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

@interface DSMeTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfActivitiesLabel;


@property (nonatomic) NSString *userName;
@property (nonatomic) float totalDistance;
@property (nonatomic) int numberOfActivities;

@end

@implementation DSMeTableViewController

- (SettingsDataObject*)settingsDataObject
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    SettingsDataObject* theDataObject = (SettingsDataObject*) theDelegate.settingsDataObject;
    return theDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName = @"Dan";
    self.totalDistance = 10;
    self.numberOfActivities = 0;
    
    SettingsDataObject *settingsDataObject = [self settingsDataObject];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Run" inManagedObjectContext:settingsDataObject.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"timestamp"];
   
    // First run expression
    NSExpression *countExpression =
                [NSExpression expressionForFunction:@"count:"
                arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    [countExpressionDescription setName:@"countTotal"];
    [countExpressionDescription setExpression:countExpression];
    [countExpressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    // latest run expression
    NSExpression *latestExpression =
                [NSExpression expressionForFunction:@"max:"
                arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *latestExpressionDescription = [[NSExpressionDescription alloc] init];
    [latestExpressionDescription setName:@"latestDate"];
    [latestExpressionDescription setExpression:latestExpression];
    [latestExpressionDescription setExpressionResultType:NSDateAttributeType];
    
    // set fetchrequest properties
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:
                                        countExpressionDescription]];
    
    // do the fetch
    NSError *error = nil;
    NSArray *fetchResults = [settingsDataObject.managedObjectContext
                             executeFetchRequest:fetchRequest
                             error:&error];
    // get the results
    NSNumber *count = [[fetchResults lastObject] valueForKey:@"countTotal"];
    //NSDate *latest = [[fetchResults lastObject] valueForKey:@"latestDate"];
    
    self.numOfActivitiesLabel.text = [NSString stringWithFormat:@"%i",count.intValue];
    //self.distanceLabel.text = [NSString stringWithFormat:@"%@",latest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nameLabel.text = self.userName;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f Miles",self.totalDistance];
    //self.numOfActivitiesLabel.text = [NSString stringWithFormat:@"%i", self.numberOfActivities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

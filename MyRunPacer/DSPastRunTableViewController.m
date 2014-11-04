//
//  PastRunTableViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/23/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSPastRunTableViewController.h"
#import "DSRunDetailTableViewController.h"
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"
#import "DSPastRunTableViewCell.h"
#import "MathController.h"
#import "Run.h"

// NOTE: This method of caching the formatter does not account for a change in locale
static NSDateFormatter *formatter = nil;
static NSString * const detailSegueName = @"RunDetail@Home";

@interface DSPastRunTableViewController ()

@property (strong, nonatomic) NSArray *runArray;

@end

@implementation DSPastRunTableViewController

- (SettingsDataObject*)settingsDataObject
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (SettingsDataObject*) theDelegate.settingsDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Set the date formatter for the table view
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE,MMM dd yyyy"];
    }
    
    SettingsDataObject *settingsDataObject = [self settingsDataObject];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Run" inManagedObjectContext:settingsDataObject.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.runArray = [settingsDataObject.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.runArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdent = @"PastRunCell";
    
    DSPastRunTableViewCell *cell = (DSPastRunTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdent forIndexPath:indexPath];
    
    if (cell == nil) {        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DSPastRunTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    Run *run = [self.runArray objectAtIndex:indexPath.row];
    cell.distanceLabel.text = [MathController stringifyDistance: run.distance.floatValue];
    cell.durationLabel.text = [MathController stringifySecondCount:run.duration.intValue usingLongFormat:YES];
    
    // format Day,Month day year
    NSString *date = [formatter stringFromDate:run.timestamp];
    NSArray *date_components = [date componentsSeparatedByString:@","];
    cell.dayLabel.text = date_components[0];
    cell.dateLabel.text = date_components[1];
    
}

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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:detailSegueName sender:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // send run to detail view
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Run *thisRun = [self.runArray objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setRun: thisRun];
    }
    
}


@end

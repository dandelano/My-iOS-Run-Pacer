//
//  DSSettingsTableViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/30/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSSettingsTableViewController.h"
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"
#import "DSSettingSelectTableViewController.h"

// TODO: Implement setting and getting of user settings
static NSDateFormatter *formatter = nil;
static NSString * const settingSelectSegueName = @"settingSelect";

@interface DSSettingsTableViewController ()

@property (weak,nonatomic) SettingsDataObject *settingsDataObj;
@property (nonatomic) CellSelector selectedCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *distanceUnitCell;
@property (weak, nonatomic) IBOutlet UISwitch *useIntervalTimerSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *walkIntervalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *runIntervalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *userNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dobCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderCell;

@end

@implementation DSSettingsTableViewController

- (SettingsDataObject*)settingsDataObject
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (SettingsDataObject*) theDelegate.settingsDataObject;
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    self.settingsDataObj = [self settingsDataObject];
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd yyyy"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Use the isMetric bool to get the string representations from array
    self.distanceUnitCell.detailTextLabel.text = [[self.settingsDataObj distanceUnits_Str] objectAtIndex:[self.settingsDataObj isMetric] ? 1 : 0];
    // Use bool to set switch on or off
    [self.useIntervalTimerSwitch setOn:[self.settingsDataObj useIntervalTimer]];
    // Display string of walk interval seconds
    self.walkIntervalCell.detailTextLabel.text = [[self.settingsDataObj intervalTimes_Str] objectAtIndex:[self.settingsDataObj walkIntervalIndex_Int]];
    // Display string of run interval seconds
    self.runIntervalCell.detailTextLabel.text = [[self.settingsDataObj intervalTimes_Str] objectAtIndex:[self.settingsDataObj runIntervalIndex_Int]];
    // Get string for name
    self.userNameCell.detailTextLabel.text = [self.settingsDataObj name_Str];
    // format Day,Month day year
    self.dobCell.detailTextLabel.text = [formatter stringFromDate:[self.settingsDataObj dob_Date]];
    // Use the gender index to get the string value
    self.genderCell.detailTextLabel.text = [[self.settingsDataObj genders_Str] objectAtIndex:[self.settingsDataObj genderIndex_Int]];
}

#pragma mark - Interval Switch

- (IBAction)switchChanged:(id)sender
{
    if ([sender isOn]) {
        [self.settingsDataObj setUseIntervalTimer:YES];
    } else {
        [self.settingsDataObj setUseIntervalTimer:NO];
    }
}


#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (theCellClicked == self.distanceUnitCell) {
        NSLog(@"Distance cell");
        self.selectedCell = csDistanceUnitCell;
    } else if (theCellClicked == self.walkIntervalCell) {
        NSLog(@"walk cell");
        self.selectedCell = csWalkIntervalCell;
    } else if (theCellClicked == self.runIntervalCell) {
        NSLog(@"run cell");
        self.selectedCell = csRunIntervalCell;
    } else if (theCellClicked == self.userNameCell) {
        NSLog(@"username cell");
        self.selectedCell = csUserNameCell;
    } else if (theCellClicked == self.dobCell) {
        NSLog(@"dob cell");
        self.selectedCell = csDobCell;
    } else if (theCellClicked == self.genderCell) {
        NSLog(@"gender cell");
        self.selectedCell = csGenderCell;
    } else {
        NSLog(@"Different cell selected");
        return;
    }
    
    [self performSegueWithIdentifier:settingSelectSegueName sender:nil];
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:settingSelectSegueName]) {
        [[segue destinationViewController] setSelectedOptions: self.selectedCell];
    }
}

@end

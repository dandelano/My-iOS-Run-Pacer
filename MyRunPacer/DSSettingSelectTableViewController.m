//
//  DSSettingSelectTableViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 11/5/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSSettingSelectTableViewController.h"
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"

#define dDatePickerTag  99  // view tag for identifiying the date picker
#define dNameTextFieldTag   98 // view tag for identifiying the name input field

static NSString * const dOptionID = @"optionCell";
static NSString * const dNameID = @"nameCell";
static NSString * const dDatePickerID = @"datePickerCell";

@interface DSSettingSelectTableViewController () <UITextFieldDelegate>

@property (nonatomic,weak) SettingsDataObject *settingsDataObj;

// Date for datepicker
@property (nonatomic,weak) NSDate *dobDate;
// Text for Name
@property (nonatomic, weak) NSString *usernameStr;

// Options for any list type options
@property (nonatomic,retain) NSIndexPath *checkedOption;
@property (nonatomic,weak) NSArray *options;
@property (nonatomic) NSInteger selectedOption;



@end

@implementation DSSettingSelectTableViewController

- (SettingsDataObject*)settingsDataObject
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (SettingsDataObject*) theDelegate.settingsDataObject;
}

- (void)setSelectedOptions:(CellSelector)selectedOptions
{
    if (_selectedOptions != selectedOptions) {
        _selectedOptions = selectedOptions;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.settingsDataObj = [self settingsDataObject];
    [self loadValuesForOption];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Settings

- (void)loadValuesForOption
{
    switch (self.selectedOptions) {
        case csDistanceUnitCell:
            self.options = self.settingsDataObj.distanceUnits_Str;
            self.selectedOption = [self.settingsDataObj isMetric] ? 1 : 0;
            break;
        case csWalkIntervalCell:
            self.options = self.settingsDataObj.intervalTimes_Str;
            self.selectedOption = [self.settingsDataObj walkIntervalIndex_Int];
            break;
        case csRunIntervalCell:
            self.options = self.settingsDataObj.intervalTimes_Str;
            self.selectedOption = [self.settingsDataObj runIntervalIndex_Int];
            break;
        case csUserNameCell:
            self.usernameStr = [self.settingsDataObj name_Str];
            break;
        case csDobCell:
            self.dobDate = [self.settingsDataObj dob_Date];
            break;
        case csGenderCell:
            self.options = self.settingsDataObj.genders_Str;
            self.selectedOption = [self.settingsDataObj genderIndex_Int];
            break;
    }
}

- (void)selectValueForOption:(NSInteger)index
{
    if (index < self.options.count) {
        switch (self.selectedOptions) {
            case csDistanceUnitCell:
                [self.settingsDataObj setIsMetric: (index == 0 ? NO : YES)];
                break;
            case csWalkIntervalCell:
                [self.settingsDataObj setWalkIntervalIndex_Int: index];
                break;
            case csRunIntervalCell:
                [self.settingsDataObj setRunIntervalIndex_Int: index];
                break;
            case csGenderCell:
                [self.settingsDataObj setGenderIndex_Int: index];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
     if (self.selectedOptions == csDobCell || self.selectedOptions == csUserNameCell)
         return 1;
    else
        return self.options.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.selectedOptions) {
        case csDobCell:
            NSLog(@"Date cell selected");
            break;
        case csUserNameCell:
            NSLog(@"Textfield cell selected");
            break;
        default:
            // Uncheck the previous checked row
            if(self.checkedOption)
                [tableView cellForRowAtIndexPath:self.checkedOption].accessoryType = UITableViewCellAccessoryNone;
            
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedOption = indexPath;
            self.selectedOption = indexPath.row;
            [self selectValueForOption:indexPath.row];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    UIDatePicker *datePicker = nil;
    UITextField *nameInputTxt = nil;
    
    switch (self.selectedOptions) {
        case csDobCell:
            cell = [tableView dequeueReusableCellWithIdentifier:dDatePickerID forIndexPath:indexPath];
            datePicker = (UIDatePicker *)[cell viewWithTag:dDatePickerTag];
            datePicker.date = self.dobDate;
            return cell;
            break;
        case csUserNameCell:
            cell = [tableView dequeueReusableCellWithIdentifier:dNameID forIndexPath:indexPath];
            nameInputTxt = (UITextField *)[cell viewWithTag:dNameTextFieldTag];
            nameInputTxt.text = [self.usernameStr isEqualToString:@"Not Set"] ? @"" : self.usernameStr;
            return cell;
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:dOptionID forIndexPath:indexPath];
            if (indexPath.row == self.selectedOption) {
                self.checkedOption = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.options objectAtIndex:indexPath.row]];
            return cell;
            break;
    }
}

#pragma mark - DatePicker Actions

- (IBAction)dateChanged:(UIDatePicker *)datePicker
{
    [self.settingsDataObj setDob_Date:[datePicker date]];
}

- (IBAction)nameDidChange:(UITextField*)textField
{
    [self.settingsDataObj setName_Str:[textField text]];
}


@end

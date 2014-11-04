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

// TODO: Implement setting and getting of user settings

@interface DSSettingsTableViewController () <UITextFieldDelegate>

@property (weak,nonatomic) SettingsDataObject *settingsDataObj;

@property (weak, nonatomic) IBOutlet UITableViewCell *distanceUnitCell;
@property (weak, nonatomic) IBOutlet UISwitch *useIntervalTimerSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *walkIntervalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *runIntervalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dobCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderCell;

@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;

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
    
    self.nameTxtField.delegate = self;
    
    self.nameTxtField.text = [self.settingsDataObj fullname];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self.view endEditing:YES];
//    return YES;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

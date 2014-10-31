//
//  HomeViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/19/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSHomeViewController.h"
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"
#import "DSNewRunViewController.h"
#import "DSPastRunTableViewController.h"

@interface DSHomeViewController () 

@property (weak, nonatomic) IBOutlet UIButton *nRunBtn;
@property (weak, nonatomic) IBOutlet UIButton *pRunBtn;


@property (strong, nonatomic) NSArray *runArray;

@end

@implementation DSHomeViewController

- (SettingsDataObject*)settingsDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    SettingsDataObject* theDataObject = (SettingsDataObject*) theDelegate.settingsDataObject;
    return theDataObject;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nRunBtn.backgroundColor = [UIColor colorWithRed:0/255.0f green:146/255.0f blue:69/255.0f alpha:1.0f];
    self.pRunBtn.backgroundColor = [UIColor colorWithRed:39/255.0f green:88/255.0f blue:130/255.0f alpha:1.0f];
    
}


// TODO: Finish implementing the fetch request to send to the new table view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SettingsDataObject *settingsDataObject = [self settingsDataObject];
    
    [settingsDataObject addSettingForKey:@"key" andValue:@"value"];
    NSLog([settingsDataObject getNSStringSettingForKey:@"key"]);
    
    UIViewController *nextController = [segue destinationViewController];
    if ([nextController isKindOfClass:[DSNewRunViewController class]]) {
        ((DSNewRunViewController *) nextController).managedObjectContext = settingsDataObject.managedObjectContext;
    }else if ([nextController isKindOfClass:[DSPastRunTableViewController class]]) {
        ((DSPastRunTableViewController *) nextController).managedObjectContext = settingsDataObject.managedObjectContext;
    }}

@end

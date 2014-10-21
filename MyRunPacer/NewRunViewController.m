//
//  NewRunViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/19/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "NewRunViewController.h"
#import "DetailViewController.h"
#import "Run.h"
#import <CoreLocation/CoreLocation.h>
#import "MathController.h"
#import "Location.h"

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate>

// LocationManager
@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

// ActionSheet
@property (nonatomic, strong) Run *run;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;

@end

@implementation NewRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.startButton.hidden = NO;
    self.promptLabel.hidden = NO;
    
    self.timeLabel.text = @"Time: 00:00";
    self.timeLabel.hidden = YES;
    self.distLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.stopButton.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

#pragma mark - Button Actions

- (IBAction)startPressed:(id)sender
{
    // hide the start UI
    self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    // show the running UI
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.stopButton.hidden = NO;
    
    // Start location and time
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self startLocationUpdates];
}

- (IBAction)stopPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save",@"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - Saving

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // save
    if (buttonIndex == 0) {
        [self saveRun]; // Added the saveRun function
        [self performSegueWithIdentifier:detailSegueName sender:nil];
    // discard
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)saveRun
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // save the context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@",error, [error userInfo]);
        abort();
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue destinationViewController] setRun:self.run];
}

#pragma mark - Timer

- (void)eachSecond
{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
}

#pragma mark - Locations

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // movement threshold for new events
    self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 20) {
            
            // Update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

@end

//
//  DSNewRunTableViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 11/3/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "DSNewRunTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegateProtocol.h"
#import "SettingsDataObject.h"
#import "MathController.h"
#import "Run.h"
#import "Location.h"


// TODO: Fix the state of view when stop button is pressed, and activity is discarded.
// TODO: Incorporate user settings into functionality
// TODO: Fix saving method
// TODO: Fix Interval timer functionality

static NSString * const detailSegueName = @"RunDetails";

@interface DSNewRunTableViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, weak) SettingsDataObject *settingsDataObj;

// Flag for is app started
@property BOOL isActivityStarted;

// Pace buzzer feature flag
@property BOOL isIntervalTimerOn;

// is walking or running interval
@property BOOL isWalking;

// Holds values for interval times
@property int paceWalkTimeSeconds;
@property int paceRunTimeSeconds;

// Used for countdown, and display
@property int paceCountSeconds;
@property NSString *intervalMsg;

// MapView
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

// LocationManager
@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

// ActionSheet
@property (nonatomic, strong) Run *run;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UITableViewCell *distanceCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *timeCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *paceCell;
@property (nonatomic, weak) IBOutlet UISwitch *useIntervalTimerSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *intervalTimeCell;
@property (nonatomic, weak) IBOutlet UIButton *startButton;

@end

@implementation DSNewRunTableViewController

- (SettingsDataObject*)settingsDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return (SettingsDataObject*) theDelegate.settingsDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsDataObj = [self settingsDataObject];
    // Do any additional setup after loading the view.
    self.isActivityStarted = NO;
    
    // set pace timer
    self.isIntervalTimerOn = [self.settingsDataObj useIntervalTimer];
    [self.useIntervalTimerSwitch setOn: [self.settingsDataObj useIntervalTimer]];
    
    // Set the initial values
    self.paceWalkTimeSeconds = [(NSNumber *)[[self.settingsDataObj intervalTimes] objectAtIndex:[self.settingsDataObj walkInterval]] intValue];
    self.paceRunTimeSeconds = [(NSNumber *)[[self.settingsDataObj intervalTimes] objectAtIndex:[self.settingsDataObj runInterval]] intValue];
    
    self.intervalMsg = @"Walking";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setDefaultViewState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.timer invalidate];
}

#pragma mark - Default States

- (void)setDefaultViewState
{
    self.mapView.hidden = YES;
    
    // Show as start button
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor colorWithRed:0/255.0f green:146/255.0f blue:69/255.0f alpha:1.0f];
    self.startButton.hidden = NO;
    
    self.promptLabel.hidden = NO;
    
    self.timeCell.detailTextLabel.hidden = YES;
    self.distanceCell.detailTextLabel.hidden = YES;
    self.paceCell.detailTextLabel.hidden = YES;
    
    if (self.isIntervalTimerOn == NO)
        self.intervalTimeCell.hidden = YES;
    else
        self.intervalTimeCell.hidden = NO;
    
    [self.useIntervalTimerSwitch setEnabled:YES];
}

#pragma mark - Button Actions

- (IBAction)startPressed:(id)sender
{
    if (self.isActivityStarted == NO) {
        [self startAction];
    } else {
        [self stopAction];
    }
}

- (void)startAction
{
    // hide the start UI
    //self.startButton.hidden = YES;
    self.promptLabel.hidden = YES;
    
    // set pace timer
    [self.useIntervalTimerSwitch setEnabled:NO];
    
    if (self.isIntervalTimerOn) {
        self.intervalTimeCell.detailTextLabel.text = [NSString stringWithFormat:@"00:%02i %@",self.paceWalkTimeSeconds, self.intervalMsg];
        self.paceCountSeconds = self.paceWalkTimeSeconds;
        self.isWalking = YES;
        self.intervalTimeCell.hidden = NO;
    }
    
    // show the running UI
    self.distanceCell.detailTextLabel.hidden = NO;
    self.timeCell.detailTextLabel.hidden = NO;
    self.paceCell.detailTextLabel.hidden = NO;
    
    // Show as stop button
    [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor redColor];
    
    // Start location and time
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self startLocationUpdates];
    
    self.mapView.hidden = NO;
    
    // set the running state
    self.isActivityStarted = YES;
}

- (void)stopAction
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save",@"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - Pacer Switch

- (IBAction)switchChanged:(id)sender
{
    if ([sender isOn]) {
        self.isIntervalTimerOn = YES;
        self.intervalTimeCell.hidden = NO;
    } else {
        self.isIntervalTimerOn = NO;
        self.intervalTimeCell.hidden = YES;
    }
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
        self.isActivityStarted = NO;
        [self.timer invalidate];
        [self setDefaultViewState];
    }
}

- (void)saveRun
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.settingsDataObj.managedObjectContext];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.settingsDataObj.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // save the context
    NSError *error = nil;
    if (![self.settingsDataObj.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@",error, [error userInfo]);
        abort();
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:detailSegueName]) {
        [[segue destinationViewController] setRun:self.run];
    }
}

#pragma mark - Timer

- (void)eachSecond
{
    self.seconds++;
    
    self.timeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distanceCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance]];
    self.paceCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    
    // check pacer if enabled
    if (self.isIntervalTimerOn) {
        [self checkPacer];
        self.intervalTimeCell.detailTextLabel.text = [NSString stringWithFormat:@"00:%02i %@",self.paceCountSeconds, self.intervalMsg];
    }
    
}

- (void)checkPacer
{
    // decrement pacer count
    self.paceCountSeconds--;
    
    // check if less than 0
    if (self.paceCountSeconds <= 0) {
        //buzz phone
        [self vibratePhone];
        //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        // switch walking/running and reset to next count
        if (self.isWalking) {
            self.isWalking = NO;
            self.intervalMsg = @"Running";
            self.paceCountSeconds = self.paceRunTimeSeconds;
        } else {
            self.isWalking = YES;
            self.intervalMsg = @"Walking";
            self.paceCountSeconds = self.paceWalkTimeSeconds;
        }
    }
}

- (void)vibratePhone;
{
    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
    {
        AudioServicesPlaySystemSound (1352); //works ALWAYS as of this post
    }
    else
    {
        // Not an iPhone, so doesn't have vibrate
        // play the less annoying tick noise or one of your own
        AudioServicesPlayAlertSound (1105);
    }
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
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (abs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // Update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
                
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

#pragma mark - MapView

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}


@end

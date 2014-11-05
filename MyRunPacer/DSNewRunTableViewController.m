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

// TODO: Possible conflict with timing in the actionsheet clickbutton

typedef enum {
    asSave = 0,
    asDiscard,
    asCancel
} ActShtBtn;

static NSString * const detailSegueName = @"RunDetails";

@interface DSNewRunTableViewController () <UITabBarControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, weak) SettingsDataObject *settingsDataObj;
@property (nonatomic, strong) Run *run;

// Flag for is app started
@property BOOL isActivityStarted;

// Pace buzzer feature flag
@property BOOL isIntervalTimerOn;

// is walking or running interval
@property BOOL isWalking;

// Holds values for interval times
@property int paceWalkTimeSeconds;
@property int paceRunTimeSeconds;

// LocationManager
@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

// View outlets
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
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
    [self.tabBarController setDelegate:self];
    
    self.settingsDataObj = [self settingsDataObject];
    [self setStartingViewState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isIntervalTimerOn = [self.settingsDataObj useIntervalTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Default States

- (void)setStartingViewState
{
    self.isActivityStarted = NO;
    
    // clear labels
    self.timeCell.detailTextLabel.text = @"-";
    self.distanceCell.detailTextLabel.text = @"-";
    self.paceCell.detailTextLabel.text = @"-";
    self.intervalTimeCell.detailTextLabel.text = @"-";
    
    // Show as start button and ready label
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor colorWithRed:0/255.0f green:146/255.0f blue:69/255.0f alpha:1.0f];
    self.startButton.hidden = NO;
    self.promptLabel.hidden = NO;
    
    // Hide map and other labels
    self.mapView.hidden = YES;
    self.timeCell.detailTextLabel.hidden = YES;
    self.distanceCell.detailTextLabel.hidden = YES;
    self.paceCell.detailTextLabel.hidden = YES;
    
    // set pace timer
    //self.isIntervalTimerOn = [self.settingsDataObj useIntervalTimer];
    [self.useIntervalTimerSwitch setEnabled:YES];
    [self.useIntervalTimerSwitch setOn: self.isIntervalTimerOn];
    
    // If switch is YES, cell.hidden is NO
    self.intervalTimeCell.hidden = !self.isIntervalTimerOn;
    
    // Set values to default zeros
    self.seconds = 0;
    self.distance = 0.0;
    
    // if not nil or empty, remove all objects
    if (!self.locations || ![self.locations count]){
        [self.locations removeAllObjects];
    }
    
    NSArray *pointsArray = [self.mapView overlays];
    [self.mapView removeOverlays:pointsArray];
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
    self.promptLabel.hidden = YES;
    
    // disable interval timer switch during run
    [self.useIntervalTimerSwitch setEnabled:NO];
    
    if (self.isIntervalTimerOn) {
        // Set the initial values
        self.paceWalkTimeSeconds = [(NSNumber *)[[self.settingsDataObj intervalTimes] objectAtIndex:[self.settingsDataObj walkInterval]] intValue];
        self.paceRunTimeSeconds = [(NSNumber *)[[self.settingsDataObj intervalTimes] objectAtIndex:[self.settingsDataObj runInterval]] intValue];
        self.isWalking = YES;
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
    // check and delete locations then create new array
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
        [self.settingsDataObj setUseIntervalTimer:YES];
    } else {
        self.isIntervalTimerOn = NO;
        self.intervalTimeCell.hidden = YES;
        [self.settingsDataObj setUseIntervalTimer:NO];
    }
}

#pragma mark - Saving

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case asSave:
            [self saveRun];
            [self performSegueWithIdentifier:detailSegueName sender:nil];
            //break;
        case asDiscard:
            [self.timer invalidate];
            [self.locationManager stopUpdatingLocation];
            [self setStartingViewState];
            break;
        case asCancel:
            break;
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

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (self.isActivityStarted == YES)
        return NO;
    else
        return YES;
}

#pragma mark - Timer

- (void)eachSecond
{
    self.seconds++;
    
    // Update display cells
    self.timeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distanceCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance]];
    self.paceCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    
    // check interval timer if enabled
    if (self.isIntervalTimerOn)
        [self checkPacer];
    
}

- (void)checkPacer
{
    static NSString *intervalMsg = @"Walking";
    static int intervalCountSeconds = 0;
    intervalCountSeconds++; // increment pace count
    
    // if isWalking, get walk time remaining, else get run time remaining
    int count = (self.isWalking == YES) ? (self.paceWalkTimeSeconds - intervalCountSeconds) : (self.paceRunTimeSeconds - intervalCountSeconds);
    
    if (count <= 0) {
        [self vibratePhone]; // buzz phone
        self.isWalking = !self.isWalking; // switch action
        intervalMsg = (self.isWalking == YES) ? @"Walking" : @"Running";
        intervalCountSeconds = 0; // reset
    }
    
    // update display label
    self.intervalTimeCell.detailTextLabel.text = [NSString stringWithFormat:@"00:%02i %@",count, intervalMsg];
}

- (void)vibratePhone;
{
    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
        AudioServicesPlaySystemSound (1352); //works ALWAYS as of this post
    else
        AudioServicesPlayAlertSound (1105); // Not an iPhone, so doesn't have vibrate, play sound of your own
}

#pragma mark - Locations

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
    
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

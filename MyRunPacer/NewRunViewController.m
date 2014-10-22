//
//  NewRunViewController.m
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/19/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import "NewRunViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DetailViewController.h"
#import "MathController.h"
#import "Run.h"
#import "Location.h"

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// Flag for is app started
@property BOOL isActivityStarted;

// Pace buzzer feature flag
@property BOOL isPacerOn;

// is walking or running interval
@property BOOL isWalking;

// Holds values for interval times
@property int paceWalkTimeSeconds;
@property int paceRunTimeSeconds;

// Used for countdown, and display
@property int paceCountSeconds;
@property NSString *intervalMsg;

// Array of interval time values
@property NSArray *pickerData;

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
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalTimeLabel;

@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UISwitch *usePacerSwitch;

// Pacer time picker
@property (weak, nonatomic) IBOutlet UIView *PopUpPickerView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation NewRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.isActivityStarted = NO;
    
    // set pace timer
    self.isPacerOn = NO;
    
    _pickerData = @[@30,@60,@90];
    
    // Set the initial values
    self.paceWalkTimeSeconds = 30;
    self.paceRunTimeSeconds = 30;
    
    self.intervalMsg = @"Walking";
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.hidden = YES;
    
    // Show as start button
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor colorWithRed:0/255.0f green:146/255.0f blue:69/255.0f alpha:1.0f];
    self.startButton.hidden = NO;
    
    self.promptLabel.hidden = NO;
    
    self.timeLabel.text = @"Time: 00:00";
    self.timeLabel.hidden = YES;
    self.distLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.intervalTimeLabel.hidden = YES;
    
    [self.usePacerSwitch setEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
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
    [self.usePacerSwitch setEnabled:NO];
    
    if (self.isPacerOn) {
        self.intervalTimeLabel.text = [NSString stringWithFormat:@"Interval Time: 00:%02i %@",self.paceWalkTimeSeconds, self.intervalMsg];
        self.paceCountSeconds = self.paceWalkTimeSeconds;
        self.isWalking = YES;
        self.intervalTimeLabel.hidden = NO;
    }
    
    // show the running UI
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    
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
        [self showPickerView];
        self.isPacerOn = YES;
    } else {
        self.isPacerOn = NO;
    }
}

#pragma mark - PickerView done button

- (IBAction)pickerDoneButton:(id)sender {
    [self hidePickerView];
}

- (void)showPickerView
{
    self.PopUpPickerView.hidden = NO;
    self.pickerView.hidden = NO;
    self.doneButton.hidden = NO;
}

- (void)hidePickerView
{
    self.PopUpPickerView.hidden = YES;
    self.pickerView.hidden = YES;
    self.doneButton.hidden = YES;
}



#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    switch (component) {
        case 0:
            title = [NSString stringWithFormat:@"%@ Sec Walk", _pickerData[row]];
            break;
        case 1:
            title = [NSString stringWithFormat:@"%@ Sec Run", _pickerData[row]];
        default:
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // component is the column
    switch (component) {
        case 0:
            self.paceWalkTimeSeconds = [(NSNumber *)_pickerData[row] intValue];
            break;
        case 1:
            self.paceRunTimeSeconds = [(NSNumber *)_pickerData[row] intValue];
        default:
            break;
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
    
    // check pacer if enabled
    if (self.isPacerOn) {
        [self checkPacer];
        self.intervalTimeLabel.text = [NSString stringWithFormat:@"Interval Time: 00:%02i %@",self.paceCountSeconds, self.intervalMsg];
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

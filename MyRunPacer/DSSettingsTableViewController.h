//
//  DSSettingsTableViewController.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/30/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    csDistanceUnitCell = 0,
    csWalkIntervalCell,
    csRunIntervalCell,
    csUserNameCell,
    csDobCell,
    csGenderCell
} CellSelector;

@interface DSSettingsTableViewController : UITableViewController

@end

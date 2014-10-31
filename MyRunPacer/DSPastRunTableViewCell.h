//
//  DSPastRunTableViewCell.h
//  MyRunPacer
//
//  Created by Danny J. Delano Jr. on 10/28/14.
//  Copyright (c) 2014 Danny J. Delano Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPastRunTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

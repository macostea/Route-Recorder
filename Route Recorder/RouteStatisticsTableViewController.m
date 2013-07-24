//
//  RouteStatisticsTableViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "RouteStatisticsTableViewController.h"

@interface RouteStatisticsTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *maxSpeedCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *meanSpeedCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *maxAltitudeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *totalDistanceCell;

@end

@implementation RouteStatisticsTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxSpeedCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f Km/h", [self.maxSpeed doubleValue]];
    self.meanSpeedCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f Km/h", [self.meanSpeed doubleValue]];
    self.maxAltitudeCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.f m", [self.maxAltitude doubleValue]];
    NSNumber *distance = [NSNumber numberWithDouble:([self.distance doubleValue] / 1000)];
    self.totalDistanceCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f Km", [distance doubleValue]];
    
}

- (void)viewDidUnload {
    [self setMaxSpeedCell:nil];
    [self setMeanSpeedCell:nil];
    [self setMaxAltitudeCell:nil];
    [self setTotalDistanceCell:nil];
    [super viewDidUnload];
}
@end

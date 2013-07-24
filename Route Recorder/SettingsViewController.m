//
//  SettingsViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/22/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "SettingsViewController.h"
#import "RouteRecorder.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *backgroundLocationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *useMetricSwitch;
@end

@implementation SettingsViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad{
    self.backgroundLocationSwitch.on = [RouteRecorder sharedInstance].trackLocationInBackground;
    self.useMetricSwitch.on = [RouteRecorder sharedInstance].useMetric;
  
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (IBAction)toggleBackgroundLocation {
    [RouteRecorder sharedInstance].trackLocationInBackground = self.backgroundLocationSwitch.on;
}

- (IBAction)toggleUseMetric {
    [RouteRecorder sharedInstance].useMetric = self.useMetricSwitch.on;
}

@end

//
//  RouteStatisticsTableViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteStatisticsTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *maxSpeed;
@property (nonatomic, strong) NSNumber *meanSpeed;
@property (nonatomic, strong) NSNumber *maxAltitude;
@property (nonatomic, strong) NSNumber *distance;

@end

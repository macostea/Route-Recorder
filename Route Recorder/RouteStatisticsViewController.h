//
//  RouteStatisticsViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/18/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"
#import "MGBox.h"
#import "Route.h"

@interface RouteStatisticsViewController : UIViewController

@property (strong, nonatomic) IBOutlet MGScrollView *scroller;

@property (nonatomic, strong) NSNumber *maxSpeed;
@property (nonatomic, strong) NSNumber *meanSpeed;
@property (nonatomic, strong) NSNumber *maxAltitude;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong) Route *selectedRoute;

@end

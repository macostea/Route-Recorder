//
//  RouteDetailsTableViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RouteDetailsTableViewController : UITableViewController <MKMapViewDelegate>

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSSet *routePoints;
@property (nonatomic, strong) NSSet *routePhotos;

@end

//
//  MapViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OverlayViewController.h"
#import "MapPoint.h"
#import "RouteRecorder.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, OverlayViewControllerDelegate, CLLocationManagerDelegate> {
    int currentDist;
}

@end

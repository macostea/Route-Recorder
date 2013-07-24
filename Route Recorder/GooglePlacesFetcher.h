//
//  GooglePlacesFetcher.h
//  Route Recorder
//
//  Created by skobbler on 7/15/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"

static NSString* const kGPResults = @"results";
static NSString* const kGPGeometry = @"geometry";
static NSString* const kGPLocation = @"location";
static NSString* const kGPName = @"name";
static NSString* const kGPVicinity = @"vicinity";
static NSString* const kGPLat = @"lat";
static NSString* const kGPLng = @"lng";

@interface GooglePlacesFetcher : NSObject

+ (GooglePlacesFetcher *)sharedInstance;
- (NSArray *)fetchGooglePlaces:(CLLocationCoordinate2D)coordinate currentDist:(int)currentDist;
- (NSData *)fetchStaticRouteMapForRoute:(Route *)route;

@end

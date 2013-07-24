//
//  RouteRecorder.h
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataModel.h"
#import "Route+Create.h"
#import "CoreDataMapPoint+Create.h"
#import <CoreLocation/CoreLocation.h>

static NSString* const kRRLocationChanged = @"locationChanged";
static NSString* const kRROldLocationKey = @"oldLocation";
static NSString* const kRRNewLocationKey = @"newLocation";

@interface RouteRecorder : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) Route *currentRoute;
@property (nonatomic) BOOL trackLocationInBackground;
@property (nonatomic) BOOL useMetric;

+ (RouteRecorder *)sharedInstance;

- (id)init;

- (void)startRecording;
- (void)endRecording;
- (void)addPhoto:(UIImage *)image title:(NSString *)title latitude:(NSNumber *)lat longitude:(NSNumber *)lng inRoute:(Route *)route;

@end

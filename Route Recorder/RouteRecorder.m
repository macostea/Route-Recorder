//
//  RouteRecorder.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "RouteRecorder.h"

static RouteRecorder *_routeRecorder = nil;

static NSString* const kRRTrackLocationInBackgroundKey = @"trackLocationInBackground";
static NSString* const kRRUseMetricKey = @"useMetric";

@interface RouteRecorder()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *oldLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation RouteRecorder
@synthesize trackLocationInBackground = _trackLocationInBackground;
@synthesize useMetric = _useMetric;

+ (RouteRecorder *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _routeRecorder = [[self alloc] init];
    });
    
    return _routeRecorder;
}

- (id)init{
    self = [super init];
    if (self){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startRecording{
    if(!self.currentRoute) {
        self.currentRoute = [[CoreDataModel sharedInstance] startNewRoute];
        [[CoreDataModel sharedInstance].managedObjectContext save:nil];
        NSLog(@"Created Route: %@", self.currentRoute);
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)endRecording{
    [self.locationManager stopUpdatingLocation];
    self.currentRoute.endTime = [NSDate date];
    self.currentRoute.meanSpeed = [NSNumber numberWithDouble:([self.currentRoute.distance doubleValue] / [self.currentRoute.endTime timeIntervalSinceDate:self.currentRoute.startTime]) * 3.6];
    NSLog(@"Route with details: %@", self.currentRoute);
    self.currentRoute = nil;
    [[CoreDataModel sharedInstance].managedObjectContext save:nil];
}

- (void)addPhoto:(UIImage *)image title:(NSString *)title latitude:(NSNumber *)lat longitude:(NSNumber *)lng inRoute:(Route *)route {
    [[CoreDataModel sharedInstance] savePhotoWithData:UIImagePNGRepresentation(image) title:title latitude:lat longitude:lng InRoute: route];
}

/*
 Code review Csongor Korosi
 Move the code from this callback on a background thread. It's called at each location update, so don't do complex operations here.
 */

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // Implementation for iOS 6

    NSNumber *latitude = [NSNumber numberWithDouble:[(CLLocation *)[locations lastObject] coordinate].latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:[(CLLocation *)[locations lastObject] coordinate].longitude];
    NSNumber *altitude = [NSNumber numberWithDouble:[(CLLocation *)[locations lastObject] altitude]];
    NSNumber *speed = [NSNumber numberWithDouble:([(CLLocation *)[locations lastObject] speed]) * 3.6];
    
    CLLocation *newLocation = [locations lastObject];
    self.oldLocation = self.currentLocation;
    self.currentLocation = newLocation;
    
    [self saveDistanceFrom:self.oldLocation to:newLocation];
    [self saveSpeedAt:newLocation];
    [self saveAltitudeAt:newLocation];
    
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if(abs(howRecent) < 1.0) {
        [[CoreDataModel sharedInstance] savePointWithLatitude:latitude longitude:longitude speed:speed altitude:altitude InRoute:self.currentRoute];
        if (self.oldLocation){
            [[NSNotificationCenter defaultCenter] postNotificationName:kRRLocationChanged object:self userInfo:@{kRROldLocationKey: self.oldLocation, kRRNewLocationKey: newLocation}];
        }
    }
}

# pragma mark - Getters / Setters

- (void)setTrackLocationInBackground:(BOOL)trackLocationInBackground{
    _trackLocationInBackground = trackLocationInBackground;
    [[NSUserDefaults standardUserDefaults] setBool:_trackLocationInBackground forKey:kRRTrackLocationInBackgroundKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)trackLocationInBackground{
    _trackLocationInBackground = [[NSUserDefaults standardUserDefaults] boolForKey:kRRTrackLocationInBackgroundKey];
    return _trackLocationInBackground;
}

- (void)setUseMetric:(BOOL)useMetric{
    _useMetric = useMetric;
    [[NSUserDefaults standardUserDefaults] setBool:_useMetric forKey:kRRUseMetricKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)useMetric{
    _useMetric = [[NSUserDefaults standardUserDefaults] boolForKey:kRRUseMetricKey];
    return _useMetric;
}

- (void)saveDistanceFrom:(CLLocation *)oldLocation to:(CLLocation *)newLocation{
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    self.currentRoute.distance = [NSNumber numberWithDouble:[self.currentRoute.distance doubleValue] + distance];
}

- (void)saveSpeedAt:(CLLocation *)location{
    CLLocationSpeed speed = location.speed * 3.6;
    if([self.currentRoute.maxSpeed doubleValue] < speed) {
        self.currentRoute.maxSpeed = [NSNumber numberWithDouble:speed];
    }
}

- (void)saveAltitudeAt:(CLLocation *)location{
    CLLocationDistance altitude = location.altitude;
    if([self.currentRoute.maxAltitude doubleValue] < altitude) {
        self.currentRoute.maxAltitude = [NSNumber numberWithDouble:altitude];
    }
}

@end

//
//  GooglePlacesFetcher.m
//  Route Recorder
//
//  Created by skobbler on 7/15/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "GooglePlacesFetcher.h"
#import "Reachability.h"
#import "CoreDataModel.h"

static NSString* const kGPGoogleAPIKey = @"AIzaSyDGu9vQMUdzxSo8n7e7WhDoJqmVjOT7bGk";
static GooglePlacesFetcher *_sharedInstance;

@implementation GooglePlacesFetcher

+ (GooglePlacesFetcher *)sharedInstance{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (NSArray *)fetchGooglePlaces:(CLLocationCoordinate2D)coordinate currentDist:(int)currentDist{
    if([self isNetworkConnection]){
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&sensor=true&key=%@", coordinate.latitude, coordinate.longitude, [NSString stringWithFormat:@"%i", currentDist], kGPGoogleAPIKey];
        NSURL *googleRequestURL = [NSURL URLWithString:url];

        NSData *data = [NSData dataWithContentsOfURL: googleRequestURL];
        return [self fetchedData:data];
    }
    return nil;
}

- (NSData *)fetchStaticRouteMapForRoute:(Route *)route{
    NSArray *points = [[CoreDataModel sharedInstance] getAllPointsForRoute:route];
    int accuracy = 1;
    int pointNr = 0;
    if ([points count] > 80){
        accuracy = ceil([points count] / 80) + 1;
    }
    if ([self isNetworkConnection]){
        NSMutableString *url = [NSMutableString stringWithString:@"http://maps.google.com/maps/api/staticmap?size=400x400&path=color:0xff0000ff%7Cweight:5%7C"];
        for (CoreDataMapPoint *point in points){
            if (pointNr % accuracy == 0){
                [url appendFormat:@"%f,%f", [point.latitude doubleValue], [point.longitude doubleValue]];
                [url appendString:@"%7C"];
            }
            pointNr++;
        }
        [url deleteCharactersInRange:NSMakeRange([url length] - 3, 3)];
        [url appendString:@"&sensor=false"];
        NSURL *requestUrl = [NSURL URLWithString:url];
        NSData *map = [NSData dataWithContentsOfURL:requestUrl];
        return map;
    }
    
    return nil;
    
}

- (NSArray *)fetchedData:(NSData *)responseData {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSArray *places = [json objectForKey:kGPResults];
    
    return places;
}

- (bool)isNetworkConnection {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        //NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        //NSLog(@"There IS internet connection");
        return YES;
    }
}

@end

 //
//  MapPoint+Create.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "CoreDataMapPoint+Create.h"

@implementation CoreDataMapPoint (Create)

+ (CoreDataMapPoint *)mapPointWithlatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inRoute:(Route *)route inManagedObjectContext:(NSManagedObjectContext *)context{
    CoreDataMapPoint *mapPoint = nil;
    
    mapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataMapPoint" inManagedObjectContext:context];
    mapPoint.latitude = latitude;
    mapPoint.longitude = longitude;
    mapPoint.route = route;
    return mapPoint;
}

@end

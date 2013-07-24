//
//  MapPoint+Create.h
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "CoreDataMapPoint.h"

@interface CoreDataMapPoint (Create)

+ (CoreDataMapPoint *)mapPointWithlatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inRoute:(Route *)route inManagedObjectContext:(NSManagedObjectContext *)context;

@end

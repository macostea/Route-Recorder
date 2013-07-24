//
//  Route+Create.h
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "Route.h"

@interface Route (Create)

+ (Route*)routeWithStartTime:(NSDate*)time InManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end

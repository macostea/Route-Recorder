//
//  Route+Create.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "Route+Create.h"

@implementation Route (Create)

+ (Route*)routeWithStartTime:(NSDate*)time InManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    Route *route = nil;
    
    if (time){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Route"];
        request.predicate = [NSPredicate predicateWithFormat:@"startTime == %@", time];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES ]];
        
        NSError *error;
        NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (error){
            NSLog(@"Error: %@", [error description]);
        } else if (![matches count]){
            route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:managedObjectContext];
            route.startTime = time;
        } else {
            route = [matches lastObject];
        }
        
    }
    return route;
}

@end

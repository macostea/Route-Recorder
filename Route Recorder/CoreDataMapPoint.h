//
//  CoreDataMapPoint.h
//  Route Recorder
//
//  Created by skobbler on 7/23/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route;

@interface CoreDataMapPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) Route *route;

@end

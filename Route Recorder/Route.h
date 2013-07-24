//
//  Route.h
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreDataMapPoint, Photo;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * maxAltitude;
@property (nonatomic, retain) NSNumber * maxSpeed;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * meanSpeed;
@property (nonatomic, retain) NSSet *mapPoints;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)addMapPointsObject:(CoreDataMapPoint *)value;
- (void)removeMapPointsObject:(CoreDataMapPoint *)value;
- (void)addMapPoints:(NSSet *)values;
- (void)removeMapPoints:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end

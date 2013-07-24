//
//  CoreDataModel.h
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route+Create.h"
#import "CoreDataMapPoint+Create.h"
#import "Photo+Create.h"
#import "CoreDataJSONSerializer.h"

@interface CoreDataModel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIManagedDocument *document;

+ (CoreDataModel *)sharedInstance;
- (id)init;

- (Route*)startNewRoute;
- (void)savePointWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude speed:(NSNumber *)speed altitude:(NSNumber *)altitude InRoute:(Route*)route;
- (void)savePhotoWithData:(NSData *)data title:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude InRoute:(Route*)route;
- (NSArray *)getAllPointsForRoute:(Route *)route;
- (NSData *)JSONDataForRoute:(Route *)route includePhotos:(BOOL)withPhotos;
- (void)routeFromJSONData:(NSData *)jsonData;
- (void)removeRoute:(Route *)route;

- (void)logAllEntries;

@end

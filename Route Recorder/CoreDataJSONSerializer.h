//
//  CoreDataJSONSerializer.h
//  Route Recorder
//
//  Created by skobbler on 7/16/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataJSONSerializer : NSObject

+ (CoreDataJSONSerializer *)sharedInstance;

- (NSData *)JSONDataForManagedObject:(NSManagedObject *)managedObject includePhotos:(BOOL)withPhotos;
- (NSArray *)managedObjectsForJSONData:(NSData *)jsonData;

@end

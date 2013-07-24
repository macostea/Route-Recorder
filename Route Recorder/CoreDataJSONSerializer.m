//
//  CoreDataJSONSerializer.m
//  Route Recorder
//
//  Created by skobbler on 7/16/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "CoreDataJSONSerializer.h"
#import "CoreDataModel.h"
#import "NSDate+JSONDataRepresentation.h"
#import "NSDataAdditions.h"
#import "NSData+GZIP.h"
#import "Route.h"

static NSString* const kJSManagedObjectName = @"ManagedObjectName";
static CoreDataJSONSerializer *_sharedInstance;

@implementation CoreDataJSONSerializer

+ (CoreDataJSONSerializer *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSData *)JSONDataForManagedObject:(NSManagedObject *)managedObject includePhotos:(BOOL)withPhotos{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self dataStructureFromManagedObject:managedObject includePhotos:withPhotos] options:0 error:&error];
    NSData *gzippedData = [jsonData gzippedData];
    if (error){
        NSLog(@"Error creating JSON data: %@", [error description]);
        return nil;
    }
    
    NSLog(@"JSON data size: %u kB", [jsonData length]/1024);
    NSLog(@"JSON data compressed size: %u kB", [gzippedData length]/1024);
    
    return gzippedData;
}

- (NSArray *)managedObjectsForJSONData:(NSData *)jsonData{
    NSData *unzippedData = [jsonData gunzippedData];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:unzippedData options:0 error:nil];
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    [objectArray addObject:[self managedObjectFromStructure:json]];
    return objectArray;
}

- (NSManagedObject *)managedObjectFromStructure:(NSDictionary *)dictionary {
    NSString *objectName = [dictionary objectForKey:kJSManagedObjectName];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:[[CoreDataModel sharedInstance] managedObjectContext]];
    NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
      
    for (NSString *attributeName in [mutableDictionary allKeys]){
        if ([attributeName isEqualToString:@"startTime"] || [attributeName isEqualToString:@"endTime"] || [attributeName isEqualToString:@"time"]){
            NSDate *date = [NSDate dateFromJSONRepresentation:[mutableDictionary objectForKey:attributeName]];
            [mutableDictionary setObject:date forKey:attributeName];
        } else if ([attributeName isEqualToString:@"data"]){
            NSString *dataString = [mutableDictionary objectForKey:attributeName];
            NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSData *decodedData = [data base64Decoded];
            [mutableDictionary setObject:decodedData forKey:attributeName];
        }
    }
    
    [mutableDictionary removeObjectForKey:kJSManagedObjectName];
      
    for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
        [mutableDictionary removeObjectForKey:relationshipName];
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if (![description isToMany]) {
            NSDictionary *childDictionary = [dictionary objectForKey:relationshipName];
            if (childDictionary){
                NSManagedObject *childObject = [self managedObjectFromStructure:childDictionary];
                [managedObject setValue:childObject forKey:relationshipName];
            } else {
                
            }
            continue;
        }
        NSMutableSet *relationshipSet = [managedObject mutableSetValueForKey:relationshipName];
        NSArray *relationshipArray = [dictionary objectForKey:relationshipName];
        for (NSDictionary *childDictionary in relationshipArray) {
            NSManagedObject *childObject = [self managedObjectFromStructure:childDictionary];
            [relationshipSet addObject:childObject];
        }
    }
    
    [managedObject setValuesForKeysWithDictionary:mutableDictionary];
    return managedObject;
}

- (NSDictionary *)dataStructureFromManagedObject:(NSManagedObject *)managedObject includePhotos:(BOOL)withPhotos{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    
    NSMutableDictionary *valuesDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *dictionary = [managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]];
    
    for (NSString *attributeName in attributesByName){
        if ([[dictionary valueForKey:attributeName] isKindOfClass:[NSDate class]]){
            NSDate *dateObject = [dictionary valueForKey:attributeName];
            [valuesDictionary setObject:[dateObject JSONRepresentation] forKey:attributeName];
            
        } else if ([[dictionary valueForKey:attributeName] isKindOfClass:[NSData class]]){
            NSData *dataObject = [dictionary valueForKey:attributeName];
            NSString *stringObject = [dataObject base64Encoded];
            if (stringObject){
                [valuesDictionary setObject:stringObject forKey:attributeName];
            } else {
                [valuesDictionary setObject:[NSNull null] forKey:attributeName];
            }
        } else {
            [valuesDictionary setObject:[dictionary valueForKey:attributeName] forKey:attributeName];
        }
    }
    
    [valuesDictionary setObject:[[managedObject entity] name] forKey:kJSManagedObjectName];
    
    for (NSString *relationshipName in [relationshipsByName allKeys]){
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if (!withPhotos){
            if ([relationshipName isEqualToString:@"photos"]){
                continue;
            }
        }
        if (![description isToMany]){
            NSManagedObject *relationshipObject = [managedObject valueForKey:relationshipName];
            if (![relationshipObject isKindOfClass:[Route class]]){
                [valuesDictionary setObject:[self dataStructureFromManagedObject:relationshipObject includePhotos:withPhotos] forKey:relationshipName];
            }
            continue;
        }
        
        NSSet *relationshipObjects = [managedObject valueForKey:relationshipName];
        NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
        
        for (NSManagedObject *relationshipObject in relationshipObjects){
            [relationshipArray addObject:[self dataStructureFromManagedObject:relationshipObject includePhotos:withPhotos]];
        }
        [valuesDictionary setObject:relationshipArray forKey:relationshipName];
    }
    return valuesDictionary;
}

@end

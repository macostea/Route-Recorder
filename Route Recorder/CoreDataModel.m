//
//  CoreDataModel.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "CoreDataModel.h"

@implementation CoreDataModel

static CoreDataModel *_sharedInstance = nil;

+ (CoreDataModel *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"RouteRecorder"];
        
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        // Set our document up for automatic migrations
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        self.document.persistentStoreOptions = options;
    
        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectsDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.document.managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.document.managedObjectContext];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]){
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                if (success){
                    self.managedObjectContext = self.document.managedObjectContext;
                    NSLog(@"Document opened");
                }
            }];
        } else if (self.document.documentState == UIDocumentStateClosed){
            [self.document openWithCompletionHandler:^(BOOL success){
                if (success){
                    self.managedObjectContext = self.document.managedObjectContext;
                    NSLog(@"Document opened");
                }
            }];
        } else {
            self.managedObjectContext = self.document.managedObjectContext;
            NSLog(@"Document opened");
        }
    }
    return self;
}

- (void)objectsDidChange:(NSNotification *)notification
{
}

- (void)contextDidSave:(NSNotification *)notification
{
}

- (Route *)startNewRoute{
    Route *route = [Route routeWithStartTime:[NSDate date] InManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext insertObject:route];
    [self.document updateChangeCount:UIDocumentChangeDone];
    return route;
}

- (void)savePointWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude speed:(NSNumber *)speed altitude:(NSNumber *)altitude InRoute:(Route *)route{
    CoreDataMapPoint *mapPoint = [CoreDataMapPoint mapPointWithlatitude:latitude longitude:longitude inRoute:route inManagedObjectContext:self.managedObjectContext];
    mapPoint.time = [NSDate date];
    mapPoint.speed = speed;
    mapPoint.altitude = altitude;
    [self.managedObjectContext insertObject:mapPoint];
    [self.document updateChangeCount:UIDocumentChangeDone];
}

- (void)savePhotoWithData:(NSData *)data title:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude InRoute:(Route *)route{
    Photo *mapPhoto = [Photo photoWithData:data title:title latitude:latitude longitude:longitude inRoute:route inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext insertObject:mapPhoto];
    [self.document updateChangeCount:UIDocumentChangeDone];
}

- (NSArray *)getAllPointsForRoute:(Route *)route {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoreDataMapPoint"];
    request.predicate = [NSPredicate predicateWithFormat:@"route == %@", route];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
    
    NSError *error;
    NSArray *points = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unable to get points for current route: %@", [error description]);
    }
    return points;
}

- (NSData *)JSONDataForRoute:(Route *)route includePhotos:(BOOL)withPhotos{
    return [[CoreDataJSONSerializer sharedInstance] JSONDataForManagedObject:route includePhotos:withPhotos];
}

- (void)routeFromJSONData:(NSData *)jsonData {
    NSArray *array = [[CoreDataJSONSerializer sharedInstance] managedObjectsForJSONData:jsonData];
    for (NSManagedObject *managedObject in array) {
        [self.managedObjectContext insertObject:managedObject];
    }
}

- (void)removeRoute:(Route *)route{
    for (CoreDataMapPoint *mapPoint in route.mapPoints){
        [self.managedObjectContext deleteObject:mapPoint];
    }
    for (Photo *photo in route.photos){
        [self.managedObjectContext deleteObject:photo];
    }
    [self.managedObjectContext deleteObject:route];
}

- (void)logAllEntries{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CoreDataMapPoint"];
    NSError *error;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error){
        NSLog(@"Error: %@", [error description]);
    } else {
        for (CoreDataMapPoint *match in matches){
            NSLog(@"Added point latitute: %@, longitude: %@, speed: %@, altitude: %@", match.latitude, match.longitude, match.speed, match.altitude);
        }
    }
}

@end

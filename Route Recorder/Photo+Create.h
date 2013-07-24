//
//  Photo+Create.h
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

+ (Photo *)photoWithData:(NSData *)data title:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inRoute:(Route *)route inManagedObjectContext:(NSManagedObjectContext *)context;

@end

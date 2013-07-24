//
//  Photo+Create.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "Photo+Create.h"

@implementation Photo (Create)

+ (Photo *)photoWithData:(NSData *)data title:(NSString *)title latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude inRoute:(Route *)route inManagedObjectContext:(NSManagedObjectContext *)context{

    Photo *photo = nil;
    
    if (data){
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.data = data;
        photo.title = title;
        photo.latitude = [latitude copy];
        photo.longitude = [longitude copy];
        photo.route = route;
    }
    return photo;
}

@end

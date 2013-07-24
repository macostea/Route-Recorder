//
//  MapPoint.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

-(id)initWithName:(NSString *)name adress:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate{
    if((self = [super init])) {
        self.name = name;
        self.address = address;
        self.coordinate = coordinate;
    }
    return self;
}

-(NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

-(NSString *)subtitle {
    return _address;
}

@end

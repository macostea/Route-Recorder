//
//  MapPoint.h
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(id)initWithName:(NSString*)name adress:(NSString*)adress coordinate:(CLLocationCoordinate2D)coordinate;

@end

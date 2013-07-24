//
//  AnnotationWithImage.h
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AnnotationWithImage : MKAnnotationView <MKAnnotation>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

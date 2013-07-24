//
//  AnnotationWithImage.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "AnnotationWithImage.h"

@implementation AnnotationWithImage
@synthesize image = _image;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate{
    self = [super init];
    if (self){
        self.coordinate = coordinate;
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
}

@end

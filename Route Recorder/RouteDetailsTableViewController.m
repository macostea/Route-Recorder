//
//  RouteDetailsTableViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "RouteDetailsTableViewController.h"
#import "CoreDataMapPoint.h"
#import "AnnotationWithImage.h"
#import "Photo.h"
#import "UIImage+Resize.h"

static NSString* const kMVImageAnnotationIdentifier = @"mapImageAnnotation";

@interface RouteDetailsTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation RouteDetailsTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [self setTimes];
    int index = 0;
    CLLocationCoordinate2D routePoints[[self.routePoints count]];
    NSArray *sortedPoints = [self.routePoints sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]]];
    for (CoreDataMapPoint *mapPoint in sortedPoints){
        routePoints[index] = CLLocationCoordinate2DMake([mapPoint.latitude doubleValue], [mapPoint.longitude doubleValue]);
        index++;
    }
    
    MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:routePoints count:[self.routePoints count]];
    
    [self.mapView addOverlay:routeLine];
    [self addAnnotationsFromCurrentRoute];
    
    [self centerMap];

}

#pragma mark - Map View Delegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithPolyline:overlay];
    overlayView.fillColor = [UIColor redColor];
    overlayView.strokeColor = [UIColor redColor];
    overlayView.lineWidth = 5;
    
    return overlayView;
    
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *pinAnnotationView = nil;
    if ([annotation isKindOfClass:[AnnotationWithImage class]]){
        // Images on route
        pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kMVImageAnnotationIdentifier];
        if (pinAnnotationView){
            [pinAnnotationView prepareForReuse];
        } else {
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMVImageAnnotationIdentifier];
        }
        [self preparePinAnnotationView:pinAnnotationView];
    }
    return pinAnnotationView;
}

#pragma mark - Other Methods

- (void)setTimes{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.locale = [NSLocale currentLocale];
    
    self.startTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:self.startTime];
    self.endTimeCell.detailTextLabel.text = [dateFormatter stringFromDate:self.endTime];
}

- (void)centerMap {
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(CoreDataMapPoint *mapPoint in self.routePoints)
	{
        CLLocationDegrees pointLat = [mapPoint.latitude doubleValue];
        CLLocationDegrees pointLon = [mapPoint.longitude doubleValue];
		if(pointLat > maxLat)
			maxLat = pointLat;
		if(pointLat < minLat)
			minLat = pointLat;
		if(pointLon > maxLon)
			maxLon = pointLon;
		if(pointLon < minLon)
			minLon = pointLon;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[self.mapView setRegion:region animated:YES];
}

- (void)addAnnotationsFromCurrentRoute {
    for (Photo* photo in self.routePhotos) {
        UIImage *image = [UIImage imageWithData:photo.data];
        AnnotationWithImage *annotation = [[AnnotationWithImage alloc]initWithCoordinate:CLLocationCoordinate2DMake([photo.latitude doubleValue], [photo.longitude doubleValue])];
        
        annotation.image = image;
        annotation.title = photo.title;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)preparePinAnnotationView:(MKPinAnnotationView *)pinAnnotationView{
    if ([pinAnnotationView.reuseIdentifier isEqualToString:kMVImageAnnotationIdentifier]){
        UIImage *image = [(AnnotationWithImage*)pinAnnotationView.annotation image];
        pinAnnotationView.image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
    }
}

@end

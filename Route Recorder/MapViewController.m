//
//  MapViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "MapViewController.h"
#import "AnnotationWithImage.h"
#import "UIImage+Resize.h"
#import "FullSizeImageViewController.h"
#import "Reachability.h"
#import "CoreDataModel.h"
#import "GooglePlacesFetcher.h"
#import "MainViewController.h"

static NSString* const kMVImageAnnotationIdentifier = @"mapImageAnnotation";
static NSString* const kMVPOIAnnotationIdentifier = @"mapPOIAnnotation";

static CGFloat const kMVPhotoWidth = 640;
static CGFloat const kMVPhotoHeight = 480;

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBarButtonItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *routeDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) OverlayViewController *overlayViewController;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *routeLineView;
@end

@implementation MapViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:kRRLocationChanged object:nil];
    if (![RouteRecorder sharedInstance].currentRoute){
        self.cameraBarButtonItem.enabled = NO;
        [self.routeDetailsView removeFromSuperview];
    }
    self.routeDetailsView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.speedLabel.text = nil;
    self.startTimeLabel.text = nil;
    self.distanceLabel.text = nil;
    
    self.overlayViewController = [[OverlayViewController alloc] init];
    self.overlayViewController.delegate = self;
   
    [self drawCurrentRoute];
    [self addAnnotationsFromCurrentRoute];
}

- (void)viewDidUnload {
    [self setCameraBarButtonItem:nil];
    [self setSpeedLabel:nil];
    [self setStartTimeLabel:nil];
    [self setDistanceLabel:nil];
    [self setRouteDetailsView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            self.overlayViewController.imagePickerSourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.overlayViewController.imagePickerController animated:YES completion:nil];
            break;
            
        case 1:
            self.overlayViewController.imagePickerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.overlayViewController.imagePickerController animated:YES completion:nil];
            break;
    }
}

#pragma mark - OverlayViewControllerDelegate

- (void)didTakePicture:(UIImage *)image{
    [self.overlayViewController.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    AnnotationWithImage *annotation = [[AnnotationWithImage alloc] initWithCoordinate:self.mapView.userLocation.coordinate];
    
    annotation.image = image;
    annotation.title = @"Photo";
    [[RouteRecorder sharedInstance] addPhoto:[UIImage imageWithImage:image scaledToSize:CGSizeMake(kMVPhotoWidth, kMVPhotoHeight)] title:annotation.title latitude:[NSNumber numberWithDouble:self.mapView.userLocation.coordinate.latitude] longitude:[NSNumber numberWithDouble:self.mapView.userLocation.coordinate.longitude] inRoute:[RouteRecorder sharedInstance].currentRoute];
    [self.mapView addAnnotation:annotation];
}

#pragma mark - MKMapViewDelegate

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
        
    } else if ([annotation isKindOfClass:[MapPoint class]]) {
        // POIs
        pinAnnotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:kMVPOIAnnotationIdentifier];
        if (pinAnnotationView) {
            [pinAnnotationView prepareForReuse];
        } else {
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMVPOIAnnotationIdentifier];
        }
        [self preparePinAnnotationView:pinAnnotationView];
    }
    return pinAnnotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));

    currentDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{       
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *data = [[GooglePlacesFetcher sharedInstance] fetchGooglePlaces:self.mapView.userLocation.coordinate currentDist:currentDist];
        [self performSelectorOnMainThread:@selector(plotPositions:) withObject:data waitUntilDone:YES];
    });
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if(overlay == self.routeLine) {
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 5;
        return self.routeLineView;
    }
    return nil;
}

#pragma mark - Map Overlay 

- (void)drawCurrentRoute {
    if ([RouteRecorder sharedInstance].currentRoute){
        NSArray *points = [[CoreDataModel sharedInstance] getAllPointsForRoute:[RouteRecorder sharedInstance].currentRoute];
        
        CLLocationCoordinate2D coordinateArray[points.count];
        NSLog(@"Point count: %d", points.count);
        for (int index = 0; index < points.count; index++) {
            CoreDataMapPoint *point = (CoreDataMapPoint *)points[index];
            NSLog(@"Coords: %@, %@",point.latitude, point.longitude);
            coordinateArray[index] = CLLocationCoordinate2DMake([point.latitude doubleValue], [point.longitude doubleValue]);
        }
        self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:points.count];
        
        [self.mapView addOverlay:self.routeLine];
    }
}

#pragma mark - Other methods

- (void)preparePinAnnotationView:(MKPinAnnotationView *)pinAnnotationView{
    if ([pinAnnotationView.reuseIdentifier isEqualToString:kMVImageAnnotationIdentifier]){
        UIImage *image = [(AnnotationWithImage*)pinAnnotationView.annotation image];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        CGRect newBounds = CGRectMake(0, 0, 32.0, 32.0);
        [imageView setBounds:newBounds];
        
        pinAnnotationView.image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
        pinAnnotationView.leftCalloutAccessoryView = imageView;
        
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotationView.rightCalloutAccessoryView = disclosureButton;
        [disclosureButton addTarget:self action:@selector(showFullSizeImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    pinAnnotationView.canShowCallout = YES;
}

- (void)showFullSizeImage:(id)sender{
    [self performSegueWithIdentifier:@"showFullSizeImage:" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AnnotationWithImage *annotation = self.mapView.selectedAnnotations[0];
    [(FullSizeImageViewController*)segue.destinationViewController setImage:annotation.image];
}

- (void)locationChanged:(NSNotification*)notification{
    CLLocation *oldLocation = [notification.userInfo objectForKey:kRROldLocationKey];
    CLLocation *newLocation = [notification.userInfo objectForKey:kRRNewLocationKey];

    CLLocationCoordinate2D coordinateArray[2];
    coordinateArray[0] = oldLocation.coordinate;
    coordinateArray[1] = newLocation.coordinate;
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [self.mapView addOverlay:self.routeLine];
    
    NSNumber *speed = [NSNumber numberWithDouble:newLocation.speed * 3.6];
    if ([RouteRecorder sharedInstance].useMetric) {
        self.speedLabel.text = [NSString stringWithFormat:@"%0.f km/h", [speed doubleValue]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [[RouteRecorder sharedInstance].currentRoute.distance doubleValue]/1000];
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%0.f mph", [speed doubleValue] / 1.6];
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f miles", [[RouteRecorder sharedInstance].currentRoute.distance doubleValue] / 1600];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.startTimeLabel.text = [dateFormatter stringFromDate:[RouteRecorder sharedInstance].currentRoute.startTime];
}

- (void)plotPositions:(NSArray *)data {
    if (data){
        for(id<MKAnnotation> annotation in self.mapView.annotations) {
            if([annotation isKindOfClass:[MapPoint class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        
        for(int i=0; i<[data count]; i++) {
            NSDictionary *place = [data objectAtIndex:i];
            NSDictionary *geo = [place objectForKey:kGPGeometry];
            NSDictionary *loc = [geo objectForKey:kGPLocation];
            NSString *name = [place objectForKey:kGPName];
            NSString *vicinity = [place objectForKey:kGPVicinity];
            
            CLLocationCoordinate2D placeCoord;
            placeCoord.latitude = [[loc objectForKey:kGPLat] doubleValue];
            placeCoord.longitude = [[loc objectForKey:kGPLng] doubleValue];
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:name adress:vicinity coordinate:placeCoord];
            [self.mapView addAnnotation:placeObject];
        }
    }
}

- (void)addAnnotationsFromCurrentRoute {
    NSSet *photos = [RouteRecorder sharedInstance].currentRoute.photos;
    for (Photo* photo in photos) {
        UIImage *image = [UIImage imageWithData:photo.data];
        AnnotationWithImage *annotation = [[AnnotationWithImage alloc]initWithCoordinate:CLLocationCoordinate2DMake([photo.latitude doubleValue], [photo.longitude doubleValue])];
        
        annotation.image = image;
        annotation.title = photo.title;
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - Actions

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera", @"From Gallery", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)goBack:(id)sender {
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotToCurrentLocation {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

@end;

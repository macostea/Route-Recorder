//
//  RouteStatisticsViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/18/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "RouteStatisticsViewController.h"
#import "Box.h"
#import "TimeBox.h"
#import "LineChartViewController.h"
#import "CoreDataModel.h"
#import "RouteRecorder.h"

#define IPHONEFIVE_PORTRAIT_BOX  (CGSize){148, 190}
#define IPHONEFIVE_LANDSCAPE_BOX (CGSize){210, 120}

#define IPHONEFIVE_PORTRAIT_TIMEBOX  (CGSize){304, 90}
#define IPHONEFIVE_LANDSCAPE_TIMEBOX (CGSize){116, 248}

#define IPHONE_PORTRAIT_BOX (CGSize){148, 190}
#define IPHONE_LANDSCAPE_BOX (CGSize){160, 120}

#define IPHONE_PORTRAIT_TIMEBOX (CGSize){304, 90}
#define IPHONE_LANDSCAPE_TIMEBOX (CGSize){116, 248}

#define IPHONEFIVE_LANDSCAPE_TIMEGRID (CGSize){98, 248}

#define IPHONE_LANDSCAPE_TIMEGRID (CGSize){88, 248}

static NSString* const kRRShowSpeedChartSegueIdentifier = @"showSpeedChart";
static NSString* const kRRShowAltitudeChartSegueIdentifier = @"showAltitudeChart";

@interface RouteStatisticsViewController()

@property (nonatomic) BOOL phone;
@property (nonatomic) BOOL iPhoneFive;
@property (nonatomic, strong) MGBox *grid;
@property (nonatomic, strong) MGBox *timeGrid;
@property (nonatomic, strong) TimeBox *timeBox;

@end

@implementation RouteStatisticsViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.iPhoneFive = screenRect.size.height == 568;
    
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    
    if (!self.grid) {
        self.grid = [MGBox boxWithSize:self.view.bounds.size];
        NSLog(@"Bounds size: %f x %f", self.view.frame.size.width, self.view.frame.size.height);
        self.grid.contentLayoutMode = MGLayoutGridStyle;
        [self.scroller.boxes addObject:self.grid];
        
        NSString *maxSpeedBoxText, *meanSpeedBoxText, *altitudeBoxText, *distanceBoxText;
        NSNumber *distance = [NSNumber numberWithDouble:([self.distance doubleValue] / 1000)];
        if ([RouteRecorder sharedInstance].useMetric){
            maxSpeedBoxText = [NSString stringWithFormat:@"%0.2f Km/h", [self.maxSpeed doubleValue]];
            meanSpeedBoxText = [NSString stringWithFormat:@"%0.2f Km/h", [self.meanSpeed doubleValue]];
            altitudeBoxText = [NSString stringWithFormat:@"%0.f m", [self.maxAltitude doubleValue]];
            distanceBoxText = [NSString stringWithFormat:@"%0.2f Km", [distance doubleValue]];
        } else {
            maxSpeedBoxText = [NSString stringWithFormat:@"%0.2f mph", [self.maxSpeed doubleValue] / 1.6];
            meanSpeedBoxText = [NSString stringWithFormat:@"%0.2f mph", [self.meanSpeed doubleValue] / 1.6];
            altitudeBoxText = [NSString stringWithFormat:@"%0.f feet", [self.maxAltitude doubleValue] / 0.3048];
            distanceBoxText = [NSString stringWithFormat:@"%0.2f miles", [distance doubleValue] / 1.6];
        }
        
        Box *maxSpeedBox = [Box boxWithSize:[self boxSize] Text:maxSpeedBoxText icon:[UIImage imageNamed:@"Speedometer-max-speed.png"] orientation:self.interfaceOrientation];
        maxSpeedBox.onTap = ^{
            [self performSegueWithIdentifier:kRRShowSpeedChartSegueIdentifier sender:nil];
        };
        Box *meanSpeedBox = [Box boxWithSize:[self boxSize] Text:meanSpeedBoxText icon:[UIImage imageNamed:@"Speedometer-mean-speed.png"] orientation:self.interfaceOrientation];
        meanSpeedBox.onTap = ^{
            [self performSegueWithIdentifier:kRRShowSpeedChartSegueIdentifier sender:nil];
        };
        Box *altitudeBox = [Box boxWithSize:[self boxSize] Text:altitudeBoxText icon:[UIImage imageNamed:@"mountainIcon.png"] orientation:self.interfaceOrientation];
        altitudeBox.onTap = ^{
            [self performSegueWithIdentifier:kRRShowAltitudeChartSegueIdentifier sender:nil];
        };
        Box *distanceBox = [Box boxWithSize:[self boxSize] Text:distanceBoxText icon:[UIImage imageNamed:@"Ruler-icon.png"] orientation:self.interfaceOrientation];
        
        int hours = (int)self.time / 3600;
        int minutes = ((int)self.time % 3600) / 60;
        
        self.timeBox = [TimeBox timeBoxWithSize:[self timeBoxSize] hoursText:[NSString stringWithFormat:@"%.2d", hours] minutesText:[NSString stringWithFormat:@"%.2d", minutes] icon:[UIImage imageNamed:@"clockIcon.png"] orientation:self.interfaceOrientation];
        

        [self.grid.boxes addObject:maxSpeedBox];
        [self.grid.boxes addObject:meanSpeedBox];
        [self.grid.boxes addObject:altitudeBox];
        [self.grid.boxes addObject:distanceBox];
        [self.grid.boxes addObject:self.timeBox];
        
        [self layoutGridOrientation:self.interfaceOrientation];

        [self.scroller scrollToView:self.grid withMargin:10];
    }
}

#pragma mark - Rotation and resizing

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutGridOrientation:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient {
    for (MGBox *box in self.grid.boxes) {
        box.layer.shadowOpacity = 1;
    }
}

- (CGSize)boxSize {
    BOOL portrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    return self.iPhoneFive ? portrait ? IPHONEFIVE_PORTRAIT_BOX : IPHONEFIVE_LANDSCAPE_BOX : portrait ? IPHONE_PORTRAIT_BOX : IPHONE_LANDSCAPE_BOX;
}

- (CGSize)timeBoxSize {
    BOOL portrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    return self.iPhoneFive ? portrait ? IPHONEFIVE_PORTRAIT_TIMEBOX : IPHONEFIVE_LANDSCAPE_TIMEBOX : portrait ? IPHONE_PORTRAIT_TIMEBOX : IPHONE_LANDSCAPE_TIMEBOX;
}

- (CGSize)timeGridSize {
    return self.iPhoneFive ? IPHONEFIVE_LANDSCAPE_TIMEGRID : IPHONE_LANDSCAPE_TIMEGRID;
}

- (void)layoutGridOrientation:(UIInterfaceOrientation)orientation{
    BOOL portrait = UIInterfaceOrientationIsPortrait(orientation);
    NSLog(@"Initial grid size: %f x %f", self.grid.size.width, self.grid.size.height);
    if (portrait){
        self.grid.size = self.view.bounds.size;
        NSLog(@"Grid size: %f x %f", self.view.bounds.size.width, self.view.bounds.size.height);
        if (self.timeGrid){
            [self.scroller.boxes removeObject:self.timeGrid];
            [self.scroller.boxes addObject:self.timeBox];
        }
    } else {
        self.grid.size = CGSizeMake(self.view.bounds.size.width - 132, self.view.bounds.size.height);
        self.timeGrid = [MGBox boxWithSize:[self timeGridSize]];
        self.timeGrid.contentLayoutMode = MGLayoutGridStyle;
        [self.scroller.boxes addObject:self.timeGrid];
        [self.grid.boxes removeObject:self.timeBox];
        [self.timeGrid.boxes addObject:self.timeBox];
    }
    
    // apply to each box
    for (Box *box in self.grid.boxes) {
        box.size = [self boxSize];
        box.layer.shadowPath = [UIBezierPath bezierPathWithRect:box.bounds].CGPath;
        box.layer.shadowOpacity = 0;
        [box repositionElementsToOrientation:orientation];
    }
    
    self.timeBox.size = [self timeBoxSize];
    [self.timeBox repositionElementsToOrientation:orientation];
    
    // relayout the sections
    [self.scroller layoutWithSpeed:0.3 completion:nil];
    NSLog(@"After layout grid size: %f x %f", self.grid.size.width, self.grid.size.height);

}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRRShowSpeedChartSegueIdentifier]) {
        NSArray *points = [[CoreDataModel sharedInstance] getAllPointsForRoute:self.selectedRoute];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        NSMutableArray *time = [[NSMutableArray alloc] init];
        for (CoreDataMapPoint *point in points) {
            double speed = [point.speed doubleValue];
            if (![RouteRecorder sharedInstance].useMetric){
                speed = speed / 1.6;
            }
            [data addObject:@(speed)];
            [time addObject:@([point.time timeIntervalSince1970])];
        }
        LineChartViewController *lineChartViewController = segue.destinationViewController;
        lineChartViewController.data = data;
        lineChartViewController.time = time;
        if ([RouteRecorder sharedInstance].useMetric){
            lineChartViewController.meanSpeed = self.selectedRoute.meanSpeed;
        } else {
            lineChartViewController.meanSpeed = [NSNumber numberWithDouble:[self.selectedRoute.meanSpeed doubleValue] / 1.6];
        }
        lineChartViewController.chartTitle = @"Speed";
        lineChartViewController.title = @"Speed Graph";
    } else if ([segue.identifier isEqualToString:kRRShowAltitudeChartSegueIdentifier]) {
        NSArray *points = [[CoreDataModel sharedInstance] getAllPointsForRoute:self.selectedRoute];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        NSMutableArray *time = [[NSMutableArray alloc] init];
        for (CoreDataMapPoint *point in points) {
            double altitude = [point.altitude doubleValue];
            if (![RouteRecorder sharedInstance].useMetric){
                altitude = altitude / 0.3048;
            }
            [data addObject:@(altitude)];
            [time addObject:@([point.time timeIntervalSince1970])];
        }
        LineChartViewController *lineChartViewController = segue.destinationViewController;
        lineChartViewController.data = data;
        lineChartViewController.time = time;
        lineChartViewController.chartTitle = @"Altitude";
        lineChartViewController.title = @"Altitude Chart";
    }
}

@end

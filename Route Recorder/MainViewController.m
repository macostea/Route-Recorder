//
//  MainViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/10/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "RouteRecorder.h"
#import "ArchiveViewController.h"
#import "MapViewController.h"
#import "SettingsViewController.h"

#define kRRPortraitMenuFrame (CGRect){self.view.bounds.size.width/2 - 150, self.view.bounds.size.height/2 - 150, 300, 300}
#define kRRLandscapeMenuFrame (CGRect){self.view.bounds.size.width/2 - 170, self.view.bounds.size.height/2 - 110, 340, 220}

static NSString* const kRRShowArchiveSegueIdentifier = @"showArchive";
static NSString* const kRRMapViewSegueIdentifier = @"showMapView";
static NSString* const kRRShowSettingsSegueIdentifier = @"showSettings";
static NSString* const kRRMapViewButtonTitle = @"Map View";
static NSString* const kRRRouteDetailsButtonTitle = @"Route Details";
static NSString* const kRRStartRecordingAlertTitle = @"Start Recording";
static NSString* const kRREndRecordingAlertTitle = @"End Recording";
static NSString* const kRROKAlertButtonTitle = @"OK";

@interface MainViewController ()
@property (strong, nonatomic) UIView *menu;
@property (strong, nonatomic) MainMenuButton *startRouteButton;
@property (strong, nonatomic) MainMenuButton *endRouteButton;
@property (strong, nonatomic) MainMenuButton *mapViewButton;
@property (strong, nonatomic) MainMenuButton *archiveViewButton;

@end

@implementation MainViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad{
    self.menu = [[UIView alloc] initWithFrame:CGRectZero];
    [UIView animateWithDuration:0.4 animations:^{
        self.menu.frame = kRRPortraitMenuFrame;
    }];
    
    
    [self.view addSubview:self.menu];
    [self.menu.layer setCornerRadius:20.0f];
    self.menu.backgroundColor = [UIColor clearColor];
    self.menu.layer.masksToBounds = YES;
       
    self.startRouteButton = [[MainMenuButton alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    self.startRouteButton.title = @"Start Route";
    self.startRouteButton.icon = [UIImage imageNamed:@"roadIcon.png"];
    self.startRouteButton.delegate = self;
    
    self.endRouteButton = [[MainMenuButton alloc] initWithFrame:CGRectMake(150, 0, 150, 150)];
    self.endRouteButton.title = @"End Route";
    self.endRouteButton.icon = [UIImage imageNamed:@"finishFlag.png"];
    self.endRouteButton.delegate = self;
    
    self.mapViewButton = [[MainMenuButton alloc] initWithFrame:CGRectMake(0, 150, 150, 150)];
    self.mapViewButton.title = @"Map View";
    self.mapViewButton.icon = [UIImage imageNamed:@"map.png"];
    self.mapViewButton.delegate = self;
    
    self.archiveViewButton = [[MainMenuButton alloc] initWithFrame:CGRectMake(150, 150, 150, 150)];
    self.archiveViewButton.title = @"Archive";
    self.archiveViewButton.icon = [UIImage imageNamed:@"archive.png"];
    self.archiveViewButton.delegate = self;
    
    [self.menu addSubview:self.startRouteButton];
    [self.menu addSubview:self.endRouteButton];
    [self.menu addSubview:self.mapViewButton];
    [self.menu addSubview:self.archiveViewButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [UIView animateWithDuration:0.4 animations:^{
        [self rotateMenuToOrientation:self.interfaceOrientation];
    }];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.4 animations:^{
        self.menu.frame = CGRectZero;
    }];
}

#pragma mark - MainMenuButtonDelegate

- (void)mainMenuButtonPressedButton:(MainMenuButton *)button{
    if (button == self.startRouteButton){
        [self startRoute];
    } else if (button == self.endRouteButton){
        [self endRoute];
    } else if (button == self.mapViewButton){
        [self performSegueWithIdentifier:kRRMapViewSegueIdentifier sender:nil];
    } else if (button == self.archiveViewButton){
        [self performSegueWithIdentifier:kRRShowArchiveSegueIdentifier sender:nil];
    }
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self rotateMenuToOrientation:toInterfaceOrientation];
}

- (void)rotateMenuToOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        self.menu.frame = kRRPortraitMenuFrame;
        self.startRouteButton.frame = CGRectMake(0, 0, 150, 150);
        self.endRouteButton.frame = CGRectMake(150, 0, 150, 150);
        self.mapViewButton.frame = CGRectMake(0, 150, 150, 150);
        self.archiveViewButton.frame = CGRectMake(150, 150, 150, 150);
    } else {
        self.menu.frame = kRRLandscapeMenuFrame;
        self.startRouteButton.frame = CGRectMake(0, 0, 170, 110);
        self.endRouteButton.frame = CGRectMake(170, 0, 170, 110);
        self.mapViewButton.frame = CGRectMake(0, 110, 170, 110);
        self.archiveViewButton.frame = CGRectMake(170, 110, 170, 110);
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:kRRMapViewButtonTitle]) {
        [self performSegueWithIdentifier:kRRMapViewSegueIdentifier sender:nil];
    }
    else if([buttonTitle isEqualToString:kRRRouteDetailsButtonTitle]) {
        [self performSegueWithIdentifier:kRRShowArchiveSegueIdentifier sender:nil];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:kRROKAlertButtonTitle otherButtonTitles:nil];
    [alert addButtonWithTitle:buttonTitle];
    [alert show];
}

#pragma mark - Actions

- (void)startRoute {
    RouteRecorder *routeRecorder = [RouteRecorder sharedInstance];
    if (!routeRecorder.currentRoute) {
        [[RouteRecorder sharedInstance] startRecording];
        [self showAlertViewWithTitle:kRRStartRecordingAlertTitle message:@"Your route will be recorded" buttonTitle:kRRMapViewButtonTitle];    }
    else {
        [self showAlertViewWithTitle:kRRStartRecordingAlertTitle message:@"Route is already in progress" buttonTitle:kRRMapViewButtonTitle];
    }
}

- (void)endRoute {
    RouteRecorder *routeRecorder = [RouteRecorder sharedInstance];
    if(routeRecorder.currentRoute) {
        [self showAlertViewWithTitle:kRREndRecordingAlertTitle message:@"Your route has been recorded" buttonTitle:kRRRouteDetailsButtonTitle];
        [[RouteRecorder sharedInstance] endRecording];
    }
    else {
        [self showAlertViewWithTitle:kRREndRecordingAlertTitle message:@"You have not started a route yet" buttonTitle:kRRRouteDetailsButtonTitle];
    }

}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRRShowSettingsSegueIdentifier]) {
        SettingsViewController *settingsViewController = segue.destinationViewController;
        settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
}


@end

//
//  ArchiveViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

#import "ArchiveViewController.h"
#import "Route.h"
#import "CoreDataModel.h"
#import "RouteDetailsTableViewController.h"
#import "RoutePhotosViewController.h"
#import "RouteStatisticsViewController.h"
#import "HexToUIColor.h"
#import "GooglePlacesFetcher.h"

static NSString* const kRCRouteMainCell = @"routeMainCell";
static NSString* const kAVShowDetailsSegueIdentifier = @"showDetails";
static NSString* const kAVShowStatisticsSegueIdentifier = @"showStatistics";
static NSString* const kAVShowPhotosSegueIdentifier = @"showPhotos";
static NSString* const kAVMailSubject = @"Route Recorder";
static NSString* const kAVRouteMimeType = @"application/octet-stream";
static NSString* const kAVFileName = @"route.rr";

static NSString* const kAVLoadingLabelText = @"Please wait";

static NSString* const kAVShareAlertViewTitle = @"Share Route";
static NSString* const kAVShareOnEmailAlertViewTitle = @"Email";

static int const kAVTableViewCellFirstColor = 0x77D7FF;
static int const KAVTableViewCellSecondColor = 0x66C7FA;

@interface ArchiveViewController ()
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic, strong) Route *selectedRoute;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UILabel *loadingLabel;

@property (nonatomic, strong) UIView *shareRouteModalView;
@end

@implementation ArchiveViewController

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.managedObjectContext = [[CoreDataModel sharedInstance] managedObjectContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.managedObjectContext = nil;
    self.fetchedResultsController = nil;
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCellWithSwipe *cell = [self.tableView dequeueReusableCellWithIdentifier:kRCRouteMainCell];
       
    if (!cell){
        cell = [[TableViewCellWithSwipe alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kRCRouteMainCell];
    }
    
    cell.delegate = self;
    
    Route *route = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];

    cell.textLabel.text = [dateFormatter stringFromDate:route.startTime];
    
    if (route == [RouteRecorder sharedInstance].currentRoute){
        cell.detailTextLabel.text = @"Current";
    } else {
        cell.detailTextLabel.text = [dateFormatter stringFromDate:route.endTime];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedRoute = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Route" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Details", @"Statistics", @"Photos", @"Share", nil];
    [actionSheet showInView:self.view];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 0){
        cell.contentView.backgroundColor = UIColorFromRGB(kAVTableViewCellFirstColor);
        cell.backgroundColor = UIColorFromRGB(kAVTableViewCellFirstColor);
    } else {
        cell.contentView.backgroundColor = UIColorFromRGB(KAVTableViewCellSecondColor);
        cell.backgroundColor = UIColorFromRGB(KAVTableViewCellSecondColor);
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

#pragma mark - RMSwipeTableViewCellDelegate

-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if (point.x < 0 && -point.x >= CGRectGetHeight(swipeTableViewCell.frame)) {
        swipeTableViewCell.shouldAnimateCellReset = NO;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, swipeTableViewCell.contentView.frame.size.width, 0);
                         }
                         completion:^(BOOL finished) {
                             [swipeTableViewCell.contentView setHidden:YES];
                             NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
                             self.selectedRoute = [self.fetchedResultsController objectAtIndexPath:indexPath];
                             [self removeRoute];
                         }
         ];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:kAVShowDetailsSegueIdentifier sender:nil];
            break;
            
        case 1:
            [self performSegueWithIdentifier:kAVShowStatisticsSegueIdentifier sender:nil];
            break;
            
        case 2:
            [self performSegueWithIdentifier:kAVShowPhotosSegueIdentifier sender:nil];
            break;
            
        case 3: {
            UIAlertView *shareAlertView = [[UIAlertView alloc] initWithTitle:kAVShareAlertViewTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
            
            [shareAlertView show];

            break;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:kAVShareOnEmailAlertViewTitle]){
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:
                [self shareRouteWithPhotos:YES];
                break;
                
            case 2:
                [self shareRouteWithPhotos:NO];
                break;
        }
    } else if ([alertView.title isEqualToString:kAVShareAlertViewTitle]){
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:
                [self shareRouteOnSocialNetwork:SLServiceTypeFacebook];
                break;
                
            case 2:
                [self shareRouteOnSocialNetwork:SLServiceTypeTwitter];
                break;
                
            case 3: {
                UIAlertView *aletView = [[UIAlertView alloc] initWithTitle:kAVShareOnEmailAlertViewTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Include Photos", @"No Photos", nil];
                [aletView show];
                break;
            }
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSLog(@"Called back");
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self hideLoadingView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:kAVShowDetailsSegueIdentifier]){
        [self prepareRouteDetailsView:(RouteDetailsTableViewController *)segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:kAVShowStatisticsSegueIdentifier]){
        [self prepareRouteStatisticsView:(RouteStatisticsViewController *)segue.destinationViewController];
    } else if ([segue.identifier isEqualToString:kAVShowPhotosSegueIdentifier]) {
        [self prepareRoutePhotosView:(RoutePhotosViewController *)segue.destinationViewController];
    }
}

#pragma mark - Setters

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Route"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Getters

- (UIView *)loadingView{
    if (!_loadingView){
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    }
    return _loadingView;
}

- (UIActivityIndicatorView *)activityView{
    if (!_activityView){
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityView;
}

- (UILabel *)loadingLabel{
    if (!_loadingLabel){
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    }
    return _loadingLabel;
}

#pragma mark - Other Methods

- (void)prepareRouteDetailsView:(RouteDetailsTableViewController *)routeDetails{
    routeDetails.startTime = self.selectedRoute.startTime;
    routeDetails.endTime = self.selectedRoute.endTime;
    routeDetails.routePoints = self.selectedRoute.mapPoints;
    routeDetails.routePhotos = self.selectedRoute.photos;
}

- (void)prepareRouteStatisticsView:(RouteStatisticsViewController *)routeStatistics{
    routeStatistics.maxSpeed = self.selectedRoute.maxSpeed;
    routeStatistics.meanSpeed = self.selectedRoute.meanSpeed;
    routeStatistics.maxAltitude = self.selectedRoute.maxAltitude;
    routeStatistics.distance = self.selectedRoute.distance;
    routeStatistics.time = [self.selectedRoute.endTime timeIntervalSinceDate:self.selectedRoute.startTime];
    routeStatistics.selectedRoute = self.selectedRoute;
}

- (void)prepareRoutePhotosView:(RoutePhotosViewController *)routePhotos {
    routePhotos.photos = self.selectedRoute.photos;
}

- (void)shareRouteWithPhotos:(BOOL)sharePhotos{
    [self showLoadingView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *jsonData = [[CoreDataModel sharedInstance] JSONDataForRoute:self.selectedRoute includePhotos:sharePhotos];
        [self performSelectorOnMainThread:@selector(presentMailViewControllerWithAttachment:) withObject:jsonData waitUntilDone:NO];
    });

}

- (void)removeRoute{
    [[CoreDataModel sharedInstance] removeRoute:self.selectedRoute];
}

- (void)presentMailViewControllerWithAttachment:(NSData *)jsonData{
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setSubject:kAVMailSubject];
    
    [mailCompose addAttachmentData:jsonData mimeType:kAVRouteMimeType fileName:kAVFileName];
    [self presentViewController:mailCompose animated:YES completion:nil];
}

- (void)showLoadingView{
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.loadingView.clipsToBounds = YES;
    self.loadingView.layer.cornerRadius = 10.0;
    
    self.activityView.frame = CGRectMake(65, 40, self.activityView.bounds.size.width, self.activityView.bounds.size.height);
    
    [self.loadingView addSubview:self.activityView];
    
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.adjustsFontSizeToFitWidth = YES;
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.text = kAVLoadingLabelText;
    [self.loadingView addSubview:self.loadingLabel];
    
    [self.view addSubview:self.loadingView];
    [self.activityView startAnimating];
}

- (void)hideLoadingView{
    [self.activityView stopAnimating];
    [self.loadingView removeFromSuperview];
}

- (void)shareRouteOnSocialNetwork:(NSString *)serviceType{
    [self showLoadingView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [[GooglePlacesFetcher sharedInstance] fetchStaticRouteMapForRoute:self.selectedRoute];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingView];
            [self showSocialDialogServiceType:serviceType data:imageData];
        });
    });
    
}

- (void)showSocialDialogServiceType:(NSString *)serviceType data:(NSData *)imageData{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];

    UIImage *image = [UIImage imageWithData:imageData];
    [composeViewController addImage:image];
    [composeViewController setInitialText:@"Check out my awesome route!"];
    
    [self presentViewController:composeViewController animated:YES completion:nil];

}

@end

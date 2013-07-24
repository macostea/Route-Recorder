//
//  ArchiveViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import "RouteRecorder.h"
#import "TableViewCellWithSwipe.h"

@interface ArchiveViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, RMSwipeTableViewCellDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;

- (void)performFetch;


@end

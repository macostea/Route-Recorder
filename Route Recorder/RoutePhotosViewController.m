//
//  RoutePhotosViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/12/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "RoutePhotosViewController.h"
#import "UICollectionViewPhotoCell.h"
#import "Photo.h"
#import "FullSizeImageViewController.h"

static NSString* const kPVShowFullSizePhotoSegueIdentifier = @"showFullSizePhoto";

@interface RoutePhotosViewController ()

@end

static NSString* const kPhotoCellID = @"photoCell";

@implementation RoutePhotosViewController

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewPhotoCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellID forIndexPath:indexPath];
    
    NSArray *photosArray = [self.photos allObjects];
    Photo *photo = (Photo *)[photosArray objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:photo.data];
    photoCell.imageView.image = image;
    return photoCell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:kPVShowFullSizePhotoSegueIdentifier]){
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        NSArray *photosArray = [self.photos allObjects];
        Photo *photo = (Photo *)[photosArray objectAtIndex:selectedIndexPath.row];
        UIImage *image = [UIImage imageWithData:photo.data];
        FullSizeImageViewController *imageViewController = (FullSizeImageViewController *)segue.destinationViewController;
        imageViewController.image = image;
    }
}
@end

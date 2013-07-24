//
//  FullSizeImageViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "FullSizeImageViewController.h"

@interface FullSizeImageViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FullSizeImageViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    [self resetImage];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    CGFloat scaleWidth = self.scrollView.frame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = self.scrollView.frame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.zoomScale = minScale;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resetImage];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

#pragma mark - Getters

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

#pragma mark - Other Methods

- (void)resetImage{
    self.scrollView.contentSize = CGSizeZero;
    self.imageView.image = nil;
    
    if (self.image){
        self.scrollView.contentSize = self.image.size;
        self.imageView.image = self.image;
        self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
}

@end

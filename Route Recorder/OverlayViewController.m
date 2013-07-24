//
//  OverlayViewController.m
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController ()
@end

@implementation OverlayViewController

#pragma mark - View Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        [self.imagePickerController setDelegate:self];
    }
    return self;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    [self.delegate didTakePicture:image];
}

#pragma mark - Setters

- (void)setImagePickerSourceType:(UIImagePickerControllerSourceType)imagePickerSourceType{
    _imagePickerSourceType = imagePickerSourceType;
    [self.imagePickerController setSourceType:imagePickerSourceType];
}

@end

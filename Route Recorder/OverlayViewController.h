//
//  OverlayViewController.h
//  Route Recorder
//
//  Created by skobbler on 7/9/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OverlayViewControllerDelegate

-(void)didTakePicture:(UIImage *)image;

@end

@interface OverlayViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id <OverlayViewControllerDelegate> delegate;
@property (nonatomic) UIImagePickerControllerSourceType imagePickerSourceType;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@end

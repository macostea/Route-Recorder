//
//  Box.h
//  Route Recorder
//
//  Created by skobbler on 7/18/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "MGBox.h"

@interface Box : MGBox

@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) UIImage *icon;

+ (Box *)boxWithSize:(CGSize)size Text:(NSString *)text icon:(UIImage *)icon orientation:(UIInterfaceOrientation)orientation;

- (void)setBackground;
- (void)repositionElementsToOrientation:(UIInterfaceOrientation)orientation;

@end

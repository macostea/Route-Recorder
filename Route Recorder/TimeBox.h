//
//  TimeBox.h
//  Route Recorder
//
//  Created by skobbler on 7/19/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "MGBox.h"

@interface TimeBox : MGBox

@property (nonatomic, strong) NSString *hoursText;
@property (nonatomic, strong) NSString *minutesText;
@property (nonatomic, strong) UIImage *icon;

+ (TimeBox *)timeBoxWithSize:(CGSize)size hoursText:(NSString *)hours minutesText:(NSString *)minutes icon:(UIImage *)icon orientation:(UIInterfaceOrientation)orientation;
- (void)setBackground;
- (void)repositionElementsToOrientation:(UIInterfaceOrientation)orientation;
@end

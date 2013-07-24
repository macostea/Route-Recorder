//
//  TimeBox.m
//  Route Recorder
//
//  Created by skobbler on 7/19/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "TimeBox.h"
#import "HexToUIColor.h"

#define kTBLandscapeHourLabelFrame (CGRect){0, 100, 120, 50}
#define kTBLandscapeMinuteLabelFrame (CGRect){0, 160, 120, 50}
#define kTBLandscapeSeparatorLabelFrame (CGRect){0, 115, 120, 50}

static NSString* const kTBSeparatorText = @"..";
static int const kTBGradientFirstColor = 0x2153EA;
static int const kTBGradientSecondColor = 0x26E8FF;

@interface TimeBox ()

@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *landscapeHourLabel;
@property (nonatomic, strong) UILabel *landscapeSeparator;
@property (nonatomic, strong) UILabel *landscapeMinuteLabel;
@end

@implementation TimeBox

+ (TimeBox *)timeBoxWithSize:(CGSize)size hoursText:(NSString *)hours minutesText:(NSString *)minutes icon:(UIImage *)icon orientation:(UIInterfaceOrientation)orientation{
    TimeBox *box = [TimeBox boxWithSize:size];
    
    // label
    box.label = [TimeBox labelWithFrame:CGRectMake(120, (size.height/2) - 30, 130, 50) text:[NSString stringWithFormat:@"%@:%@", hours, minutes] backgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor]];
    box.landscapeHourLabel = [TimeBox labelWithFrame:kTBLandscapeHourLabelFrame text:hours backgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor]];
    box.landscapeMinuteLabel = [TimeBox labelWithFrame:kTBLandscapeMinuteLabelFrame text:minutes backgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor]];
    box.landscapeSeparator = [TimeBox labelWithFrame:kTBLandscapeSeparatorLabelFrame text:kTBSeparatorText backgroundColor:[UIColor clearColor] textColor:[UIColor whiteColor]];
          
    [box addSubview:box.label];
    
    box.iconView = [[UIImageView alloc] initWithImage:icon];
    box.iconView.frame = CGRectMake(15, 15, 60, 60);
    
    [box addSubview:box.iconView];
    
    return box;
}

- (void)setup {
    // positioning
    self.topMargin = 8;
    self.leftMargin = 8;
    
    // background
    [self setBackground];
    
    // shadow
    self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 1;
    
}

- (void)setBackground{
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.bounds;
    self.gradient.colors = @[(id)UIColorFromRGB(kTBGradientFirstColor).CGColor, (id)UIColorFromRGB(kTBGradientSecondColor).CGColor];
    [self.layer insertSublayer:self.gradient atIndex:0];
}

- (void)repositionElementsToOrientation:(UIInterfaceOrientation)orientation{
    self.gradient.frame = self.bounds;
    if (UIInterfaceOrientationIsPortrait(orientation)){
        self.iconView.frame = CGRectMake(15, 15, 60, 60);
        [self.landscapeHourLabel removeFromSuperview];
        [self.landscapeMinuteLabel removeFromSuperview];
        [self.landscapeSeparator removeFromSuperview];
        self.label.frame = CGRectMake(120, (self.size.height/2) - 30, 130, 50);
        [self addSubview:self.label];
    } else {
        self.iconView.frame = CGRectMake(self.size.width / 2 - 35, 15, 70, 70);
        [self.label removeFromSuperview];

        [self addSubview:self.landscapeHourLabel];
        [self addSubview:self.landscapeSeparator];
        [self addSubview:self.landscapeMinuteLabel];
    }
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.backgroundColor = backgroundColor;
    label.textColor = textColor;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:50];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
}


@end

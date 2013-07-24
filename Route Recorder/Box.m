//
//  Box.m
//  Route Recorder
//
//  Created by skobbler on 7/18/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "Box.h"
#import "HexToUIColor.h"

#define kRRIconViewFramePortrait (CGRect){24, 30, 100, 100}
#define kRRIconViewFrameLandscape (CGRect){(self.size.width/2) - 40, 10, 80, 80}

static int const kRRGradientFirstColor = 0xFB2B69;
static int const kRRGradientSecondColor = 0xFF5B37;

@interface Box()

@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation Box

+ (Box *)boxWithSize:(CGSize)size Text:(NSString *)text icon:(UIImage *)icon orientation:(UIInterfaceOrientation)orientation{
    Box *box = [Box boxWithSize:size];
    
    // label
    box.label = [[UILabel alloc] initWithFrame:CGRectMake((size.width/2) - 65, size.height - 32, 130, 22)];
    box.label.text = text;
    box.label.backgroundColor = [UIColor clearColor];
    box.label.textColor = [UIColor whiteColor];
    box.label.adjustsFontSizeToFitWidth = YES;
    box.label.textAlignment = NSTextAlignmentCenter;
    box.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:box.label.font.pointSize];
    
    [box addSubview:box.label];
    
    box.iconView = [[UIImageView alloc] initWithImage:icon];
    box.iconView.frame = kRRIconViewFramePortrait;
    
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
    self.gradient.colors = @[(id)UIColorFromRGB(kRRGradientFirstColor).CGColor, (id)UIColorFromRGB(kRRGradientSecondColor).CGColor];
    [self.layer insertSublayer:self.gradient atIndex:0];
}

- (void)repositionElementsToOrientation:(UIInterfaceOrientation)orientation{
    self.gradient.frame = self.bounds;
    self.label.frame = CGRectMake((self.size.width/2) - 65, self.size.height - 32, 130, 22);
    if (UIInterfaceOrientationIsPortrait(orientation)){
        self.iconView.frame = kRRIconViewFramePortrait;
    } else {
        self.iconView.frame = kRRIconViewFrameLandscape;
    }
}

@end

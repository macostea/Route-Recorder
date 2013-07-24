//
//  MainMenuButton.m
//  Route Recorder
//
//  Created by skobbler on 7/22/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainMenuButton.h"

@interface MainMenuButton()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MainMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.iconView];
        [self addSubview:self.titleLabel];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGFloat inset = floorf(CGRectGetHeight(frame) * 0.1f);
    
    CGFloat labelY = 0, imageY = 0;
    CGFloat labelHeight, imageHeight;
    CGFloat left = 0;
    
    imageY = inset / 2;
    imageHeight = floorf(CGRectGetHeight(frame) * 2/3.f);
    
    self.iconView.frame = CGRectInset(CGRectMake(0, imageY, CGRectGetWidth(frame), imageHeight), inset, inset);
    
    labelY = floorf(CGRectGetHeight(frame) * 2/3.f) - inset / 2;
    labelHeight = floorf(CGRectGetHeight(frame) / 3.f);
    
    self.titleLabel.frame = CGRectMake(left, labelY, CGRectGetWidth(frame), labelHeight);
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setIcon:(UIImage *)icon{
    _icon = icon;
    self.iconView.image = icon;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.6];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    id<MainMenuButtonDelegate> delegate = self.delegate;
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    CGPoint touchPoint = [(UITouch *)[touches anyObject] locationInView:self];

    if ([delegate respondsToSelector:@selector(mainMenuButtonPressedButton:)] && CGRectContainsPoint(self.bounds, touchPoint)){
        [delegate mainMenuButtonPressedButton:self];
    }
    
}

@end

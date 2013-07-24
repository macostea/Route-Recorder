//
//  MainMenuButton.h
//  Route Recorder
//
//  Created by skobbler on 7/22/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuButton;

@protocol MainMenuButtonDelegate <NSObject>
@optional
- (void)mainMenuButtonPressedButton:(MainMenuButton *)button;

@end

@interface MainMenuButton : UIView

@property (weak, nonatomic) id<MainMenuButtonDelegate> delegate;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;

@end

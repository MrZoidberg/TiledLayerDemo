//
//  AppDelegate.h
//  TiledLayerDemo
//
//  Created by Mykhaylo Merkulov on 06.02.13.
//  Copyright (c) 2013 Mikhail Merkulov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LandscapeGridController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LandscapeGridController *viewController;

@end

//
//  LandscapeGridController.h
//  TV-Guide
//
//  Created by Mahmood1 on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"

@class TimeView;

@interface LandscapeGridController : UIViewController <GridViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    //Data:
    NSMutableArray *_channelsList;
    NSMutableDictionary *_programsDict;
    
    //UI controls:
    GridView *_gridView;
    TimeView *_timeView;
    UIView *_currentTimeView;
    
    //Misc
    NSDate *_lastUpdateTime;
    //NSTimer *_updateTimer;
    CGFloat gridScale;
    BOOL isZooming;
}

- (IBAction)timeSelectorTouched:(id)sender;

@property (retain, nonatomic) IBOutlet UITableView *channelsTableView;
@property (retain, nonatomic) IBOutlet UIScrollView *programsScrollView;
@property (retain, nonatomic) IBOutlet UIScrollView *timeScrollView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;

@end

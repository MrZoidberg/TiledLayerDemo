//
//  GridView.h
//  scrolltest
//
//  Created by Zoid on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRID_COLUMN_WIDTH 240
#define GRID_DEFAULT_WIDTH GRID_COLUMN_WIDTH * 24
#define GRID_ROW_HEIGHT 64

@class GridView;

@protocol GridViewDelegate <NSObject>
@required
- (CGFloat)getScaleFactorInGridView:(GridView *)gridView;
- (NSArray *)channelsListInGridView:(GridView *)gridView;
- (NSArray*)programsForChannelAtChannel:(NSNumber *)channel;
- (NSArray*)programsForChannelAtIndex:(int)channelIndex;
@optional
- (void)gridView:(GridView *)gridView didSelectProgram:(NSDictionary *)programData;
@end

@interface GridView : UIView {
    NSObject<GridViewDelegate> *_delegate;
    NSCalendar *_calendar;
}

@property (nonatomic) NSObject<GridViewDelegate> *delegate;

@end



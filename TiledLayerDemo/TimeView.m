//
//  TimeView.m
//  TV-Guide
//
//  Created by Mahmood1 on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeView.h"
#import "GridView.h"

@implementation TimeView

@synthesize scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scale = 1.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rect);
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextFillRect(context, rect);
    
    float hourWidth = GRID_COLUMN_WIDTH*scale;
    
    //Draw timeline
    CGRect frame;
    for(int i=0; i <= 47; i++) {
        int hour = i/2 + 6;
        if (hour >= 24) {
            hour -= 24;
        }
        
        frame.origin.y = 0;
        frame.size.width = hourWidth/2;
        frame.size.height = GRID_TIMEROW_HEIGHT;
        frame.origin.x = i*hourWidth/2;
        
        //draw background
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
        CGContextAddRect(context, frame);
        CGContextStrokePath(context);
        
        //draw time
        frame.origin.y = 1;
        frame.origin.x += 10;
        frame.size.width -= 10;
        frame.size.height -= 7;
        
        int minutes = i%2 == 0 ? 0 :30;
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [components setHour:hour];
        NSString *hourString = [NSString stringWithFormat:@"%d:%02d", [components hour], minutes];
        [hourString drawInRect:frame withFont:[UIFont boldSystemFontOfSize:13]];
    }
}


@end

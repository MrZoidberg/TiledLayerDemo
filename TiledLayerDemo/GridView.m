//
//  GridView.m
//  scrolltest
//
//  Created by Zoid on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GridView.h"
#import "ChannelProgram.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTFont.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CTFramesetter.h>

@implementation GridView

@synthesize delegate = _delegate;

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //CATiledLayer *tempTiledLayer = (CATiledLayer*)self.layer;
        //tempTiledLayer.tileSize = CGSizeMake(256, GRID_ROW_HEIGHT*2);
        _calendar = [NSCalendar currentCalendar];
    }
    return self;
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
    NSLog(@"setNeedsDisplayInRect:%@", NSStringFromCGRect(rect));
    [super setNeedsDisplayInRect:rect];
}

- (void)setNeedsDisplay {
    NSLog(@"setNeedsDisplay");
    [super setNeedsDisplay];
}

#ifdef LANDSCAPE_MODE_ENABLED

- (void)drawEmptyRect:(CGRect)rect inContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextFillRect(context, rect);
}

- (void)drawProgram:(ChannelProgram *)programData inChannel:(int)channelIndex withClipBox:(CGRect)clipBox inContext:(CGContextRef)context withScaleFactor:(CGFloat)scaleFactor
{
    NSDate *startTimeDate = [NSDate dateWithTimeIntervalSince1970:programData.starttime];
    NSDate *endTimeDate = [NSDate dateWithTimeIntervalSince1970:programData.endtime];
    NSDateComponents *todayComponents = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSDateComponents *startComponents = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startTimeDate];
    NSDateComponents *endComponents = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:endTimeDate];
    NSTimeInterval programDuration = [endTimeDate timeIntervalSinceDate:startTimeDate];
    
    //NSLog(@"startComponents: %@", startComponents);
    //NSLog(@"programDuration: %f", programDuration);
    
    if ([todayComponents hour] < 6) {
        [todayComponents setDay:[todayComponents day]-1];
    }
    
    CGRect frame;
    if ([todayComponents day] == [startComponents day]) { //program is today
        frame.origin.x = ([startComponents hour]-6) * GRID_COLUMN_WIDTH + ([startComponents minute]/60.0)*GRID_COLUMN_WIDTH;
    } else { //program is tomorrow
        frame.origin.x = 18* GRID_COLUMN_WIDTH + [startComponents hour] * GRID_COLUMN_WIDTH + ([startComponents minute]/60.0)*GRID_COLUMN_WIDTH;
    }
    frame.origin.y = channelIndex*GRID_ROW_HEIGHT;
    frame.size.height = GRID_ROW_HEIGHT;
    frame.size.width = (programDuration/3600.0)*GRID_COLUMN_WIDTH;
    
    //Draw background
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:30.0/255 green:30.0/255.0 blue:30.0/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, frame);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextAddRect(context, frame);
    CGContextStrokePath(context);
    
    //Draw title
    CGContextSaveGState( context );
    NSString *programNameString = programData.title;
    
	//NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:programName];
    CTFontRef helvetica;
    if (scaleFactor >= 1) {
        helvetica = CTFontCreateWithName(CFSTR("Helvetica"), round(12.0/pow(scaleFactor,1.0/3.0)), NULL);
    } else {
        helvetica = CTFontCreateWithName(CFSTR("Helvetica"), round(12.0), NULL);
    }
    CGFloat lineHeight = CTFontGetDescent(helvetica) + CTFontGetAscent(helvetica) + CTFontGetLeading(helvetica);
    //NSLog(@"line height: %f", lineHeight);
    
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { helvetica, [[UIColor whiteColor] CGColor] };
    
    CFDictionaryRef attributes =
    CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                       (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                       &kCFTypeDictionaryKeyCallBacks,
                       &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)programNameString, attributes);
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
	// left column form
    CGRect textFrame = frame;
    textFrame.origin.x += 3;
    textFrame.origin.y = -lineHeight-3*sqrt(scaleFactor);
    textFrame.size.width -= 5;
    textFrame.size.height = lineHeight + 3;
    /*
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, textFrame);
    
    //CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, textFrame.size, NULL);
    //NSLog(NSStringFromCGSize(textSize));
	// create frame ref
	CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0),
                                                    path, NULL);
    */
	// set the coordinate system
    CGContextTranslateCTM(context, 0, (channelIndex)*GRID_ROW_HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
    
    // Set text position and draw the line into the graphics context
    CGContextSetTextPosition(context, textFrame.origin.x, textFrame.origin.y);
    CTLineDraw(line, context);
    CFRelease(line);
    
    NSString *startTime = [NSString stringWithFormat:@"%d:%02d - %d:%02d", [startComponents hour], [startComponents minute], [endComponents hour], [endComponents minute]];
    attrString = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)startTime, attributes);
    line = CTLineCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    if (scaleFactor >= 1) {
        CGContextTranslateCTM(context, 0, -12.0);
    } else {
        CGContextTranslateCTM(context, 0, -12.0/scaleFactor);
    }
    
    CGContextSetTextPosition(context, textFrame.origin.x, textFrame.origin.y);
    CTLineDraw(line, context);
    CFRelease(line);
    
    
    //start draw description
    NSString *description = programData.introdesc;
    if (scaleFactor >= 1 && description != nil && ((NSNull *)description != [NSNull null]) && [description length] > 0) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:description];
        [string addAttribute:(id)kCTFontAttributeName
                       value:(__bridge id)helvetica
                       range:NSMakeRange(0, [string length])];
        
        // add some color
        [string addAttribute:(id)kCTForegroundColorAttributeName
                       value:(id)[UIColor whiteColor].CGColor
                       range:NSMakeRange(0, [string length])];
        
        // layout master
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge_retained CFAttributedStringRef) string);
        
        // left column form
        textFrame.size.height = GRID_ROW_HEIGHT - 35;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        
        // create frame ref
        CTFrameRef  frameRef = CTFramesetterCreateFrame(framesetter,
                                            CFRangeMake(0, 0),
                                            path, NULL);
        
        CGContextTranslateCTM(context, 0, -35);
        // draw description
        CTFrameDraw(frameRef, context);
        
        CFRelease(frameRef);
        CFRelease(framesetter);
        CGPathRelease(path);
    }
    
	// cleanup
    CFRelease(attributes);
    CFRelease(helvetica);
    CGContextRestoreGState(context);  
}

- (CGAffineTransform)transformForTile:(CGPoint)tile
{
	return CGAffineTransformIdentity;
}

#pragma mark Tiled layer delegate methods

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    //Timer *timer = [[Timer alloc] init];
    //[timer startTimer];

    
	// Fetch clip box in *world* space; context's CTM is preconfigured for world space->tile pixel space transform
	CGRect box = CGContextGetClipBoundingBox(context);
	
	// Calculate tile index
    
	CGSize tileSize = [(CATiledLayer*)layer tileSize];
	CGRect tbox = CGRectApplyAffineTransform(CGRectMake(0, 0, tileSize.width, tileSize.height), 
											 CGAffineTransformInvert(CGContextGetCTM(context)));
	CGFloat x = box.origin.x / tbox.size.width;
	CGFloat y = box.origin.y / tbox.size.height;
    
    NSLog(@"Drawing layer %@", NSStringFromCGPoint(CGPointMake(x, y)));
	
	// Clear background
    [self drawEmptyRect:box inContext:context];
    
    if (_delegate != nil)
    {
        CGFloat scaleFactor = [_delegate getScaleFactorInGridView:self];
        
        //NSLog(@"scale factor: %f",scaleFactor);
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *dayStartComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        if ([dayStartComponents hour] < 6) {
            [dayStartComponents setDay:[dayStartComponents day]-1];
        }
        [dayStartComponents setHour:6];
        [dayStartComponents setMinute:0];
        [dayStartComponents setSecond:0];
        
        NSArray *channelsList = [_delegate channelsListInGridView:self];
        
        //Calc which channels included into this tile
        int minChannel = (int)floor(box.origin.y / (float)GRID_ROW_HEIGHT);
        int maxChannel = (int)floor((box.origin.y + box.size.height) / (float)GRID_ROW_HEIGHT) - 1;
        
        
        if (minChannel <= [channelsList count])
        {
            //CGContextSaveGState(context);
            //CGContextTranslateCTM(context, 0.0, box.size.height);
            //CGContextScaleCTM(context, 1.0, -1.0);
            //CGRect rect = CGContextGetClipBoundingBox(context);
            
            if (maxChannel >= [channelsList count])
                maxChannel = [channelsList count] - 1;
            
            //Calc time included into this tile
            NSTimeInterval tileStartInterval = (box.origin.x / (float)GRID_COLUMN_WIDTH) * 60.0 * 60.0;
            NSTimeInterval tileDuration = (box.size.width / (float)GRID_COLUMN_WIDTH) * 60.0 * 60.0;
            
            NSDate *dayStart = [cal dateFromComponents:dayStartComponents];
            NSTimeInterval tileStart = [dayStart timeIntervalSince1970] + tileStartInterval;
            NSTimeInterval tileEnd = tileStart + tileDuration;
            
            //NSLog(@"min channel: %d, max: %d", minChannel, maxChannel);
            for (int i=minChannel; i <= maxChannel; i++)
            {
                NSDictionary *channelInfoDict = [channelsList objectAtIndex:i];
                NSString *channelID = [channelInfoDict objectForKey:@"id"];
                
                NSArray *progArray = [_delegate programsForChannelAtChannel:[NSNumber numberWithInt:[channelID intValue]]];
                
                if (progArray != nil) {
                    for (ChannelProgram *programData in progArray) {
                        NSTimeInterval programStart = programData.starttime;
                        NSTimeInterval programEnd = programData.endtime;
                        
                        if ((programStart <= tileStart && programEnd >= tileStart) || (tileStart <= programStart && programStart <= tileEnd)) {
                        //if (tileStart <= programStart || programEnd <= tileEnd || (programStart <= tileStart && programEnd >= tileEnd)) {
                            //CGContextSaveGState(context);
                            [self drawProgram:programData inChannel:i withClipBox:box inContext:context withScaleFactor:scaleFactor];
                            //CGContextRestoreGState(context);  
                        }
                    }
                }

            }
        }
    } else {
        NSLog(@"Something wrong!");
    }
	// Render label (Setup)
    
	UIFont* font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:10];
	CGContextSelectFont(context, [[font fontName] cStringUsingEncoding:NSASCIIStringEncoding], [font pointSize], kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1, -1));
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] CGColor]);
	
	// Draw label
	NSString* s = [NSString stringWithFormat:@"(%.0f, %.0f)",x,y];
	CGContextShowTextAtPoint(context,
							 box.origin.x,
							 box.origin.y + [font pointSize],
							 [s cStringUsingEncoding:NSMacOSRomanStringEncoding],
							 [s lengthOfBytesUsingEncoding:NSMacOSRomanStringEncoding]);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5] CGColor]);
    CGContextAddRect(context, box);
    CGContextStrokePath(context);
    
    
    //[timer stopTimer];
    //NSLog(@"Total layer render time was: %lf milliseconds", [timer timeElapsedInMilliseconds]);  
    //[timer release];
}


#pragma mark View overrides

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    
    for (UITouch *touch in touches)
	{
        CGPoint touchPoint = [touch locationInView:self];
        
		if ([touch tapCount] == 1)
		{
            NSLog(@"%f %f", touchPoint.x, touchPoint.y);
            int channelID = touchPoint.y / GRID_ROW_HEIGHT;
            CGFloat timeInSec = touchPoint.x * 60.0 * 60.0 / (CGFloat)GRID_COLUMN_WIDTH;
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDateComponents *todayComponents = [cal components:(NSTimeZoneCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
            if ([todayComponents hour] < 6) {
                //[todayComponents setDay:[todayComponents day]-1];
            }
            [todayComponents setHour:4];
            [todayComponents setMinute:0];
            [todayComponents setSecond:0];
            
            NSDate *todayStart = [cal dateFromComponents:todayComponents]; //time will be in UTC
            NSDate *tappedTime = [todayStart dateByAddingTimeInterval:timeInSec];
            
            NSLog(@"%@", tappedTime);
            
            int tappedTimeStamp = [tappedTime timeIntervalSince1970];
            
            NSArray *progArray = [_delegate programsForChannelAtIndex:channelID];
            for (ChannelProgram *programData in progArray) {
                int startTime = programData.starttime;
                int endTime = programData.endtime;
                
                if (startTime < tappedTimeStamp && tappedTimeStamp < endTime) {
                    
                    NSDateComponents *startComponents = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
                    NSDateComponents *endComponents = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSince1970:endTime]];
                    NSString *durationString = [NSString stringWithFormat:@"%d:%02d - %d:%02d", [startComponents hour], [startComponents minute], [endComponents hour], [endComponents minute]];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TEST" message:[NSString stringWithFormat:@"You have tapped '%@'. %@", programData.title, durationString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                    break;
                    
                }                
            }
		}
    }
    
}

#endif

@end

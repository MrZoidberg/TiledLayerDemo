//
//  ChannelProgram.m
//  TVGuide
//
//  Created by Ramappa on 02/11/08.
//  Copyright 2008 iApps Software Solutions. All rights reserved.
//

#import "ChannelProgram.h"

@implementation ChannelProgram

/*
- (NSString*)getShortStartTime {
    if (startTimeString == nil) {
        NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        startTimeString = [[df stringFromDate:startTimeDate] retain];
    }
    
	return [ChannelProgram parseString:startTimeString AMPM:YES];
}

- (NSString*)getMiniStartTime {
    if (startTimeString == nil) {
        NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
        [df setDateFormat:@"HH:mm"];
        [df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        startTimeString = [[df stringFromDate:startTimeDate] retain];
    }
    
	return [ChannelProgram parseString:startTimeString AMPM:NO];
}

- (NSDate*)getEndTime {
	
    if (self.endTimeDate != nil)
        return self.endTimeDate;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	 
	self.endTimeDate = [[df dateFromString: endTimeString] convertToCurrentTimeZone];
    [df release];
	 
	return self.endTimeDate;
}

- (NSString*)getShortEndTime {
    if (endTimeString == nil) {
        NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        endTimeString = [[df stringFromDate:endTimeDate] retain];
    }
    
	return [ChannelProgram parseString:endTimeString  AMPM:YES];
}

- (NSString*)getShortStartTime1 {
	return [ChannelProgram parseString:startTimeString1 AMPM:NO];
}

- (NSString*)getShortStartTime2 {
	return [ChannelProgram parseString:startTimeString2  AMPM:NO];
}
*/
@end

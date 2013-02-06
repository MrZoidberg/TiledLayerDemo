//
//  ChannelProgram.h
//  TVGuide
//
//  Created by Ramappa on 02/11/08.
//  Copyright 2008 iApps Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelProgram : NSObject 
{
    
}

@property (nonatomic) int starttime;
@property (nonatomic) int endtime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *introdesc;

@end

//
//  LandscapeGridController.m
//  TV-Guide
//
//  Created by Mahmood1 on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LandscapeGridController.h"
#import "TimeView.h"
#import "ChannelProgram.h"
#import <QuartzCore/QuartzCore.h>


@interface LandscapeGridController (PRIVATE)
- (void)selectActiveChannels;
- (void)readProgramsLocaly;
- (void)reloadUI;
- (void)updateCurrentTimeView;
@end

@implementation LandscapeGridController

@synthesize channelsTableView;
@synthesize programsScrollView;
@synthesize timeScrollView;
@synthesize activityIndicator = _activityIndicator;
@synthesize loadingLabel = _loadingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int channelsCount = 10;
    _gridView = [[GridView alloc] initWithFrame:CGRectMake(0, 0, GRID_DEFAULT_WIDTH, GRID_ROW_HEIGHT * channelsCount)];
    _gridView.delegate = self;
    programsScrollView.contentSize = _gridView.frame.size;
    [programsScrollView addSubview:_gridView];
    
    _timeView = [[TimeView alloc] initWithFrame:CGRectMake(0, 0, GRID_DEFAULT_WIDTH, GRID_TIMEROW_HEIGHT)];
    self.timeScrollView.contentSize = _timeView.frame.size;
    [self.timeScrollView addSubview:_timeView];
    
    _currentTimeView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 3, _gridView.frame.size.height)];
    _currentTimeView.backgroundColor = [UIColor colorWithRed:180.0/255.0 green:210.0/255.0 blue:150.0/255.0 alpha:0.7];
    [programsScrollView addSubview:_currentTimeView];
    
    programsScrollView.minimumZoomScale = 0.5;
    programsScrollView.maximumZoomScale = 3;
    gridScale = 1;
    
    self.loadingLabel.text = @"Loading grid...";    
}

- (void)viewDidUnload
{
    [self setChannelsTableView:nil];
    [self setProgramsScrollView:nil];
    [self setTimeScrollView:nil];
    [self setActivityIndicator:nil];
    
    [self setLoadingLabel:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self readProgramsLocaly];
    //_updateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateCurrentTimeViewFromTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	[super viewWillDisappear:animated];
}



#pragma mark
#pragma mark Logic
     
- (void)updateCurrentTimeView
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [cal components:(NSTimeZoneCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    if ([startComponents hour] < 6) {
        [startComponents setDay:[startComponents day]-1];
    }
    [startComponents setHour:6];
    [startComponents setMinute:0];
    [startComponents setSecond:0];
    
    NSDate *invervalStart = [cal dateFromComponents:startComponents];
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:invervalStart];
    int x = (elapsedTime * (CGFloat)GRID_COLUMN_WIDTH * gridScale) / 60 / 60;
    
    CGRect frame = _currentTimeView.frame;
    frame.origin.x = x;
    _currentTimeView.frame = frame;
    
    [_currentTimeView setNeedsDisplay];
    [timeScrollView setNeedsDisplay];
}


- (void)selectActiveChannels
{
	_channelsList = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=1; i<=10; i++) {
        [_channelsList addObject:[NSNumber numberWithInt:i]];
    }
}

- (void)readProgramsLocaly
{
    _programsDict = [[NSMutableDictionary alloc] init];
    
    int programCount = 1;
    for (int channelId=1; channelId<=10; channelId++) {
        NSMutableArray *channelPrograms = [[NSMutableArray alloc] init];
        NSDate *date = [NSDate date];
        NSCalendar *cal = [[NSCalendar alloc] init];
        NSDateComponents *components = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        for (int hour = 0; hour < 24; hour++) {
            components.hour = hour;
            components.minute = rand() % 60;
            
            ChannelProgram *program = [[ChannelProgram alloc] init];
            program.starttime = [[cal dateFromComponents:components] timeIntervalSince1970];
            components.minute = rand() % (60 - components.minute) + components.minute;
            program.endtime = [[cal dateFromComponents:components] timeIntervalSince1970];
            
            program.title = [NSString stringWithFormat:@"Program #%d", programCount];
            programCount++;
            
            program.introdesc = @"test program";
            
            [channelPrograms addObject:program];
        }
        
        [_programsDict setObject:channelPrograms forKey:[NSNumber numberWithInt:channelId]];
    }
    [self performSelectorOnMainThread:@selector(reloadUI) withObject:nil waitUntilDone:NO];
}

- (void)scrollToNow:(BOOL)animated
{
    int x = _currentTimeView.frame.origin.x;
    if (x > 100) {
        x -= 100;
    }
    [programsScrollView scrollRectToVisible:CGRectMake(x, 0, programsScrollView.frame.size.width, programsScrollView.frame.size.height) animated:animated];
}

- (void)scrollTo:(int)hour animated:(BOOL)animated
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [cal components:(NSTimeZoneCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    if ([startComponents hour] < 6) {
        [startComponents setDay:[startComponents day]-1];
    }
    [startComponents setHour:6];
    [startComponents setMinute:0];
    [startComponents setSecond:0];
    
    NSDate *invervalStart = [cal dateFromComponents:startComponents];
    [startComponents setHour:hour];
    NSDate *desiredDate = [cal dateFromComponents:startComponents];
    NSTimeInterval elapsedTime = [desiredDate timeIntervalSinceDate:invervalStart];
    int x = (elapsedTime * (CGFloat)GRID_COLUMN_WIDTH * gridScale) / 60 / 60;
    
    if (x > 100) {
        x -= 100;
    }
    [programsScrollView scrollRectToVisible:CGRectMake(x, 0, programsScrollView.frame.size.width, programsScrollView.frame.size.height) animated:animated];
}

- (void)reloadUI
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(reloadUI) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (_channelsList == nil || [_channelsList count] == 0) {
        [self selectActiveChannels];
    }
    
    CGSize world = CGSizeMake(GRID_DEFAULT_WIDTH,  GRID_ROW_HEIGHT * [_channelsList count]);
    _gridView.frame = CGRectMake(0, 0, world.width * gridScale,world.height * gridScale);
    programsScrollView.contentSize = _gridView.frame.size;
    
//    CGSize vpSize = programsScrollView.frame.size;
	CGFloat zoomOutLevels = 0.6;//MAX(ceil(log2(MAX(world.width* gridScale/vpSize.width, world.height* gridScale/vpSize.height))), 0);
	CGFloat zoomInLevels = 2;
    
	[(CATiledLayer*)_gridView.layer setLevelsOfDetail:zoomOutLevels+zoomInLevels+1];
	[(CATiledLayer*)_gridView.layer setLevelsOfDetailBias:zoomInLevels];
    
	programsScrollView.minimumZoomScale = pow(2, -zoomOutLevels);
	programsScrollView.maximumZoomScale = pow(2, zoomInLevels);
    
    //set current time view frame
    CGRect frame = _currentTimeView.frame;
    frame.size.height = _gridView.frame.size.height * gridScale;
    _currentTimeView.frame = frame;
    
    [channelsTableView reloadData];
    [self updateCurrentTimeView];
    [self scrollToNow:NO];
    [_gridView.layer setNeedsDisplayInRect: _gridView.layer.bounds];
    
    [self.loadingLabel setHidden:YES];
    [self.activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}


- (IBAction)timeSelectorTouched:(id)sender {
}

#pragma mark - GridViewDelegate

- (NSArray *)channelsListInGridView:(GridView *)gridView
{
    if (_channelsList == nil || [_channelsList count] == 0) {
        [self selectActiveChannels];
    }
    return _channelsList;
}

- (NSArray*)programsForChannelAtChannel:(NSNumber *)channel
{
    return (NSArray *)[_programsDict objectForKey:channel];
}

- (NSArray*)programsForChannelAtIndex:(int)channelIndex
{
    if (_channelsList == nil || [_channelsList count] == 0) {
        [self selectActiveChannels];
    }
    NSDictionary *channelInfoDict = [_channelsList objectAtIndex:channelIndex];
    NSNumber *channelId = [NSNumber numberWithInt:[[channelInfoDict objectForKey:@"id"] intValue]];
    return [self programsForChannelAtChannel:channelId];
}

- (void)gridView:(GridView *)gridView didSelectProgram:(NSDictionary *)programData
{
    //Here we get a callback when a program is selected
}

- (CGFloat)getScaleFactorInGridView:(GridView *)gridView
{
    return [programsScrollView zoomScale];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isZooming)
        return;
    
    //syncronize scrolling
    if (scrollView.tag == channelsTableView.tag) {
        programsScrollView.contentOffset = CGPointMake(programsScrollView.contentOffset.x, channelsTableView.contentOffset.y);
    } else if (scrollView.tag == programsScrollView.tag) {
        channelsTableView.contentOffset = CGPointMake(channelsTableView.contentOffset.x, programsScrollView.contentOffset.y);
        timeScrollView.contentOffset  = CGPointMake(programsScrollView.contentOffset.x, timeScrollView.contentOffset.y);
    } else if (scrollView.tag == timeScrollView.tag) {
        programsScrollView.contentOffset = CGPointMake(timeScrollView.contentOffset.x, programsScrollView.contentOffset.y);
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    isZooming = YES;
    _currentTimeView.hidden = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale 
{
    isZooming = NO;
    gridScale = scale;
    _timeView.scale = gridScale;
    
    CGRect frame = _timeView.frame;
    frame.size.width = _gridView.frame.size.width;
    _timeView.frame = frame;
    timeScrollView.contentSize = _timeView.frame.size;
    
    _currentTimeView.hidden = NO;
    frame = _currentTimeView.frame;
    frame.size.height = _gridView.frame.size.height * gridScale;
    _currentTimeView.frame = frame;
    
    channelsTableView.contentOffset = CGPointMake(channelsTableView.contentOffset.x, programsScrollView.contentOffset.y);
    [channelsTableView reloadData];
    [_timeView setNeedsDisplay];
    [timeScrollView setNeedsDisplay];
    [_gridView.layer setNeedsDisplayInRect: _gridView.layer.bounds];
     
    [self updateCurrentTimeView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _gridView;
}

#pragma mark UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_channelsList) {
        return [_channelsList count];
    } else {
        return  0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = [aTableView dequeueReusableCellWithIdentifier:@"ChannelTableCell"];
    
    UIImageView *imageView;
    UILabel *label;
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChannelTableCell"];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 100;
        [cell addSubview:imageView];
        
        label = [[UILabel alloc] init];
        label.tag = 101;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 2;
        label.textColor = [UIColor whiteColor];
        [cell addSubview:label];
	} else {
        imageView = (UIImageView *)[cell viewWithTag:100];
        label  = (UILabel *)[cell viewWithTag:101];
    }
    
    if (_channelsList == nil || [_channelsList count] == 0) {
        [self selectActiveChannels];
    }
    
    NSDictionary *channelInfoDict = [_channelsList objectAtIndex:[indexPath row]];
    NSString *channelName = [channelInfoDict objectForKey:@"name"];
    UIImage* channelImage = [UIImage imageNamed: [NSString stringWithFormat:@"%s.png", [[channelInfoDict objectForKey:@"id"] UTF8String]]];
    
    imageView.frame = CGRectMake(3, 3, channelImage.size.width, channelImage.size.height);
    imageView.image = channelImage;
    
    CGFloat rowHeight = [self tableView:aTableView heightForRowAtIndexPath:indexPath];
    
    CGFloat actualFontSize = 9;
    CGSize actualTitleSize = [channelName sizeWithFont:[UIFont systemFontOfSize:9] constrainedToSize:CGSizeMake(aTableView.frame.size.width - 6, rowHeight - CGRectGetMaxY(imageView.frame)) lineBreakMode:NSLineBreakByWordWrapping];
    
    if (rowHeight - CGRectGetMaxY(imageView.frame) > 9) {
/*        CGFloat divHeight = (rowHeight - CGRectGetMaxY(imageView.frame) - actualTitleSize.height)/2;
        if (divHeight < 0) {
            divHeight = 0;
        } else if (divHeight > 3) {
            divHeight = 3;
        }*/
        label.frame = CGRectMake(3, CGRectGetMaxY(imageView.frame) + 3, actualTitleSize.width, actualTitleSize.height);
        label.font = [UIFont systemFontOfSize:actualFontSize];
        label.text = channelName;
        [label setHidden:NO];
    } else {
        [label setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GRID_ROW_HEIGHT*gridScale;
}

@end

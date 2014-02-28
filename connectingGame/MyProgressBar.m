//
//  MyProgressBar.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/10.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MyProgressBar.h"
#import "Constants.h"

#define NUMBER_59_DIV_60 0.01667
#define PIXEL_OFFSET_X   2.7f

@class CCSprite;
@implementation MyProgressBar

enum {
    kTagWhiteLine,
    kTagprogressLine,
    kTagLabel
};

@synthesize progressLine, whiteLine;
@synthesize label, isPaused;
@synthesize remainedTime;
@synthesize delegate;

+(id)progressBarWithPosition:(CGPoint)point
{
    return [[[self alloc] initWithPoint:point] autorelease];
}

-(id)initWithPoint:(CGPoint)point
{
    if(self = [super init]) {
        self.progressLine = [CCSprite spriteWithFile:IMAGE_GREEN_LINE];
        self.progressLine.position = point;
        self.whiteLine = [CCSprite spriteWithFile:IMAGE_WHITE_LINE];
        self.whiteLine.position = point;
        self.label = [CCLabelBMFont labelWithString:@"60" fntFile:FNT_SUB];
        self.label.position = point;
        self.label.scale = 1.2f;
        self.remainedTime = 60;
        [self addChild:self.whiteLine z:kTagWhiteLine tag:kTagWhiteLine];
        [self addChild:self.progressLine z:kTagprogressLine tag:kTagprogressLine];
        [self addChild:self.label     z:kTagLabel     tag:kTagLabel];
    }
	return self;
}

-(void)timePause
{
    self.isPaused = YES;
    [self unschedule:@selector(redraw)];
}

-(void)timeStart
{
    self.isPaused = NO;
    [self schedule:@selector(redraw) interval:1.0f];
}

-(void)redraw
{
    if(self.isPaused) return;
    self.remainedTime--;
    if (self.remainedTime<=0) {
        [self unschedule:@selector(redraw)];
        [delegate timesUp];
    } else if (self.remainedTime==10) {
        self.progressLine.texture = [[CCTextureCache sharedTextureCache] addImage:IMAGE_RED_LINE];
    }
    NSString *tmpStr = [NSString stringWithFormat:@"%d", self.remainedTime];
    [self.label setString:tmpStr];
    self.progressLine.scaleX = 1-NUMBER_59_DIV_60*(60-self.remainedTime);
    self.progressLine.position = ccp(self.progressLine.position.x-PIXEL_OFFSET_X, self.progressLine.position.y);
}


-(void)dealloc
{
    [super dealloc];
}

@end

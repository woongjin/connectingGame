//
//  MyProgressBar.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/10.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol MyProgressBarTimesUp <NSObject>

-(void) timesUp;

@end

@interface MyProgressBar : CCNode {
    CCSprite *progressLine;
    CCSprite *whiteLine;
    CCLabelBMFont *label;
    BOOL      isPaused;
    NSInteger remainedTime;
    
    id <MyProgressBarTimesUp> delegate;
}

@property (nonatomic, retain) CCSprite *progressLine;
@property (nonatomic, retain) CCSprite *whiteLine;
@property (nonatomic, retain) CCLabelBMFont *label;
@property (nonatomic, readwrite) BOOL      isPaused;
@property (nonatomic, readwrite, assign) NSInteger remainedTime;
@property (unsafe_unretained) id <MyProgressBarTimesUp> delegate;

+(id)progressBarWithPosition:(CGPoint)point;
-(void)timeStart;
-(void)timePause;

@end

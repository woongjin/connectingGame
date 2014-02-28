//
//  MainGameLayer.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 12/12/24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "MyProgressBar.h"

@class SimpleAudioEngine;

@interface MainGameLayer : CCLayer<MyProgressBarTimesUp> {
    CGSize size;
    CGPoint halfPoint;
    NSArray *imageArray;
    NSMutableArray *jewelImagesArray;
    NSMutableArray *touchedJewelsArray;
    
    NSInteger  playerCombo;
    NSUInteger score;
    NSUInteger firstTouchedJewelNumber;
    NSUInteger lastOpacityChangedJewelNumber;
    NSUInteger touchHash;
    
    BOOL isTouchedinJewels;
    
    CCMenuItem *pauseItem;
    CCMenu     *pauseMenu;
    CCMenuItem *resumeItem;
    CCMenuItem *mainMenuItem;
    CCMenuItem *highScoreItem;
    CCMenuItem *optionItem;
    
    MyProgressBar *progressBar;
    
    CCLabelBMFont *scoreFont;
    
    CCSprite *explosionSprite;
    
    SimpleAudioEngine *audioEngine;
    BOOL isPlayBGM;
    BOOL isPlayFX;
}

@property(nonatomic, retain) NSArray *imageArray;
@property(nonatomic, retain) NSMutableArray *jewelImagesArray;
@property(nonatomic, retain) NSMutableArray *touchedJewelsArray;
@property(nonatomic, retain) CCMenuItem *pauseItem;
@property(nonatomic, retain) CCMenu     *pauseMenu;
@property(nonatomic, retain) CCMenuItem *resumeItem;
@property(nonatomic, retain) CCMenuItem *mainMenuItem;
@property(nonatomic, retain) CCMenuItem *highScoreItem;
@property(nonatomic, retain) CCMenuItem *optionItem;
@property(nonatomic, retain) MyProgressBar *progressBar;
@property(nonatomic, retain) CCLabelBMFont *scoreFont;
@property(nonatomic, readwrite) NSUInteger firstTouchedJewelNumber;
@property(nonatomic, readwrite) NSUInteger score;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

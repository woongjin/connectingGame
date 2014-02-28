//
//  MainMenuLayer.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/11.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@class SimpleAudioEngine;

@interface MainMenuLayer : CCLayer {
    CGSize size;
    CGPoint halfPoint;
    NSArray *imageArray;
    NSMutableArray *jewelImagesArray;
    
    CCMenuItem *newGameMenuItem;
    CCMenuItem *optionMenuItem;
    CCMenuItem *aboutMenuItem;
    CCMenuItem *resumeGameMenuItem;
    CCMenuItem *highScoreMenuItem;
    
    SimpleAudioEngine *audioEngine;
    BOOL isPlayBGM;
    BOOL isPlayFX;
}

+(CCScene *) scene;

@end

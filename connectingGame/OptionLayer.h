//
//  OptionLayer.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MainMenuLayer.h"
#import "MyToggleButton.h"

@class SimpleAudioEngine;

@interface OptionLayer : MainMenuLayer {
    MyToggleButton *soundOption;
    MyToggleButton *musicOption;
    NSMutableArray *toggleButtonArray;
    NSInteger touchHash;
}

@property (nonatomic, retain) NSMutableArray *toggleButtonArray;

+(CCScene *) scene;

@end

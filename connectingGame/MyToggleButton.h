//
//  MyToggleButton.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface MyToggleButton : CCLayer {
    CCSprite *bgSprite;
    CCSprite *toggleButton;
    CCLabelBMFont *leftLabel;
    CCLabelBMFont *rightLabel;
    BOOL switchOn;
}

@property (nonatomic, retain) CCSprite *bgSprite;
@property (nonatomic, retain) CCSprite *toggleButton;
@property (nonatomic, retain) CCLabelBMFont *leftLabel;
@property (nonatomic, retain) CCLabelBMFont *rightLabel;
@property (nonatomic, readwrite, assign) BOOL switchOn; //default YES

+(id)toggleButtonWithTitle:(NSString *)title position:(CGPoint)point;
+(id)toggleButtonWithTitle:(NSString*)title position:(CGPoint)point LeftLabel:(NSString*)left RightLabel:(NSString*)right;

@end

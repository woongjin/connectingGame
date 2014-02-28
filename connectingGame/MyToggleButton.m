//
//  MyToggleButton.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/14.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MyToggleButton.h"
#import "Constants.h"

#define FONT_SCALE        .7f
#define OPACITY_ENABLED   255
#define OPACITY_DISABLED  64

enum{
  zTagTitleAndBackground = 600,
  zTagButton,
  zTagLabel
};

enum{
    kTagBackground = 700,
    kTagToggleButton,
    kTagSwitchLeftLabel,
    kTagSwitchRightLabel
};

@implementation MyToggleButton

@synthesize bgSprite;
@synthesize toggleButton;
@synthesize leftLabel, rightLabel;
@synthesize switchOn = switchOn_;

+(id)toggleButtonWithTitle:(NSString *)title position:(CGPoint)point
{
    return [self toggleButtonWithTitle:title position:point LeftLabel:@"ON" RightLabel:@"OFF"];
}

+(id)toggleButtonWithTitle:(NSString*)title position:(CGPoint)point LeftLabel:(NSString*)left RightLabel:(NSString*)right
{
    return [[[self alloc] initWithToggleButtonTitle:title position:point LeftLabel:left RightLabel:right] autorelease];
}

-(id)initWithToggleButtonTitle:(NSString*)title position:(CGPoint)point LeftLabel:(NSString*)left RightLabel:(NSString*)right
{
    if(self = [super init]) {
        self.isTouchEnabled = YES;
        switchOn = YES;
        CGFloat halfX = [[CCDirector sharedDirector] winSize].width*.28f;
        CCLabelBMFont *titleFont = [CCLabelBMFont labelWithString:title fntFile:FNT_MAIN];
        titleFont.position = ccp(point.x-halfX, point.y);
        [self addChild:titleFont z:zTagTitleAndBackground];
        
        bgSprite  = [CCSprite spriteWithFile:@"blankFrame02.png"];
        bgSprite.position = ccp(point.x+halfX, point.y);
        [self addChild:bgSprite z:zTagTitleAndBackground tag:kTagBackground];
        
        CGFloat halfSizeOfbankground = bgSprite.contentSize.width*.25f;
        
        toggleButton = [CCSprite spriteWithFile:@"blankButton.png"];
        toggleButton.position = ccp(bgSprite.position.x-halfSizeOfbankground, point.y);
        [self addChild:toggleButton z:zTagButton tag:kTagToggleButton];
        
        leftLabel = [CCLabelBMFont labelWithString:left fntFile:FNT_MAIN];
        leftLabel.scale = FONT_SCALE;
        leftLabel.position = ccp(bgSprite.position.x-halfSizeOfbankground, point.y);
        [self addChild:leftLabel z:zTagLabel tag:kTagSwitchLeftLabel];
        
        rightLabel = [CCLabelBMFont labelWithString:right fntFile:FNT_MAIN];
        rightLabel.opacity = OPACITY_DISABLED;
        rightLabel.scale = FONT_SCALE;
        rightLabel.position = ccp(bgSprite.position.x+halfSizeOfbankground, point.y);
        [self addChild:rightLabel z:zTagLabel tag:kTagSwitchRightLabel];
    }
    return self;
}

-(void)setSwitchOn:(BOOL)on
{
    switchOn_ = on;
    if (on) {
        toggleButton.position = leftLabel.position;
        leftLabel.opacity  = OPACITY_ENABLED;
        rightLabel.opacity = OPACITY_DISABLED;
    } else {
        toggleButton.position = rightLabel.position;
        leftLabel.opacity  = OPACITY_DISABLED;
        rightLabel.opacity = OPACITY_ENABLED;
    }
}

@end

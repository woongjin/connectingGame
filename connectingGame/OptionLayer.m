//
//  OptionLayer.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "OptionLayer.h"
#import "Constants.h"

#define SCALE_BUTTON      .8f
#define OPACITY_ENABLED   255
#define OPACITY_DISABLED  64

enum {
  zTagBackground1 = 400,
  zTagBackground2,
  zTagToggleButton,
  zTagMenu
};

enum {
    zTagMusicOption,
    zTagSoundOption
};

@implementation OptionLayer

@synthesize toggleButtonArray;

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    OptionLayer *layer = [OptionLayer node];
    
    // add layer as a child to scene
    [scene addChild:layer];
    
    // return the scene
    return scene;
}

#pragma mark - init

-(id) init
{
    if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        [self buildOptionMenu];
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

#pragma mark - buildOptionMenu

-(void)buildOptionMenu
{
    CCLabelBMFont *highScoreLabel = [CCLabelBMFont labelWithString:@"OPTIONS" fntFile:@"font07.fnt"];
    highScoreLabel.position = ccp(halfPoint.x, size.height*.9);
    [self addChild:highScoreLabel z:zTagBackground1];
    
    CCSprite *background1 = [CCSprite spriteWithFile:@"blankFrame02.png"];
    background1.position = ccp(halfPoint.x, halfPoint.y*1.12);
    background1.scaleX = 1.8f;
    background1.scaleY = 3.0f;
    [self addChild:background1 z:zTagBackground1];
    
    CCSprite *background2 = [CCSprite spriteWithFile:@"blankButton.png"];
    background2.position = ccp(halfPoint.x, halfPoint.y*1.12);
    background2.scaleX = 3.6f;
    background2.scaleY = 3.0f;
    [self addChild:background2 z:zTagBackground2];
    
    
    CGPoint soundPoint = ccp(halfPoint.x, halfPoint.y*1.3);
    soundOption = [MyToggleButton toggleButtonWithTitle:@"SOUND" position:soundPoint];
    soundOption.scale = SCALE_BUTTON;
    soundOption.tag = zTagSoundOption;
    [self addChild:soundOption z:zTagToggleButton];
    
    musicOption = [MyToggleButton toggleButtonWithTitle:@"MUSIC" position:halfPoint];
    musicOption.scale = SCALE_BUTTON;
    musicOption.tag = zTagMusicOption;
    [self addChild:musicOption z:zTagToggleButton];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault synchronize]) {
        soundOption.switchOn = [userDefault boolForKey:USER_DEFAULT_SOUND];
        musicOption.switchOn = [userDefault boolForKey:USER_DEFAULT_MUSIC];
    }
    
    self.toggleButtonArray = [NSMutableArray arrayWithObjects:soundOption, musicOption, nil];
    
    CCMenuItem *okItem = [CCMenuItemSprite  itemWithNormalSprite:[CCSprite spriteWithFile:@"ok_01.png"]
                                                  selectedSprite:[CCSprite spriteWithFile:@"ok_02.png"]
                                                  disabledSprite:[CCSprite spriteWithFile:@"ok_02.png"]
                                                          target:self
                                                        selector:@selector(selectedOkItem)];
    CCMenu *menu = [CCMenu menuWithItems: okItem, nil];
    menu.scaleX = .945f;
    menu.position = ccp(halfPoint.x*.945, halfPoint.y*.7);
    [self addChild:menu z:zTagMenu];
}

#pragma mark - Menu selectors
-(void)selectedOkItem
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault synchronize]) {
        [userDefault setBool:soundOption.switchOn forKey:USER_DEFAULT_SOUND];
        [userDefault setBool:musicOption.switchOn forKey:USER_DEFAULT_MUSIC];
    }
    if (soundOption.switchOn) {
        [audioEngine playEffect:FX_TRUE01];
    }
    [[CCDirector sharedDirector] popScene];
}

#pragma mark - touches delegate

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    MyToggleButton *touchedButton = [self whichToggleButtonTouched:event];
    if (!touchedButton) return;
    BOOL touchedLeft = [self isTouchedLeftLabel:event myToggleButton:touchedButton];
    BOOL switchOn  = touchedButton.switchOn;
    //touchedLeft = NO, switchLeft = YES ->goto right
    //touchedLeft = YES, switchLeft = NO ->goto left
    if (!touchedLeft && switchOn) {
        [touchedButton setSwitchOn:NO];
        if (touchedButton.tag == zTagMusicOption) {
            [audioEngine stopBackgroundMusic];
        } 
    } else if (touchedLeft && !switchOn) {
        [touchedButton setSwitchOn:YES];
        if (touchedButton.tag == zTagMusicOption) {
            [audioEngine playBackgroundMusic:BGM_01 loop:YES];
        } else if (touchedButton.tag == zTagSoundOption) {
            [audioEngine playEffect:FX_TRUE01];
        }
    }
}

-(MyToggleButton *)whichToggleButtonTouched:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        touchHash = [touch hash];
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
        for (MyToggleButton *toggleButton in toggleButtonArray) {
            if ([self isInsideOfSwitch:convertedLocation bgSprite:toggleButton.bgSprite]) {
                return toggleButton;
            }
        }
    }
    return nil; //not touched toggle buttons
}

-(BOOL)isTouchedLeftLabel:(UIEvent *)event myToggleButton:(MyToggleButton*)myToggleButton
{
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        touchHash = [touch hash];
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
        CGFloat halfWidth  = myToggleButton.leftLabel.contentSize.width*.5f;
        CGFloat halfHeight = myToggleButton.leftLabel.contentSize.height*.5f;
        CGPoint spritePoint = myToggleButton.leftLabel.position;
        if (convertedLocation.x > spritePoint.x-halfWidth  &&
            convertedLocation.x < spritePoint.x+halfWidth  &&
            convertedLocation.y > spritePoint.y-halfHeight &&
            convertedLocation.y < spritePoint.y+halfHeight) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isInsideOfSwitch:(CGPoint)pointXY bgSprite:(CCSprite *)bgSprite{
    CGFloat halfWidthSwitch  = bgSprite.contentSize.width*.5f;
    CGFloat halfHeightSwitch = bgSprite.contentSize.height*.5f;
    CGPoint switchpoint = bgSprite.position;
    if (pointXY.x > switchpoint.x-halfWidthSwitch  &&
        pointXY.x < switchpoint.x+halfWidthSwitch  &&
        pointXY.y > switchpoint.y-halfHeightSwitch &&
        pointXY.y < switchpoint.y+halfHeightSwitch) {
        return YES;
    }
    return NO;
}
 
@end

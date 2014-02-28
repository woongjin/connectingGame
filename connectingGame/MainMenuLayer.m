//
//  MainMenuLayer.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/11.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "MainGameLayer.h"
#import "MyParticle.h"
#import "OptionLayer.h"
#import "HighScoreLayer.h"
#import "Constants.h"

enum {
    zTagBackground = 100,
    zTagMenu,
    zTagParticle
};


@implementation MainMenuLayer

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    MainMenuLayer *layer = [MainMenuLayer node];
    [layer buildMenuItems];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

#pragma mark - init

-(id) init
{
    if( (self=[super init]) ) {
        size = [[CCDirector sharedDirector] winSize];
        halfPoint = ccpMult(CGPointMake(size.width, size.height), .5f);
        audioEngine = [SimpleAudioEngine sharedEngine];
        [self setIsTouchEnabled:YES];
        [self buildBackground];    
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [self buildSound];
}

-(void) dealloc
{
    [super dealloc];
}

#pragma mark - BuildBackground

-(void)buildSound
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault synchronize]) {
        isPlayFX = [userDefault boolForKey:USER_DEFAULT_SOUND];
        isPlayBGM = [userDefault boolForKey:USER_DEFAULT_MUSIC];
        
        if(isPlayBGM) {
            [audioEngine playBackgroundMusic:BGM_01 loop:YES];
        } else {
            [audioEngine stopBackgroundMusic];
        }
    }
}

-(void)buildBackground
{
    CCSprite *back01 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back01.position = ccp(size.width/2, size.height*0.92);
    [self addChild:back01 z:zTagBackground];
    
    CCSprite *back02 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back02.position = ccp(size.width/2, back02.contentSize.height/2);
    [self addChild:back02 z:zTagBackground];
    
    //initialize imageArray
    imageArray = [NSArray arrayWithObjects:
                       IMAGE_JEWELS_00,IMAGE_JEWELS_01, IMAGE_JEWELS_02, IMAGE_JEWELS_03,
                       IMAGE_JEWELS_04, IMAGE_JEWELS_05, IMAGE_JEWELS_06, nil];
    [self buildImagesPosition];
    for (CCSprite *aSprite in jewelImagesArray) {
        [self addChild:aSprite z:zTagBackground];
    }
}

-(CCSprite*)loadImagesWithName:(NSString*)jewelName
{
    return (CCSprite*)[CCSprite spriteWithSpriteFrame:
                       [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:jewelName]];
}

-(void)buildImagesPosition
{
    jewelImagesArray = [NSMutableArray arrayWithCapacity:MAX_JEWELS_X_BY_Y];
    int randomNumber=0,i=0;
    for (i=0; i<MAX_JEWELS_X_BY_Y; i++) {
        randomNumber = arc4random() % IMAGE_MAX;
        CCSprite *jewelSprite = [self loadImagesWithName:[imageArray objectAtIndex:randomNumber]];
        jewelSprite.tag = randomNumber;
        jewelSprite.position = ccp(IMAGE_HALF_SIZE + IMAGE_FULL_SIZE*(int)(i/MAX_JEWELS_X),
                                   IMAGE_START_Y + IMAGE_HALF_SIZE + IMAGE_FULL_SIZE*(int)(i%MAX_JEWELS_Y));
        [jewelImagesArray addObject:jewelSprite];
    }
}

#pragma mark - buildMenus

-(void) buildMenuItems
{
    newGameMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"newgame01.png"]
                                              selectedSprite:[CCSprite spriteWithFile:@"newgame02.png"]
                                              disabledSprite:[CCSprite spriteWithFile:@"newgame02.png"]
                                                      target:self
                                                    selector:@selector(pushSceneMainGame)];
    highScoreMenuItem = [CCMenuItemImage itemWithNormalImage:@"highscore01.png"
                                               selectedImage:@"highscore02.png"
                                               disabledImage:@"highscore02.png"
                                                      target:self
                                                    selector:@selector(pushSceneHighScore)];
    optionMenuItem = [CCMenuItemImage itemWithNormalImage:@"option01.png"
                                            selectedImage:@"option02.png"
                                            disabledImage:@"option02.png"
                                                   target:self
                                                 selector:@selector(pushSceneOption)];
    newGameMenuItem.scale   = 1.2f;
    highScoreMenuItem.scale = 1.2f;
    optionMenuItem.scale    = 1.2f;
    CCMenu *menu = [CCMenu menuWithItems: newGameMenuItem, highScoreMenuItem, optionMenuItem, aboutMenuItem, nil];
    menu.position = halfPoint;
    [menu alignItemsVerticallyWithPadding:10.0f];
    [self addChild:menu z:zTagMenu];
}

#pragma mark - MenuItem Selector

-(void)pushSceneMainGame
{
    if(isPlayFX) [audioEngine playEffect:FX_TRUE01];
    [[CCDirector sharedDirector] pushScene:[MainGameLayer scene]];
}

-(void)pushSceneOption
{
    if(isPlayFX) [audioEngine playEffect:FX_TRUE01];
    [[CCDirector sharedDirector] pushScene:[OptionLayer scene]];
}

-(void)pushSceneHighScore
{
    if(isPlayFX) [audioEngine playEffect:FX_TRUE01];
    [[CCDirector sharedDirector] pushScene:[HighScoreLayer scene]];
}

#pragma mark - touch events

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self createParticle:event];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [audioEngine playEffect:FX_BOOM02];
    [self createParticle:event];
}

-(void)createParticle:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
        MyParticle *particle = [[MyParticle new] autorelease];
        particle.position = convertedLocation;
        [self addChild:particle z:zTagParticle tag:zTagParticle];
        [self performSelector:@selector(removeAddedParticleFromLayer) withObject:nil afterDelay:DELAY_PARTICLE];
    }
}

-(void)removeAddedParticleFromLayer
{
    [self removeChildByTag:zTagParticle cleanup:YES];
}

@end

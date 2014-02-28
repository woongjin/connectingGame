//
//  MainGameLayer.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 12/12/24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainGameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "Constants.h"
#import "MyParticle.h"
#import "HighScoreLayer.h"
#import "OptionLayer.h"

@interface MainGameLayer() {
    
}

@end

enum {
    zTagBackground = 200,
    zTagScore,
    zTagComboLabel,
    zTagPauseButton,
    zTagProgressBar,
    zTagJewels,
    zTagExplode,
    zTagParticle,
    zTagReadyStartLabel,
    zTagTimeUpLabel,
    zTagYesNoMenu,
    zTagPauseMenu
};

enum {
    kTagBackground = 300,
    kTagScore,
    kTagComboLabel,
    kTagPauseButton,
    kTagProgressBar,
    kTagJewels,
    kTagExplode,
    kTagParticle,
    kTagReadyStartLabel,
    kTagTimeUpLabel,
    kTagYesNoMenu,
    kTagPauseMenu
};

@implementation MainGameLayer
@synthesize imageArray, jewelImagesArray, touchedJewelsArray;
@synthesize firstTouchedJewelNumber, score;
@synthesize pauseItem, pauseMenu, resumeItem, mainMenuItem;
@synthesize optionItem, highScoreItem;
@synthesize progressBar, scoreFont;

#pragma mark - scene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	MainGameLayer *layer = [MainGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        
//        self.isTouchEnabled = YES;
        //get window size
        size = [[CCDirector sharedDirector] winSize];
        halfPoint = ccpMult(CGPointMake(size.width, size.height), .5f);
        [self scheduleOnce:@selector(showRedayAndGo) delay:.2f];
        //[self performSelector:@selector(showRedayAndGo) withObject:nil afterDelay:0.2f];
        // may combo bigger than 2
        playerCombo = 0;
        score = 1000;
        lastOpacityChangedJewelNumber = 0;
        audioEngine = [SimpleAudioEngine sharedEngine];
        [self buildSound];
        [self setUp];
        [self buildProgressBar];
    }
    return self;
}


-(void)onEnterTransitionDidFinish
{
    [self buildSound];
    //NSLog(@"onEnterTransitionDidFinish");
}


#pragma mark - Show Ready, Start and Start progressBar
-(void)showRedayAndGo
{
    pauseItem.isEnabled = NO;
    CCLabelBMFont *readyLabel = [CCLabelBMFont labelWithString:@"READY!" fntFile:FNT_MAIN];
    readyLabel.position = halfPoint;
    [self addChild:readyLabel z:zTagReadyStartLabel tag:kTagReadyStartLabel];
    CCFadeIn    *fadeIn  = [CCFadeIn actionWithDuration:.5f];
    CCDelayTime *delay   = [CCDelayTime actionWithDuration:1.0f];
    CCFadeOut   *fadeOut = [CCFadeOut actionWithDuration:.1f];
    CCCallFuncND *func = [CCCallFuncND actionWithTarget:self selector:@selector(showGoLabel) data:nil];
    [readyLabel runAction:[CCSequence actions:fadeIn, delay, fadeOut, func, nil]];
}

-(void)showGoLabel
{
    [self removeChild:[self getChildByTag:kTagReadyStartLabel] cleanup:YES];
    CCLabelBMFont *goLabel = [CCLabelBMFont labelWithString:@"START" fntFile:FNT_MAIN];
    goLabel.position = halfPoint;
    [self addChild:goLabel z:zTagReadyStartLabel tag:kTagReadyStartLabel];
    CCFadeIn    *fadeIn  = [CCFadeIn actionWithDuration:.5f];
    CCDelayTime *delay   = [CCDelayTime actionWithDuration:1.0f];
    CCFadeOut   *fadeOut = [CCFadeOut actionWithDuration:.1f];
    CCCallFuncND *func = [CCCallFuncND actionWithTarget:self selector:@selector(progressBarStart) data:nil];
    [goLabel runAction:[CCSequence actions:fadeIn, delay, fadeOut, func, nil]];
}

-(void)progressBarStart
{
    self.isTouchEnabled = YES;
    [self removeChild:[self getChildByTag:kTagReadyStartLabel] cleanup:YES];
    [self.progressBar timeStart];
    pauseItem.isEnabled = YES;
}


#pragma mark - setUp and building

-(void)buildSound
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault synchronize]) {
        isPlayFX = [userDefault boolForKey:USER_DEFAULT_SOUND];
        isPlayBGM = [userDefault boolForKey:USER_DEFAULT_MUSIC];
        if (isPlayBGM) {
            [audioEngine playBackgroundMusic:BGM_01];
        }
    }
}

-(void)setUp
{
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Score" fntFile:FNT_MAIN];
    label.scale = 0.5f;
    label.anchorPoint = CGPointMake(0, 1);
    label.position = ccp(25, size.height-5);
    [self addChild:label z:zTagScore];
    
    scoreFont = [CCLabelBMFont labelWithString:@"1,000" fntFile:FNT_MAIN];
    scoreFont.position = ccp(size.width/2, size.height*0.9);
    [self addChild:scoreFont z:zTagScore tag:kTagScore];
    
    CCSprite *back01 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back01.position = ccp(size.width/2, size.height*0.92);
    [self addChild:back01 z:zTagBackground];
    
    CCSprite *back02 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back02.position = ccp(size.width/2, back02.contentSize.height/2);
    [self addChild:back02 z:zTagBackground];
    
    //set pause image button
    pauseItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"pause01.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"pause02.png"]
                                        disabledSprite:[CCSprite spriteWithFile:@"pause03.png"]
                                                target:self
                                              selector:@selector(pauseItemTouched)];
    CCMenu *pauseButton = [CCMenu menuWithItems:pauseItem, nil];
    pauseButton.position = ccp(size.width*0.95, size.height*0.95);
    [self addChild:pauseButton z:zTagPauseButton tag:kTagPauseButton];
    
    CCLabelBMFont *comboLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"font06.fnt"];
    comboLabel.scale = 0.6f;
    comboLabel.position = ccp(size.width*0.15, size.height*0.852);
    [self addChild:comboLabel z:zTagComboLabel tag:kTagComboLabel];
    comboLabel.opacity = 0;
    
    //initialize arrays
    self.imageArray = [NSArray arrayWithObjects:
                       IMAGE_JEWELS_00,IMAGE_JEWELS_01, IMAGE_JEWELS_02, IMAGE_JEWELS_03,
                       IMAGE_JEWELS_04, IMAGE_JEWELS_05, IMAGE_JEWELS_06, nil];
    self.touchedJewelsArray = [NSMutableArray array];
    
    //buildImagesPosition randomly
    [self buildImagesPosition];
    
    //buildPauseMenu
    [self buildPauseMenu];
    
    for (CCSprite *aSprite in self.jewelImagesArray) {
        [self addChild:aSprite z:zTagJewels];
    }
}

-(void)buildProgressBar
{
    //setUp progressBar
    CGPoint point = ccp(size.width/2, size.height*0.155);
    self.progressBar = [MyProgressBar progressBarWithPosition:point];
    self.progressBar.delegate = self;
    [self addChild:progressBar z:zTagProgressBar];
}

-(void)buildPauseMenu
{
    resumeItem = [CCMenuItemSprite   itemWithNormalSprite:[CCSprite spriteWithFile:@"resume01.png"]
                                           selectedSprite:[CCSprite spriteWithFile:@"resume02.png"]
                                           disabledSprite:[CCSprite spriteWithFile:@"resume02.png"]
                                                   target:self
                                                 selector:@selector(selectedResuemItem)];
    mainMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"mainmenu01.png"]
                                           selectedSprite:[CCSprite spriteWithFile:@"mainmenu02.png"]
                                           disabledSprite:[CCSprite spriteWithFile:@"mainmenu02.png"]
                                                   target:self
                                                 selector:@selector(selectedMainMenuItem)];
    highScoreItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"highscore01.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"highscore02.png"]
                                            disabledSprite:[CCSprite spriteWithFile:@"highscore02.png"]
                                                    target:self
                                                  selector:@selector(selectedHighScoreItem)];
    optionItem    = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"option01.png"]
                                            selectedSprite:[CCSprite spriteWithFile:@"option02.png"]
                                            disabledSprite:[CCSprite spriteWithFile:@"option02.png"]
                                                    target:self
                                                  selector:@selector(selectedOptionItem)];
    resumeItem.scale   = 1.2f;
    mainMenuItem.scale = 1.2f;
    highScoreItem.scale= 1.2f;
    optionItem.scale   = 1.2f;
    pauseMenu = [CCMenu menuWithItems: resumeItem, mainMenuItem, highScoreItem, optionItem, nil];
    [pauseMenu alignItemsVerticallyWithPadding:10.0f];
    pauseMenu.position = ccp(size.width/2, size.height/2);
    pauseMenu.opacity = 0;
    [resumeItem setIsEnabled:NO];
    [mainMenuItem setIsEnabled:NO];
    [highScoreItem setIsEnabled:NO];
    [optionItem setIsEnabled:NO];
    [self addChild:self.pauseMenu z:zTagPauseMenu tag:kTagPauseMenu];
}

-(void)buildImagesPosition
{
    self.jewelImagesArray = [NSMutableArray arrayWithCapacity:MAX_JEWELS_X_BY_Y];
    int randomNumber=0,i=0;
    for (i=0; i<MAX_JEWELS_X_BY_Y; i++) {
        randomNumber = arc4random() % IMAGE_MAX;
        CCSprite *jewelSprite = [self loadImagesWithName:[self.imageArray objectAtIndex:randomNumber]];
        jewelSprite.tag = randomNumber;
        jewelSprite.position = ccp(IMAGE_HALF_SIZE + IMAGE_FULL_SIZE*(int)(i/MAX_JEWELS_X),
                                   IMAGE_START_Y + IMAGE_HALF_SIZE + IMAGE_FULL_SIZE*(int)(i%MAX_JEWELS_Y));
        [self.jewelImagesArray addObject:jewelSprite];
    }
}

-(CCSprite*)loadImagesWithName:(NSString*)jewelName
{
    return (CCSprite*)[CCSprite spriteWithSpriteFrame:
                       [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:jewelName]];
}

#pragma mark - touched Delegate

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.touchedJewelsArray removeAllObjects];
    int jewelIndex = [self processTouchEvent:event];
    if (jewelIndex<0) return;
    lastOpacityChangedJewelNumber = jewelIndex;
    CCSprite *touchedJewel = [self.jewelImagesArray objectAtIndex:jewelIndex];
    self.firstTouchedJewelNumber = touchedJewel.tag;
    touchedJewel.opacity = OPACITY_HALF_MAX;
    [self.touchedJewelsArray addObject:[NSNumber numberWithInt:jewelIndex]];
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    int i=0,j=0, sameCount=0, opacityCount=0;
    
    for (CCSprite *touchedJewel in [self children]){
        if ([touchedJewel isKindOfClass:[CCSprite class]]) {
            if (touchedJewel.opacity==OPACITY_HALF_MAX) {
                opacityCount++;
            }
        }
    }
    
    //one touched
    if ([self.touchedJewelsArray count]==1) {
        if(isPlayFX) [audioEngine playEffect:FX_FALSE01];
        [self returnChangedJewelOpacity];
        [self.touchedJewelsArray removeAllObjects];
        playerCombo = 0;
        [self hideComboLabel];
        NSLog(@"ccTouchesEnded count 1");
        return;
    }
    
    if (opacityCount==1) {
        if(isPlayFX) [audioEngine playEffect:FX_FALSE01];
        [self returnChangedJewelOpacity];
        [self.touchedJewelsArray removeAllObjects];
        playerCombo = 0;
        [self hideComboLabel];
        NSLog(@"ccTouchesEnded opacity 1");
        return;
    }
    //may need touchedEndIndex
    int touchedEndIndex = [[self.touchedJewelsArray lastObject] intValue];
    
    [self.touchedJewelsArray removeAllObjects];
    for (CCSprite *touchedJewel in [self children]){
        if ([touchedJewel isKindOfClass:[CCSprite class]]) {
            if (touchedJewel.opacity==OPACITY_HALF_MAX) {
                int indexNumber = [self whichJewelsTouched:touchedJewel.position];
                [self.touchedJewelsArray addObject:[NSNumber numberWithInt:indexNumber]];
            }
        }
    }
    for (i=0; i<[self.touchedJewelsArray count]; i++) {
        int indexNumber = [[self.touchedJewelsArray objectAtIndex:i] intValue];
        CCSprite *savedJewel = [self.jewelImagesArray objectAtIndex:indexNumber];
        
        if (self.firstTouchedJewelNumber == [savedJewel tag]) {
            sameCount++;
            if(isPlayFX) [audioEngine playEffect:FX_BOOM];
            [self initParticleAddToLayerWithPosition:savedJewel.position];
            [self removeChild:savedJewel cleanup:YES];
            
            int randomNumber = arc4random() % IMAGE_MAX;
            NSString *str = [self.imageArray objectAtIndex:randomNumber];
            CCSprite *newJewelSprite = [self loadImagesWithName:str];
            newJewelSprite.position = savedJewel.position;
            newJewelSprite.tag = randomNumber;
            [self addChild:newJewelSprite];
            [self.jewelImagesArray removeObjectAtIndex:indexNumber];
            [self.jewelImagesArray insertObject:newJewelSprite atIndex:indexNumber];
        } else {
            [self.touchedJewelsArray removeAllObjects];
            NSLog(@"ccEnd for if else");
            return;
        }
    }
    
    if (sameCount > 2 ) {
        playerCombo++;
        if (playerCombo > 2) {
            [self showComboLabel:playerCombo-2];
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (i=0; i<[self.touchedJewelsArray count]; i++) {
                int indexNumber = [[self.touchedJewelsArray objectAtIndex:i] intValue];
                for (j=1; j<5; j++) {
                    // -9 -8 -7 -1 +1 +7 +8 +9
                    int index1=0, index2=0;
                    if (j==1) {
                        index1 = indexNumber+j;
                        index2 = indexNumber-j;
                    }
                    index1 = indexNumber+(j+5);
                    index2 = indexNumber-(j+5);
                    if (index1>-1 && index1<MAX_JEWELS_X_BY_Y) [tmpArray addObject:[NSNumber numberWithInt:index1]];
                    if (index2>-1 && index2<MAX_JEWELS_X_BY_Y) [tmpArray addObject:[NSNumber numberWithInt:index2]];
                }
            }
            NSArray *tmpArray2 = [self reduceEvenArray:tmpArray];
            for (NSNumber *num in self.touchedJewelsArray) {
                tmpArray2 = (NSMutableArray*)[self removeSameNumber:tmpArray2 number:[num intValue]];
            }
            //NSLog(@"%@",tmpArray2);
            
            for (i=0; i<[tmpArray2 count]; i++) {
                int indexNumber = [[tmpArray2 objectAtIndex:i] intValue];
                CCSprite *savedJewel = [self.jewelImagesArray objectAtIndex:indexNumber];
                //[self initParticleAddToLayerWithPosition:savedJewel.position];
                [self removeChild:savedJewel cleanup:YES];
                
                int randomNumber = arc4random() % IMAGE_MAX;
                NSString *str = [self.imageArray objectAtIndex:randomNumber];
                CCSprite *newJewelSprite = [self loadImagesWithName:str];
                newJewelSprite.position = savedJewel.position;
                newJewelSprite.tag = randomNumber;
                [self addChild:newJewelSprite];
                [self.jewelImagesArray removeObjectAtIndex:indexNumber];
                [self.jewelImagesArray insertObject:newJewelSprite atIndex:indexNumber];
            }
            
        }
    } else {
        playerCombo = 0;
        [self hideComboLabel];
    }
    
    
    if (playerCombo-2>1 && (playerCombo-2)%5==0) {
        score += 10000;
        [self animationExplodeWithIndex:touchedEndIndex];
    }

    [self.touchedJewelsArray removeAllObjects];
    
    score = score + (sameCount*sameCount*(STANDARD_SCORE+playerCombo*10));
    NSString *scoreString = [self processScoreFormat];
    [scoreFont setString:scoreString];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    int jewelIndex = [self processTouchEvent:event];
    if (jewelIndex<0) return;
    int touchedJewelCount = [self.touchedJewelsArray count];
    if (touchedJewelCount>1) {
        CCSprite *touchedJewel = [self.jewelImagesArray objectAtIndex:jewelIndex];
        if (self.firstTouchedJewelNumber == [touchedJewel tag]) {
            if (touchedJewel.opacity!=OPACITY_HALF_MAX) {
                if ([self isAdjacentToNumber:jewelIndex]) {
                    lastOpacityChangedJewelNumber = jewelIndex;
                    touchedJewel.opacity=OPACITY_HALF_MAX;
                    if(isPlayFX) [audioEngine playEffect:FX_TRUE01];
                } 
            }
        } else {
//            [audioEngine playEffect:FX_FALSE01];
        }
    }
    [self.touchedJewelsArray addObject:[NSNumber numberWithInt:jewelIndex]];
}

-(BOOL)isAdjacentToNumber:(int)index
{
    //index is 00 - 63 ?
    if (index<0 && index>63) {
        NSLog(@"func isAdjcentWithNumber, not between 00 and 63");
        return NO;
    }
    //07 15 23 31 39 47 55 63
    //06 14 22 30 38 46 54 62
    //05 13 21 29 37 45 53 61
    //04 12 20 28 36 44 52 60
    //03 11 19 27 35 43 51 59
    //02 10 18 26 34 42 50 58
    //01 09 17 25 33 41 49 57
    //00 08 16 24 32 40 48 56
    int last = lastOpacityChangedJewelNumber;
    switch (last) {
        case 0:
            switch (index) {
                case 1: case 8: case 9:
                    return YES;
            }
        case 7:
            switch (index) {
                case 6: case 14: case 15:
                    return YES;
            }
        case 56:
            switch (index) {
                case 48: case 49: case 57:
                    return YES;
            }
        case 63:
            switch (index) {
                case 54: case 55: case 62:
                    return YES;
            }
    }
    
    //1 ~ 6
    if (last>=1 && last<=6) {
        if (index==last+1 ||
            index==last-1 ||
            index==last+7 ||
            index==last+8 ||
            index==last+9) {
            return YES;
        }
    }
    
    //8 16 24 .. 48
    if (last!=0 && last!= 56 && last%8==0) {
        if (index==last-8 ||
            index==last-7 ||
            index==last+1 ||
            index==last+9 ||
            index==last+8) {
            return YES;
        }
    }
    
    // 15 23 24 .. 55
    if (last!=7 && last!=63 && last%8==7) {
        if (index==last-8 ||
            index==last-9 ||
            index==last-1 ||
            index==last+7 ||
            index==last+8) {
            return YES;
        }
    }
    
    // 57 ~ 62
    if (last>=57&&last<=62) {
        if (index==last-1 ||
            index==last-9 ||
            index==last-8 ||
            index==last-7 ||
            index==last+1) {
            return YES;
        }
    }
    
    if (!((last>=1 &&last<=6)  ||
          (last>=57&&last<=62) ||
          last%8==0 ||
          last%8==7
          )) {
        if (index==last+1 || index==last-1 ||
            index==last+8 || index==last-8 ||
            index==last+7 || index==last+9 ||
            index==last-7 || index==last-9 ) {
            return YES;
        }
    }
    return NO;
}

-(void)returnChangedJewelOpacity
{
    for (CCSprite *touchedJewel in [self children]){
        if ([touchedJewel isKindOfClass:[CCSprite class]]) {
            if (touchedJewel.opacity==OPACITY_HALF_MAX) {
                touchedJewel.opacity=OPACITY_MAX;
            }
        }
    }
}

-(int)processTouchEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        touchHash = [touch hash];
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
        if([self isInsideOfJewels:convertedLocation]){
            return [self whichJewelsTouched:convertedLocation];
        }
    }
    return -1;
}

-(BOOL)isInsideOfJewels:(CGPoint)pointXY{
    if (pointXY.x > IMAGE_START_X   &&
        pointXY.x < IMAGE_START_X+IMAGE_FULL_SIZE*MAX_JEWELS_X &&
        pointXY.y > IMAGE_START_Y  &&
        pointXY.y < IMAGE_START_Y+IMAGE_FULL_SIZE*MAX_JEWELS_Y) {
        return YES;
    }
    return NO;
}

-(int)whichJewelsTouched:(CGPoint)pointXY{
    int index=0;
    for(index=0; index<MAX_JEWELS_X_BY_Y; index++) {
        CCSprite *jewelSprite = [self.jewelImagesArray objectAtIndex:index];
        CGFloat pointX = jewelSprite.position.x;
        CGFloat pointY = jewelSprite.position.y;
        if(pointXY.x > (pointX - ADJUSTED_IMAGE_SIZE)  &&
           pointXY.x < (pointX + ADJUSTED_IMAGE_SIZE)  &&
           pointXY.y > (pointY - ADJUSTED_IMAGE_SIZE)  &&
           pointXY.y < (pointY + ADJUSTED_IMAGE_SIZE) ) {
            return index;
        }
    }
    return -1;
}

-(void)initParticleAddToLayerWithPosition:(CGPoint)point
{
    MyParticle *particle = [[MyParticle new] autorelease];
    particle.position = point;
    [self addChild:particle z:zTagParticle tag:kTagParticle];
    [self performSelector:@selector(removeAddedParticleFromLayer) withObject:nil afterDelay:DELAY_PARTICLE];
}

-(void)removeAddedParticleFromLayer
{
    [self removeChildByTag:kTagParticle cleanup:YES];
}

-(NSString *)processScoreFormat
{
    NSString *scoreString = [NSString stringWithFormat:@"%d",score];
    NSInteger scoreCount = [scoreString length];
    NSInteger quotient  = scoreCount / 3;
    NSInteger remainder = scoreCount % 3;
    NSMutableString *tmpString = [NSMutableString string];
    if (remainder > 0) {
        [tmpString appendString:[scoreString substringWithRange:NSMakeRange(0,remainder)]];
        [tmpString appendString:@","];
    }
    for (int i=0; i<quotient; i++) {
        [tmpString appendString:[scoreString substringWithRange:NSMakeRange(remainder+(i*3),3)]];
        [tmpString appendString:@","];
    }
    return [tmpString substringWithRange:NSMakeRange(0, [tmpString length]-1)];
}


-(NSArray *)reduceEvenArray:(NSMutableArray*)arr
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObject:[arr objectAtIndex:0]];
    NSArray *tmpArray2 = [NSArray arrayWithArray:arr];
    while (YES) {
        tmpArray2 = [self removeSameNumber:tmpArray2 number:[[tmpArray2 objectAtIndex:0] intValue]];
        if ([tmpArray2 count]==0) {
            break;
        } else {
            [tmpArray addObject:[tmpArray2 objectAtIndex:0]];
        }
    }
    return tmpArray;
}

-(NSArray *)removeSameNumber:(NSArray *)array number:(int)number
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSNumber *num in array) {
        if (number != [num intValue]) {
            [tmpArray addObject:num];
        }
    }
    return tmpArray;
}

#pragma mark - explode

-(void)animationExplodeWithIndex:(int)index
{
    int i=0,x=0,y=0,z=0,w=0,yy=0,zz=0;
    //index is 00 - 63 ?
    if (index<0 && index>63) {
        NSLog(@"func animationExplodeWithIndex, not between 00 and 63");
        return;
    }
    [self performSelector:@selector(showAnExplode:) withObject:[NSNumber numberWithInt:index]];
    //07 15 23 31 39 47 55 63
    //06 14 22 30 38 46 54 62
    //05 13 21 29 37 45 53 61
    //04 12 20 28 36 44 52 60
    //03 11 19 27 35 43 51 59
    //02 10 18 26 34 42 50 58
    //01 09 17 25 33 41 49 57
    //00 08 16 24 32 40 48 56
    yy = index%MAX_JEWELS_Y;
    zz = index%MAX_JEWELS_Y;
    for (i=0; i<8; i++) {
        x = index+(MAX_JEWELS_X*i);
        w = index-(MAX_JEWELS_X*i);
        y = index+i;
        z = index-i;
        if (x<MAX_JEWELS_X_BY_Y) {
            if (x!=index) {
                [self performSelector:@selector(showAnExplode:)
                           withObject:[NSNumber numberWithInt:x]
                           afterDelay:.2f*i];
            }
        }
        if (w>-1) {
            if (w!=index) {
                [self performSelector:@selector(showAnExplode:)
                           withObject:[NSNumber numberWithInt:w]
                           afterDelay:.2f*i];
            }
        }
        if (yy++<MAX_JEWELS_Y) {
            if (y!=index) {
                [self performSelector:@selector(showAnExplode:)
                           withObject:[NSNumber numberWithInt:y]
                           afterDelay:.2f*i];
            }
        }
        if (zz-->-1) {
            if (z!=index) {
                [self performSelector:@selector(showAnExplode:)
                           withObject:[NSNumber numberWithInt:z]
                           afterDelay:.2f*i];
            }
        }
    }
}

-(void)showAnExplode:(NSNumber*)index
{
    int indexNumber = [index intValue];
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"explode01_01.png"];
    NSMutableArray *aniFrames = [NSMutableArray array];
    for (int i=1; i<17; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                spriteFrameByName:[NSString stringWithFormat:@"explode01_%02d.png",i]];
        [aniFrames addObject:frame];
    }
    [self addChild:sprite z:zTagExplode tag:kTagExplode];
    CCSprite *s = [self.jewelImagesArray objectAtIndex:indexNumber];
    sprite.position = ccp(s.position.x, s.position.y);
    sprite.scale = 1.5f;
    
    CCSprite *savedJewel = [self.jewelImagesArray objectAtIndex:indexNumber];
    CCCallBlock *removeJewel = [CCCallBlock actionWithBlock:^{
        [self removeChild:savedJewel cleanup:YES];
    }];
    CCCallBlock *removeExplode = [CCCallBlock actionWithBlock:^{
        [self removeChild:sprite cleanup:YES];
    }];
    CCCallBlock *playExplodeEffect = [CCCallBlock actionWithBlock:^{
        if (isPlayFX) [audioEngine playEffect:FX_EXPLODE];
    }];
    
    CCCallBlock *createJewel   = [CCCallBlock actionWithBlock:^{
        int randomNumber = arc4random() % IMAGE_MAX;
        NSString *str = [self.imageArray objectAtIndex:randomNumber];
        CCSprite *newJewelSprite = [self loadImagesWithName:str];
        newJewelSprite.position = savedJewel.position;
        newJewelSprite.tag = randomNumber;
        [self addChild:newJewelSprite];
        [self.jewelImagesArray removeObjectAtIndex:indexNumber];
        [self.jewelImagesArray insertObject:newJewelSprite atIndex:indexNumber];
    }];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:aniFrames delay:.02f];
    //    [sprite runAction: [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:animation] times:10]];
    [sprite runAction:[CCSequence actions:removeJewel, playExplodeEffect, [CCAnimate actionWithAnimation:animation], removeExplode, createJewel, nil]];
}


#pragma mark - ComboLabel
-(void)showComboLabel:(int)comboCount
{
    CCLabelBMFont *label = (CCLabelBMFont*)[self getChildByTag:kTagComboLabel];
    [label setString:[NSString stringWithFormat:@"%d COMBO",comboCount]];
    if(label.opacity==0) label.opacity=OPACITY_MAX;
    CCScaleTo   *scaleTo = [CCScaleTo actionWithDuration:.2f scale:.8f];
    CCDelayTime *delay   = [CCDelayTime actionWithDuration:.2f];
    CCScaleBy   *scaleBy = [CCScaleBy actionWithDuration:.2f scale:.6f];
    [label runAction:[CCSequence actions:scaleTo, delay ,scaleBy, nil]];
}

-(void)hideComboLabel
{
    CCLabelBMFont *label = (CCLabelBMFont*)[self getChildByTag:kTagComboLabel];
    label.opacity = 0;
}

#pragma mark - pauseMenu
-(void)pauseItemTouched
{
    self.progressBar.isPaused = YES;
    [self setIsTouchEnabled:NO];
    [self.pauseItem setIsEnabled:NO];
    [self.resumeItem setIsEnabled:YES];
    [self.optionItem setIsEnabled:YES];
    [self.highScoreItem setIsEnabled:YES];
    [self.mainMenuItem setIsEnabled:YES];
    self.pauseMenu.opacity = 255;
    [self AllJewelsVisible:NO];
    [[CCDirector sharedDirector] pause];
}

#pragma mark - MyProgressBarTimesUp Delegate
-(void)timesUp
{
    self.isTouchEnabled = NO;
    CCLabelBMFont *timeUpLabel = [CCLabelBMFont labelWithString:@"TIMES UP!" fntFile:FNT_MAIN];
    timeUpLabel.position = halfPoint;
    [self addChild:timeUpLabel z:zTagTimeUpLabel tag:kTagTimeUpLabel];
    
    HighScoreLayer *highScoreLayer =[[[HighScoreLayer alloc] init] autorelease];
    [highScoreLayer saveDataWithScore:score];
    [highScoreLayer saveDataIntoGlobalWithScore:score];
    
    CCFadeIn    *fadeIn  = [CCFadeIn actionWithDuration : .2f];
    CCDelayTime *delay   = [CCDelayTime actionWithDuration:1.0f];
    CCFadeOut   *fadeOut = [CCFadeOut actionWithDuration:.1f];
    CCCallFuncND *func = [CCCallFuncND actionWithTarget:self selector:@selector(showYesNoMenu) data:nil];
    [timeUpLabel runAction:[CCSequence actions:fadeIn, delay ,fadeOut, func, nil]];
}

-(void)showYesNoMenu
{
    [self.pauseItem setIsEnabled:NO];
    [self removeChild:[self getChildByTag:kTagTimeUpLabel] cleanup:YES];
    CCMenuItem *yesItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"yes_01.png"]
                                                  selectedSprite:[CCSprite spriteWithFile:@"yes_02.png"]
                                                  disabledSprite:[CCSprite spriteWithFile:@"yes_02.png"]
                                                          target:self
                                                        selector:@selector(selectedYesItem)];
    CCMenuItem *noItem = [CCMenuItemSprite  itemWithNormalSprite:[CCSprite spriteWithFile:@"no_01.png"]
                                                  selectedSprite:[CCSprite spriteWithFile:@"no_02.png"]
                                                  disabledSprite:[CCSprite spriteWithFile:@"no_02.png"]
                                                          target:self
                                                        selector:@selector(selectedNoItem)];
    yesItem.scale = noItem.scale = 0.8f;
    CCMenu *yesNoMenu = [CCMenu menuWithItems: yesItem, noItem, nil];
    [yesNoMenu alignItemsHorizontallyWithPadding:3.0f];
    yesNoMenu.position = halfPoint;
    [self addChild:yesNoMenu z:zTagYesNoMenu tag:kTagYesNoMenu];
    
    HighScoreLayer *highScoreLayer =[[[HighScoreLayer alloc] init] autorelease];
    int ranking = [highScoreLayer getRankingWithScore:score];
    //NSLog(@"%d",ranking);
    
    CCLabelBMFont *OneMoreGameLabel = [CCLabelBMFont labelWithString:@"More Game?" fntFile:FNT_MAIN];
    OneMoreGameLabel.scale = 0.7f;
    CGPoint newPoint = ccp(halfPoint.x, halfPoint.y + OneMoreGameLabel.contentSize.height);
    OneMoreGameLabel.position = newPoint;
    [self addChild:OneMoreGameLabel z:zTagYesNoMenu tag:kTagYesNoMenu];
    
    CCLabelBMFont *rankingLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Ranked %d",ranking]
                                                         fntFile:@"font05.fnt"];
    rankingLabel.scale = 1.1f;
    rankingLabel.position = ccp(halfPoint.x, halfPoint.y + OneMoreGameLabel.contentSize.height*2);
    [self addChild:rankingLabel z:zTagYesNoMenu];
    for (CCSprite *jewel in self.jewelImagesArray) jewel.opacity = OPACITY_HALF_MAX;
}

-(void)selectedYesItem
{
    [self.pauseItem setIsEnabled:YES];
    [self removeAllChildrenWithCleanup:YES];
    self.isTouchEnabled = YES;
    playerCombo = 0;
    score = 1000;
    lastOpacityChangedJewelNumber = 0;
    [self setUp];
    [self buildProgressBar];
    [self performSelector:@selector(showRedayAndGo) withObject:nil afterDelay:0.2f];
}

-(void)selectedNoItem
{
    [self.pauseItem setIsEnabled:YES];
    [[CCDirector sharedDirector] popScene];
}

#pragma makr - PauseMenu
-(void)selectedResuemItem
{
    self.progressBar.isPaused = NO;
    [self setIsTouchEnabled:YES];
    [self.pauseItem setIsEnabled:YES];
    [self.resumeItem setIsEnabled:NO];
    [self.mainMenuItem setIsEnabled:NO];
    [self.highScoreItem setIsEnabled:NO];
    [self.optionItem setIsEnabled:NO];
    self.pauseMenu.opacity = 0;
    
    [self AllJewelsVisible:YES];
    [[CCDirector sharedDirector] resume];
}

-(void)selectedMainMenuItem
{
    [audioEngine stopBackgroundMusic];
    [self setIsTouchEnabled:YES];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] popScene];
}

-(void)selectedHighScoreItem
{
    self.progressBar.isPaused = YES;
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] pushScene:[HighScoreLayer scene]];
}

-(void)selectedOptionItem
{
    self.progressBar.isPaused = YES;
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] pushScene:[OptionLayer scene]];
}

-(void)AllJewelsVisible:(BOOL)visible
{
    if (visible) {
        for (CCSprite *jewel in self.jewelImagesArray) jewel.opacity = 255;
    } else {
        for (CCSprite *jewel in self.jewelImagesArray) jewel.opacity = 0;
    }
}

@end

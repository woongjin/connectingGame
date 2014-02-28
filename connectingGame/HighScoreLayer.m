//
//  HighScoreLayer.m
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "HighScoreLayer.h"
#import "TouchMongoDB.h"
#import "MyCoreData.h"
#import "DB_Constants.h"
#import "Constants.h"
#import "Rank.h"

#define FIRST_LABEL_POSITION_Y 384
#define  LAST_LABEL_POSITION_Y  96

enum {
    zTagBackground1 = 500,
    zTagBackground2,
    zTagOption,
    zTagMenu,
    zTagLoadingLabel
};

@implementation HighScoreLayer

@synthesize fetchedResultsController, managedObjectContext, addingManagedObjectContext;
@synthesize labelArray;
@synthesize optionMenu, glMenu;
@synthesize loadingLabel;

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    HighScoreLayer *layer = [HighScoreLayer node];
    
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
        size = [[CCDirector sharedDirector] winSize];
        audioEngine = [SimpleAudioEngine sharedEngine];
        halfPoint = ccpMult(CGPointMake(size.width, size.height), .5f);
        movedY = 0.0f;
        [self buildCoreData];
        [self buildBackground];
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

-(void) onEnter
{
    [super onEnter];
    [self buildSound];
}

#pragma mark - building

-(void)buildSound
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault synchronize]) {
        isPlayFX = [userDefault boolForKey:USER_DEFAULT_SOUND];
        isPlayBGM = [userDefault boolForKey:USER_DEFAULT_MUSIC];
    }
}

-(void)buildBackground
{
    CCSprite *back01 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back01.position = ccp(size.width/2, size.height*0.92);
    [self addChild:back01 z:zTagBackground2];
    
    CCSprite *back02 = [CCSprite spriteWithFile:IMAGE_BACK_TOP_BOTTOM];
    back02.position = ccp(size.width/2, back02.contentSize.height/2);
    [self addChild:back02 z:zTagBackground2];
    
    CCMenuItem *okItem = [CCMenuItemSprite  itemWithNormalSprite:[CCSprite spriteWithFile:@"ok_01.png"]
                                                  selectedSprite:[CCSprite spriteWithFile:@"ok_02.png"]
                                                  disabledSprite:[CCSprite spriteWithFile:@"ok_02.png"]
                                                          target:self
                                                        selector:@selector(selectedOkItem)];
    CCMenu *menu = [CCMenu menuWithItems: okItem, nil];
    menu.position = ccp(halfPoint.x, back02.contentSize.height/2);
    [self addChild:menu z:zTagMenu];
    
    CCMenuItem *optionItem = [CCMenuItemImage itemWithNormalImage:@"gear01.png"
                                                    selectedImage:@"gear02.png"
                                                            block:^(id sender) {
                                                                [self removeAllScoreLabel];
                                                                [self changeOpacityAllCCSprite:127];
                                                                self.optionMenu.opacity = 0;
                                                                menu.opacity = 0;
                                                                menu.isTouchEnabled = NO;
                                                                self.glMenu.opacity = OPACITY_MAX;
                                                                self.glMenu.isTouchEnabled = YES;
                                                        }];
    self.optionMenu = [CCMenu menuWithItems:optionItem, nil];
    optionMenu.position = ccp(size.width*.93f, size.height*.95f);
    [self addChild:optionMenu z:zTagOption];
    CCMenuItem *globalItem = [CCMenuItemImage itemWithNormalImage:@"Global01.png"
                                                    selectedImage:@"Global02.png"
                                                            block:^(id sender) {
                                                                [self changeOpacityAllCCSprite:255];
                                                                [self removeAllScoreLabel];
                                                                self.optionMenu.opacity = OPACITY_MAX;
                                                                self.glMenu.opacity = 0;
                                                                menu.isTouchEnabled = YES;
                                                                menu.opacity = OPACITY_MAX;
                                                                self.glMenu.isTouchEnabled = NO;
                                                                self.isTouchEnabled = NO;
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    [optionItem setIsEnabled:NO];
                                                                    optionItem.visible = NO;
                                                                    [self makeGlobalScore];
                                                                    [self dissmissLoding];
                                                                    self.isTouchEnabled = YES;
                                                                    [optionItem setIsEnabled:YES];
                                                                    optionItem.visible = YES;
                                                                });
                                                                [self showLoding];
                                                            }];
    CCMenuItem *localItem  = [CCMenuItemImage itemWithNormalImage:@"Myscore01.png"
                                                    selectedImage:@"Myscore02.png"
                                                            block:^(id sender) {
                                                                [self changeOpacityAllCCSprite:255];
                                                                [self removeAllScoreLabel];
                                                                [self makeLocalScore];
                                                                self.optionMenu.opacity = OPACITY_MAX;
                                                                self.glMenu.opacity = 0;
                                                                menu.isTouchEnabled = YES;
                                                                menu.opacity = OPACITY_MAX;
                                                                self.glMenu.isTouchEnabled = NO;
                                                            }];
    globalItem.scale = 1.5f;
    localItem.scale  = 1.5f;
    self.glMenu     = [CCMenu menuWithItems:globalItem, localItem, nil];
    [glMenu alignItemsVertically];
    glMenu.position = ccp(halfPoint.x, halfPoint.y);
    glMenu.opacity  = 0;
    [self addChild:glMenu z:zTagMenu];
    
    CCLabelBMFont *highScoreLabel = [CCLabelBMFont labelWithString:@"HIGH SCORE" fntFile:@"font07.fnt"];
    highScoreLabel.position = ccp(halfPoint.x, size.height*.9);
    [self addChild:highScoreLabel z:zTagBackground2];
    
    [self makeLocalScore];
}

-(void)showLoding
{
    self.loadingLabel = [CCLabelBMFont labelWithString:@"Loading.." fntFile:@"font05.fnt"];
    self.loadingLabel.position = ccp(halfPoint.x, halfPoint.y);
    [self addChild:self.loadingLabel z:zTagLoadingLabel tag:999];
    NSString *loadingStr = @"Loading...";
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i=0; i<[loadingStr length]; i++) {
        CCCallBlock *c = [CCCallBlock actionWithBlock:^{
            self.loadingLabel.string = [loadingStr substringToIndex:i+1];
        }];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:.3f];
        [tmpArray addObject:c];
        [tmpArray addObject:delay];
    }
    [self.loadingLabel runAction:[CCRepeatForever actionWithAction:[CCSequence actionWithArray:tmpArray]]];
    //NSLog(@"showLoding %@",[self children]);
}

-(void)dissmissLoding
{
    [self.loadingLabel stopAllActions];
    [self.loadingLabel removeFromParentAndCleanup:YES];
}

#pragma mark - Touch CoreData

-(void)saveDataIntoGlobalWithScore:(int)score
{
    TouchMongoDB *mongoDB = [TouchMongoDB sharedTouchMongoDB];
    NSString *scoreStr = [NSString stringWithFormat:@"%d",score];
    NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"name",scoreStr,@"score", nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [mongoDB insertDocuments:tmpDic];
    });
}

-(void)makeGlobalScore
{
    TouchMongoDB *mongoDB = [TouchMongoDB sharedTouchMongoDB];
    self.labelArray = [NSMutableArray array];
    NSArray *globalScore = [mongoDB getData];
    if (globalScore == nil) {
        CCLabelBMFont *l = [CCLabelBMFont labelWithString:@"Sorry, Check Network Status" fntFile:@"font05.fnt"];
        l.scaleX = size.width*.7f / l.contentSize.width;
        l.position = ccp(halfPoint.x, halfPoint.y);
        [self.labelArray addObject:l];
        [self addChild:l z:zTagBackground1];
        return;
    }
    NSMutableArray *tmpRankArray = [NSMutableArray array]; //NSString
    NSMutableArray *score = [NSMutableArray array]; //NSString
    for (NSDictionary *data in globalScore) {
        NSString *tmpString = [data objectForKey:@"score"];
        [tmpRankArray addObject:tmpString];
    }
    tmpRankArray = [self sortArrayData:tmpRankArray];
    if ([tmpRankArray count]>0) {
        NSString *firstScoreString = [self processScoreFormat:[[tmpRankArray objectAtIndex:0] intValue]];
        int lengthFirstScore = [firstScoreString length];
        for (NSString *str in tmpRankArray) {
            NSString *tmpString =[self processScoreFormat:[str intValue]];
            int spaceLength = lengthFirstScore - [tmpString length];
            [score addObject:[self makeSpaceFromFront:tmpString spaceLength:spaceLength]];
        }
        self.labelArray = [NSMutableArray array];
        for (int i=0; i<[score count]; i++) {
            NSString *tmp = [NSString stringWithFormat:@"%2d. %@",i+1,[score objectAtIndex:i]];
            CCLabelBMFont *label = [CCLabelBMFont labelWithString:tmp fntFile:@"font05.fnt"];
            label.position = ccp(halfPoint.x, size.height*(0.8-i*0.1));
            [self.labelArray addObject:label];
            [self addChild:label z:zTagBackground1 tag:zTagBackground2];
        }
    }
}

-(NSMutableArray*)sortArrayData:(NSMutableArray*)array
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:array];
    for (int i=0; i<[tmpArray count]; i++) {
        for (int j=0; j<[tmpArray count]; j++) {
            if (i==j) continue;
            int tmp1 = [[tmpArray objectAtIndex:i] intValue];
            int tmp2 = [[tmpArray objectAtIndex:j] intValue];
            if (tmp1>tmp2) {
                NSString *tmpStr = [tmpArray objectAtIndex:i];
                [tmpArray replaceObjectAtIndex:i withObject:[tmpArray objectAtIndex:j]];
                [tmpArray replaceObjectAtIndex:j withObject:tmpStr];
            }
        }
    }
    //NSLog(@"%@",tmpArray);
    return tmpArray;
}

-(void)makeLocalScore
{
    NSArray *tmpRankArray = [fetchedResultsController fetchedObjects];
    if ([tmpRankArray count]>0) {
        NSMutableArray *score = [NSMutableArray array];
        //may a first object is the biggest score
        NSString *firstScoreString = [self processScoreFormat:[((Rank*)[tmpRankArray objectAtIndex:0]).score intValue]];
        int lengthFirstScore = [firstScoreString length];
        for (Rank *rank in tmpRankArray) {
            NSString *tmpString = [self processScoreFormat:[rank.score intValue]];
            int spaceLength = lengthFirstScore - [tmpString length];
            [score addObject:[self makeSpaceFromFront:tmpString spaceLength:spaceLength]];
        }
        self.labelArray = [NSMutableArray array];
        for (int i=0; i<[score count]; i++) {
            NSString *tmp = [NSString stringWithFormat:@"%2d. %@",i+1,[score objectAtIndex:i]];
            CCLabelBMFont *label = [CCLabelBMFont labelWithString:tmp fntFile:@"font05.fnt"];
            label.position = ccp(halfPoint.x, size.height*(0.8-i*0.1));
            [self.labelArray addObject:label];
            [self addChild:label z:zTagBackground1 tag:zTagBackground2];
        }
    }
}

-(void)removeAllScoreLabel
{
    for (CCLabelBMFont *label in self.labelArray) {
        [self removeChild:label cleanup:YES];
    }
}

-(void)saveDataWithScore:(int)score
{
    NSManagedObjectContext *context = [self managedObjectContext];
    Rank *aRank = [NSEntityDescription insertNewObjectForEntityForName:@"Rank" inManagedObjectContext:context];
    
    aRank.name = @"";
    aRank.score = [NSNumber numberWithInt:score];
    
    NSError *error;
    
    if (![context save:&error]) {
        NSLog(@"save: %@", [error localizedDescription]);
    }
}

-(int)getRankingWithScore:(int)score
{
    int count=0;
    NSArray *tmpRankArray = [fetchedResultsController fetchedObjects];
    for (Rank *rank in tmpRankArray) {
        count++;
        if ([[rank score] intValue] == score) {
            return count;
        }
    }
    return -1;
}

-(void)deleteData;
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *tmpRankArray = [fetchedResultsController fetchedObjects];
    [context deleteObject:[tmpRankArray objectAtIndex:0]];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"deleteAllData, couldn't delete: %@", [error localizedDescription]);
    }
}

-(void)buildCoreData
{
    self.managedObjectContext = [[MyCoreData shareMyCoreData] managedObjectContext];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

#pragma mark - processScoreFormat

-(NSString *)processScoreFormat:(int)score
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

-(NSString *)makeSpaceFromFront:(NSString *)str spaceLength:(int)len
{
    int i=0;
    NSMutableString *tmpString = [NSMutableString string];
    for (i=0; i<len; i++) {
        [tmpString appendString:@"  "];
    }
    [tmpString appendString:str];
    return tmpString;
}

-(void)changeOpacityAllCCSprite:(int)o
{
    for (CCSprite *child in [self children]) {
        child.opacity = o;
    }
}

#pragma mark - Menu selectors
-(void)selectedOkItem
{
    if (isPlayFX) {
        [audioEngine playEffect:FX_TRUE01];
    }
    [[CCDirector sharedDirector] popScene];
}

#pragma mark - touches delegate

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"ccTouchesBegan");
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        CGPoint location = [touch locationInView: [touch view]];
        CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
        CGPoint preLocation = [touch previousLocationInView:[touch view]];
        CGPoint preConvertedLocation = [[CCDirector sharedDirector] convertToGL:preLocation];
        movedY = convertedLocation.y-preConvertedLocation.y;
        
        CCLabelBMFont *firstLabel = [self.labelArray objectAtIndex:0];
        CCLabelBMFont *lastLabel = [self.labelArray lastObject];
        
        // moved Up, firstLabel doesn't move up
        if (movedY<0 && firstLabel.position.y<=size.height*0.8) return;
        
        // moved down, firstLabel doesn't move down
        if (movedY>0 && lastLabel.position.y>=size.height*0.2) return;
        
        for (CCLabelBMFont *label in self.labelArray) {
            label.position = ccp(label.position.x, label.position.y+movedY);
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"ccTouchesEnded");
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rank" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	return fetchedResultsController;
}

@end

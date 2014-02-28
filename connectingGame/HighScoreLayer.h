//
//  HighScoreLayer.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 13/01/15.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "cocos2d.h"
#import "MainMenuLayer.h"

@interface HighScoreLayer : CCLayer<NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectContext *addingManagedObjectContext;
    
    CGSize size;
    CGPoint halfPoint;
    CGFloat movedY;
    NSMutableArray *labelArray;
    
    SimpleAudioEngine *audioEngine;
    BOOL isPlayBGM;
    BOOL isPlayFX;
    
    CCMenu     *optionMenu;
    CCMenu     *glMenu;
    
    CCLabelBMFont *loadingLabel;
}

@property (nonatomic, retain) NSMutableArray *labelArray;
@property (nonatomic, retain) CCMenu     *optionMenu;
@property (nonatomic, retain) CCMenu     *glMenu;
@property (nonatomic, retain) CCLabelBMFont *loadingLabel;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

+(CCScene *) scene;
-(void)saveDataWithScore:(int)score;
-(int)getRankingWithScore:(int)score;
-(void)saveDataIntoGlobalWithScore:(int)score;

@end

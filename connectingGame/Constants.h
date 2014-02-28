//
//  Constants.h
//  connectingGame
//
//  Created by HWANG WOONGJIN on 12/12/24.
//
//

#import <Foundation/Foundation.h>

#ifndef connectingGame_Constants_h
#define connectingGame_Constants_h

#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + arc4random() % ((__MAX__+1)-(__MIN__)))
#define GET_SPRITE_BY_NAME(__FILE_NAME__) (CCSprite*)[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:__FILE_NAME__]]
#define SET_TEXTURE(__TARGET__, __KEY__) [__TARGET__ setTexture:[[CCTextureCache sharedTextureCache] textureForKey:__KEY__]];
#define SET_TEXTURE_RECT_BY_NAME(__TARGET__, __NAME__) [__TARGET__ setTextureRect:[[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:__NAME__] rect]]
#define SET_TEXTURE_BY_TAG_RECT_BY_NAME(__TAG__, __NAME__) [(CCSprite*)[self getChildByTag:__TAG__] setTextureRect:[[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:__NAME__] rect]]
#define SET_TEXTURE_BY_TAG_RECT(__TAG__, __RECT__) [(CCSprite*)[self getChildByTag:__TAG__] setTextureRect:__RECT__]
#define SET_TEXTURE_BY_TAG_BY_JEWEL_NUM(__TAG__, __NUM__) [(CCSprite*)[self getChildByTag:__TAG__] setTextureRect:[(CCSprite*)[CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"jewels%02d.png",__NUM__ ]]] textureRect]]

#define GLOBAL_MENU_FONT_SIZE   12

#define USER_DEFAULT_SOUND      @"SOUND"
#define USER_DEFAULT_MUSIC      @"MUSIC"

#define IMAGE_START_X            0.0f
#define IMAGE_START_Y           80.0f

#define IMAGE_FULL_SIZE         40.0f
#define IMAGE_HALF_SIZE         20.0f
#define ADJUSTED_IMAGE_SIZE     16.5f

#define PLIST_EXPLODE           @"explode01.plist"

#define IMAGE_MAX               7
#define PLIST_JEWELS            @"jewels.plist"
#define IMAGE_JEWELS_00         @"jewels00.png"
#define IMAGE_JEWELS_01         @"jewels01.png"
#define IMAGE_JEWELS_02         @"jewels02.png"
#define IMAGE_JEWELS_03         @"jewels03.png"
#define IMAGE_JEWELS_04         @"jewels04.png"
#define IMAGE_JEWELS_05         @"jewels05.png"
#define IMAGE_JEWELS_06         @"jewels06.png"

#define IMAGE_BACK_TOP_BOTTOM   @"back01.png"

#define IMAGE_PAUSE             @"pause.png"
#define IMAGE_FIRE              @"fire.png"

#define IMAGE_RED_LINE          @"line01.png"
#define IMAGE_GREEN_LINE        @"line02.png"
#define IMAGE_WHITE_LINE        @"line03.png"

#define FNT_MAIN                @"font01.fnt"
#define FNT_SUB                 @"font02.fnt"

#define FX_BOOM                 @"true02.mp3"
#define FX_BOOM02               @"boom02.mp3"
#define FX_EXPLODE              @"explodeEffect.mp3"
#define FX_FALSE01              @"false01.mp3"
#define FX_TRUE01               @"true01.mp3"
#define FX_TRUE02               @"true02.mp3"

#define BGM_01                  @"bgm01.mp3"

#define MAX_JEWELS_X            8
#define MAX_JEWELS_Y            8
#define MAX_JEWELS_X_BY_Y       64

//delay
#define DELAY_PARTICLE          2.3f

#define STANDARD_SCORE          100

#define OPACITY_MAX             255
#define OPACITY_HALF_MAX        127

#endif

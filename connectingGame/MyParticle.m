//
//  MyParticle.m
//  ParticleManager
//
//  Created by WOONGJIN HWANG on 12/06/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyParticle.h"
#import "Constants.h"

@implementation MyParticle

-(id) init
{
    return [self initWithTotalParticles:2500];
}

-(id) initWithTotalParticles:(NSUInteger)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		// duration
		duration = 0;
        
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
        
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
        
		// Gravity Mode:  radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
        
		//  Gravity Mode: speed of particles
		self.speed = 180;
		self.speedVar = 50;
        
		// angle
		angle = 90;
		angleVar = 180;
        
		// life of particles
		life = 3.5f;
		lifeVar = 1;
        
		// emits per frame
		emissionRate = totalParticles/life;
        
		// color of particles
		startColor.r = 0.5f;
		startColor.g = 0.5f;
		startColor.b = 0.5f;
		startColor.a = 1.0f;
		startColorVar.r = 0.5f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.1f;
		endColor.r = 0.1f;
		endColor.g = 0.1f;
		endColor.b = 0.1f;
		endColor.a = 0.2f;
		endColorVar.r = 0.1f;
		endColorVar.g = 0.1f;
		endColorVar.b = 0.1f;
		endColorVar.a = 0.2f;
        
		// size, in pixels
		startSize = 50.0f;
		startSizeVar = 2.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
        
		self.texture = [[CCTextureCache sharedTextureCache] textureForKey:IMAGE_FIRE];
        
		// additive
		self.blendAdditive = NO;
	}
    
	return self;
}

@end

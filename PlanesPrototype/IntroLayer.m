//
//  IntroLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "LevelSelectLayer.h"
#import "GameLayer.h"
#import "MainMenuLayer.h"

#pragma mark - IntroLayer

@implementation IntroLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(void) onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
#ifdef EDITOR
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
#else
    
    LevelSelectLayer *newLayer = [[[LevelSelectLayer alloc] initWithMode:LEVEL_SELECT_MODE_GAME] autorelease];
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
#endif
    
    
}
@end

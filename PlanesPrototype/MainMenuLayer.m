//
//  MainMenuLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 28.01.13.
//
//

#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "EditorLayer.h"
#import "LevelSelectLayer.h"



@implementation MainMenuLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    
    MainMenuLayer *mml = [MainMenuLayer node];
    [scene addChild:mml];
    
	return scene;
}

-(id) init
{
	if (self = [super init])
    {
        CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
        bg.position = ccp (self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
		[CCMenuItemFont setFontSize:28];
        
        CCSprite *unpressedButton = [CCSprite spriteWithFile:@"popupButtonBase.png"];
        unpressedButton.color = flowerColors[FLOWERS_COLOR_PINK];
        unpressedButton.opacity = DEFAULT_OPACITY;
        CCLabelTTF *labelPlayUnpressed = [CCLabelTTF labelWithString:@"Play" fontName:@"Marker Felt" fontSize:48];
        labelPlayUnpressed.position = ccp(unpressedButton.contentSize.width * 0.48, unpressedButton.contentSize.height * 0.5);
        [unpressedButton addChild:labelPlayUnpressed];

        CCSprite *pressedButton = [CCSprite spriteWithFile:@"popupButtonBase.png"];
        pressedButton.color = flowerColors[FLOWERS_COLOR_BLUE];
        pressedButton.opacity = DEFAULT_OPACITY;
        CCLabelTTF *labelPlayPressed = [CCLabelTTF labelWithString:@"Play" fontName:@"Marker Felt" fontSize:48];
        labelPlayPressed.position = ccp(pressedButton.contentSize.width * 0.48, pressedButton.contentSize.height * 0.5);
        [pressedButton addChild:labelPlayPressed];
        
        CCMenuItemSprite *playButton = [CCMenuItemSprite itemWithNormalSprite:unpressedButton selectedSprite:pressedButton target:self selector:@selector(playButtonPressed)];
        
        CCSprite *unpressedEditorButton = [CCSprite spriteWithFile:@"popupButtonBase.png"];
        unpressedEditorButton.color = flowerColors[FLOWERS_COLOR_PINK];
        unpressedEditorButton.opacity = DEFAULT_OPACITY;

        CCLabelTTF *labelEditorUnpressed = [CCLabelTTF labelWithString:@"Editor" fontName:@"Marker Felt" fontSize:48];
        labelEditorUnpressed.position = ccp(unpressedEditorButton.contentSize.width * 0.48, unpressedEditorButton.contentSize.height * 0.5);
        [unpressedEditorButton addChild:labelEditorUnpressed];
        
        CCSprite *pressedEditorButton = [CCSprite spriteWithFile:@"popupButtonBase.png"];
        pressedEditorButton.color = flowerColors[FLOWERS_COLOR_BLUE];
        pressedEditorButton.opacity = DEFAULT_OPACITY;

        CCLabelTTF *labelEditorPressed = [CCLabelTTF labelWithString:@"Editor" fontName:@"Marker Felt" fontSize:48];
        labelEditorPressed.position = ccp(pressedEditorButton.contentSize.width * 0.48, pressedEditorButton.contentSize.height * 0.5);
        [pressedEditorButton addChild:labelEditorPressed];
        
        CCMenuItemSprite *editorButton = [CCMenuItemSprite itemWithNormalSprite:unpressedEditorButton selectedSprite:pressedEditorButton target:self selector:@selector(editorButtonPressed)];
		
		CCMenu *menu = [CCMenu menuWithItems:playButton, editorButton, nil];
		[menu alignItemsVerticallyWithPadding:20];
        CGSize size = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		[self addChild:menu];

    }
    
    return self;
}

- (void)playButtonPressed
{
    LevelSelectLayer *newLayer = [[[LevelSelectLayer alloc] initWithMode:LEVEL_SELECT_MODE_GAME] autorelease];
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

- (void)editorButtonPressed
{
    LevelSelectLayer *newLayer = [[[LevelSelectLayer alloc] initWithMode:LEVEL_SELECT_MODE_EDITOR] autorelease];
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

@end

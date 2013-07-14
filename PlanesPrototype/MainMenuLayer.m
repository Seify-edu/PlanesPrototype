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
        CCSprite *bg = [CCSprite spriteWithFile:@"BlueSkyBg.jpg"];
        bg.position = ccp (self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
		[CCMenuItemFont setFontSize:28];
        
        CCSprite *unpressedButton = [CCSprite spriteWithFile:@"redButtonUnpressed.png"];
        CCLabelTTF *labelPlayUnpressed = [CCLabelTTF labelWithString:@"Play" fontName:@"Marker Felt" fontSize:64];
        labelPlayUnpressed.position = ccp(unpressedButton.contentSize.width * 0.48, unpressedButton.contentSize.height * 0.67);
        [unpressedButton addChild:labelPlayUnpressed];

        CCSprite *pressedButton = [CCSprite spriteWithFile:@"redButtonPressed.png"];
        CCLabelTTF *labelPlayPressed = [CCLabelTTF labelWithString:@"Play" fontName:@"Marker Felt" fontSize:64];
        labelPlayPressed.position = ccp(pressedButton.contentSize.width * 0.48, pressedButton.contentSize.height * 0.57);
        [pressedButton addChild:labelPlayPressed];
        
        CCMenuItemSprite *playButton = [CCMenuItemSprite itemWithNormalSprite:unpressedButton selectedSprite:pressedButton target:self selector:@selector(playButtonPressed)];
        
        CCSprite *unpressedEditorButton = [CCSprite spriteWithFile:@"redButtonUnpressed.png"];
        CCLabelTTF *labelEditorUnpressed = [CCLabelTTF labelWithString:@"Editor" fontName:@"Marker Felt" fontSize:64];
        labelEditorUnpressed.position = ccp(unpressedEditorButton.contentSize.width * 0.48, unpressedEditorButton.contentSize.height * 0.67);
        [unpressedEditorButton addChild:labelEditorUnpressed];
        
        CCSprite *pressedEditorButton = [CCSprite spriteWithFile:@"redButtonPressed.png"];
        CCLabelTTF *labelEditorPressed = [CCLabelTTF labelWithString:@"Editor" fontName:@"Marker Felt" fontSize:64];
        labelEditorPressed.position = ccp(pressedEditorButton.contentSize.width * 0.48, pressedEditorButton.contentSize.height * 0.57);
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelectLayer sceneWithNextScene:[GameLayer scene]] withColor:ccWHITE]];
    
}

- (void)editorButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelectLayer sceneWithNextScene:[EditorLayer scene]] withColor:ccWHITE]];
}

@end

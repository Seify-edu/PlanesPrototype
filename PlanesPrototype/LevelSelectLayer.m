//
//  LevelSelectLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 11.02.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "LevelSelectLayer.h"
#import "MainMenuLayer.h"
#import "Constants.h"
#import "EditorLayer.h"

@implementation LevelSelectLayer

- (CCMenuItemSprite *)createButtonWithNormalSprite:(NSString *)normS selectedSprite:(NSString *)selS Text:(NSString *)text Selector:(SEL)sel;
{
    CCSprite *normalSprite = [CCSprite spriteWithFile:normS];
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:48];
    label.position = ccp(normalSprite.contentSize.width * 0.5, normalSprite.contentSize.height * 0.7);
    label.color = UI_COLOR_GREY;
    label.opacity = DEFAULT_OPACITY;
    [normalSprite addChild:label];
    
    CCSprite *selectedSprite = [CCSprite spriteWithFile:selS];
    CCLabelTTF *label2 = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:48];
    label2.position = ccp(selectedSprite.contentSize.width * 0.5, selectedSprite.contentSize.height * 0.7);
    label2.color = UI_COLOR_GREY;
    label2.opacity = DEFAULT_OPACITY;
    [selectedSprite addChild:label2];
    
    CCMenuItemSprite *sp = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector: sel];
    
    return sp;
}

- (id)init
{
    return [self initWithMode:LEVEL_SELECT_MODE_GAME];
}

- (id)initWithMode:(int)mode
{
    if (self = [super init])
    {
        self.mode = mode;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
        bg.position = ccp(self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
#define RAWS_COUNT 6
#define LEVELS_IN_PACK 30
        
        int row = 0;
        
        for (int buttonIndex = 0; buttonIndex < LEVELS_IN_PACK; buttonIndex++) {
            
            int levelNumber =  buttonIndex + 1;
            int prevLevelNumber = buttonIndex;
            NSMutableArray *menuItems;
            
            if ((buttonIndex % RAWS_COUNT) == 0) {
                menuItems = [NSMutableArray array];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL levelEnabled = YES; // first level avaible ever
            if (levelNumber > 1) {
                NSString *levWonKey = [NSString stringWithFormat:@"pack%dlevel%dWon", 1, prevLevelNumber ];
                levelEnabled = [defaults boolForKey:levWonKey];
            }
            
#ifdef EDITOR
            levelEnabled |= (LEVEL_SELECT_MODE_EDITOR == self.mode);
#endif
            
#define BUTTON_FADETO_DURATION (0.3)
#define LABELS_FADETO_DURATION (0.8)
            
            
            NSString *buttonText = levelEnabled ? [NSString stringWithFormat:@"%d", levelNumber] : @"?";
            
            CCSprite *normalSprite = [CCSprite spriteWithFile:@"levelSelectButtonBase.png"];
            CCLabelTTF *label = [CCLabelTTF labelWithString:buttonText fontName:@"Marker Felt" fontSize:48];
            label.position = ccp(normalSprite.contentSize.width * 0.5, normalSprite.contentSize.height * 0.7);
            label.color = UI_COLOR_GREY;
            [normalSprite addChild:label];
            
            label.opacity = 0;
            float labelNewOpacity = levelEnabled ? DEFAULT_OPACITY : DEFAULT_OPACITY_DISABLED;
            CCFadeTo *labelFadeTo = [CCFadeTo actionWithDuration:LABELS_FADETO_DURATION opacity:labelNewOpacity];
            [label runAction:labelFadeTo];

            
            CCSprite *selectedSprite = [CCSprite spriteWithFile:@"levelSelectButtonBase.png"];
            CCLabelTTF *label2 = [CCLabelTTF labelWithString:buttonText fontName:@"Marker Felt" fontSize:48];
            label2.position = ccp(selectedSprite.contentSize.width * 0.5, selectedSprite.contentSize.height * 0.7);
            label2.color = UI_COLOR_GREY;
            [selectedSprite addChild:label2];
            label2.opacity = 0;
            float label2NewOpacity = levelEnabled ? DEFAULT_OPACITY : DEFAULT_OPACITY_DISABLED;
            CCFadeTo *label2FadeTo = [CCFadeTo actionWithDuration:LABELS_FADETO_DURATION opacity:label2NewOpacity];
            [label2 runAction:label2FadeTo];
            
            CCMenuItemSprite *button;
            if (levelEnabled) {
                button = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector: @selector(buttonPressed:)];
            } else {
                button = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:nil selector:nil];
            }
            
            button.color = flowerColors[ ( buttonIndex + 2 * row ) % 5 ];
            button.tag = levelNumber;
            button.opacity = 0;
            float buttonNewOpacity = levelEnabled ? DEFAULT_OPACITY : DEFAULT_OPACITY_DISABLED;
            CCFadeTo *buttonFadeTo = [CCFadeTo actionWithDuration:BUTTON_FADETO_DURATION opacity:buttonNewOpacity];
            [button runAction:buttonFadeTo];

            
            NSString *starsCollectedKey = [NSString stringWithFormat:@"starsUnlockedInPack%dLevel%d", 1, levelNumber];
            int starsUnlocked = [defaults integerForKey:starsCollectedKey];
                        
            for (int starsI = 1; starsI <= 3; starsI++ )
            {
                CCSprite *starFrame = [CCSprite spriteWithFile:@"starFrameBase.png"];
                starFrame.position = ccp(button.contentSize.width * ( 0.165 + 0.33 * ( starsI - 1 ) ), button.contentSize.height * 0.165);
                starFrame.color = UI_COLOR_GREY;
                starFrame.scale = 0.45;
                starFrame.opacity = levelEnabled ? DEFAULT_OPACITY : DEFAULT_OPACITY_DISABLED;
                [button addChild:starFrame];
                
                if (starsI <= starsUnlocked) {
                    CCSprite *star = [CCSprite spriteWithFile:@"starBase.png"];
                    star.color = SIGNS_COLOR_ORANGE;
                    star.position = ccp(starFrame.contentSize.width / 2., starFrame.contentSize.height / 2.);
                    [starFrame addChild:star];
                    star.opacity = 0;
                    float starNewOpacity = levelEnabled ? DEFAULT_OPACITY : DEFAULT_OPACITY_DISABLED;
                    CCFadeTo *starFadeTo = [CCFadeTo actionWithDuration:LABELS_FADETO_DURATION opacity:starNewOpacity];
                    [star runAction:starFadeTo];
                }
            }
            
            [menuItems addObject:button];
            
            if ( ( buttonIndex + 1 ) % RAWS_COUNT == 0) {
                CCMenu *menu = [CCMenu menuWithArray:menuItems];
                [menu alignItemsHorizontallyWithPadding:59];
                [menu setPosition:ccp( WIN_SIZE.width / 2.0 + 15, WIN_SIZE.height * ( 0.9 - 0.2 * row ) )];
                row++;
                [self addChild:menu];
                [menuItems removeAllObjects];
            }
        }        
    }
    return self;
}

- (void)buttonPressed:(CCNode *)button
{
    
    //TODO: add real pack number here
    int packNumber = 1;

    
    CCLayer<LevelSelectProtocol> *newLayer;
    if (self.mode == LEVEL_SELECT_MODE_EDITOR)
    {
        newLayer = [EditorLayer node];
    }
    else
    {
        newLayer = [GameLayer node];
    }
    
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];
    newLayer.currentLevel = button.tag;
    newLayer.currentPack = packNumber;
    NSString *levelName = [NSString stringWithFormat:@"level%d_%d", packNumber, button.tag];
    NSDictionary *level = [newLayer loadLevel:levelName];
    [newLayer parseLevel:level];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

@end

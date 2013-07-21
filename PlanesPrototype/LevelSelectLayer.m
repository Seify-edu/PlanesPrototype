//
//  LevelSelectLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 11.02.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "MainMenuLayer.h"
#import "Constants.h"

@implementation LevelSelectLayer

+(CCScene *) sceneWithNextScene:(id)nextScene
{
	CCScene *scene = [CCScene node];
    
	LevelSelectLayer *lsl = [LevelSelectLayer node];
    lsl.nextScene = nextScene;
	[scene addChild: lsl];
    
	return scene;
}

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
    if (self = [super init])
    {
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
        bg.position = ccp(self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
//#define COLUMNS_COUNT 2
#define RAWS_COUNT 5
#define LEVELS_IN_PACK 20
        
        int row = 0;
        
        for (int i = 0; i < LEVELS_IN_PACK; i++) {
            
            NSMutableArray *menuItems;
            
            if ((i % RAWS_COUNT) == 0) {
                menuItems = [NSMutableArray array];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            BOOL levelEnabled = YES; // first level avaible ever
            if (i > 0) {
                NSString *levWonKey = [NSString stringWithFormat:@"pack%dlevel%dWon", 1, (i - 1 ) ];
                levelEnabled = [defaults boolForKey:levWonKey];
            }
            
            NSString *buttonText = levelEnabled ? [NSString stringWithFormat:@"%d", i + 1] : @"?";
            CCMenuItemSprite *button = [self createButtonWithNormalSprite:@"levelSelectButtonBase.png"
                                                           selectedSprite:@"levelSelectButtonBase.png"
                                                                     Text:buttonText
                                                                 Selector:@selector(buttonPressed:)];
            
            button.color = flowerColors[ ( i + 2 * row ) % 5 ];
            button.opacity = DEFAULT_OPACITY;
            button.tag = i + 1;
            
            NSString *key = [NSString stringWithFormat:@"starsUnlockedInPack%dLevel%d", 0, i];
            int starsUnlocked = [defaults integerForKey:key];
                        
            for (int starsI = 1; starsI <= 3; starsI++ )
            {
                CCSprite *starFrame = [CCSprite spriteWithFile:@"starFrameBase.png"];
                starFrame.position = ccp(button.contentSize.width * ( 0.165 + 0.33 * ( starsI - 1 ) ), button.contentSize.height * 0.165);
                starFrame.color = UI_COLOR_GREY;
                starFrame.scale = 0.45;
                starFrame.opacity = DEFAULT_OPACITY;
                [button addChild:starFrame];
                
                if (starsI <= starsUnlocked) {
                    CCSprite *star = [CCSprite spriteWithFile:@"starBase.png"];
                    star.color = SIGNS_COLOR_ORANGE;
                    star.position = ccp(starFrame.contentSize.width / 2., starFrame.contentSize.height / 2.);
                    star.opacity = DEFAULT_OPACITY;
                    [starFrame addChild:star];
                }
            }
            
            [menuItems addObject:button];
            
            if ( ( i + 1 ) % RAWS_COUNT == 0) {
                CCMenu *menu = [CCMenu menuWithArray:menuItems];
                [menu alignItemsHorizontallyWithPadding:59];
                [menu setPosition:ccp( WIN_SIZE.width / 2.0, WIN_SIZE.height * ( 0.8 - 0.2 * row ) - 15)];
                row++;
                [self addChild:menu];
                [menuItems removeAllObjects];
            }
        }
                
        CCMenuItemSprite *backButton = [self createButtonWithNormalSprite:@"flowerBase.png"
                                                           selectedSprite:@"flowerBase.png"
                                                                     Text:@"<-"
                                                                 Selector:@selector(backPressed)];
        
        backButton.color = flowerColors[ rand() % 5 ];
        backButton.opacity = DEFAULT_OPACITY;
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
		[backMenu alignItemsHorizontallyWithPadding:20];
		[backMenu setPosition:ccp( WIN_SIZE.width * 0.1, WIN_SIZE.height * 0.1)];

        [self addChild:backMenu];
        
        self.currentPageNumber = 1;
        [self updatePageNumber];
        
    }
    return self;
}

- (void)buttonPressed:(CCNode *)button
{
    NSLog(@"%@ : %@ button = %@", self, NSStringFromSelector(_cmd), button);
    
    id nextLayer = [self.nextScene getChildByTag:0];
    NSString *levelName = [NSString stringWithFormat:@"level%d_%d", self.currentPageNumber, button.tag];
    NSDictionary *level = [nextLayer loadLevel:levelName];
    [nextLayer parseLevel:level];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:self.nextScene withColor:ccWHITE]];
    self.nextScene = nil;
}

- (void)updatePageNumber
{
    [self removeChild:self.pageMenu cleanup:YES];
    
    CCLabelTTF *currentPageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", self.currentPageNumber] fontName:@"Marker Felt"  fontSize:64];
    CCMenuItemLabel *currentPage = [CCMenuItemLabel itemWithLabel:currentPageLabel];
    CCLabelTTF *leftArrowLabel = [CCLabelTTF labelWithString:@"<--" fontName:@"Marker Felt"  fontSize:64];
    CCMenuItemFont *leftArrow = [CCMenuItemFont itemWithLabel:leftArrowLabel target:self selector:@selector(leftPressed)];
    CCLabelTTF *rightArrowLabel = [CCLabelTTF labelWithString:@"-->" fontName:@"Marker Felt"  fontSize:64];
    CCMenuItemFont *rightArrow = [CCMenuItemFont itemWithLabel:rightArrowLabel target:self selector:@selector(rightPressed)];
    self.pageMenu = [CCMenu menuWithItems:leftArrow, currentPage, rightArrow, nil];
    [self.pageMenu alignItemsHorizontallyWithPadding:50];
    self.pageMenu.position = ccp(WIN_SIZE.width * 0.5, WIN_SIZE.height * 0.9);
    [self addChild:self.pageMenu];
}


- (void)leftPressed
{
    self.currentPageNumber = MAX(self.currentPageNumber - 1, 1);
    [self updatePageNumber];
}

- (void)rightPressed
{
    self.currentPageNumber++;
    [self updatePageNumber];
}



- (void)backPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
    self.nextScene = nil;
}

@end

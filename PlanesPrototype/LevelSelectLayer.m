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
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:64];
    label.position = ccp(normalSprite.contentSize.width * 0.5, normalSprite.contentSize.height * 0.5);
    [normalSprite addChild:label];
    
    CCSprite *selectedSprite = [CCSprite spriteWithFile:selS];
    CCLabelTTF *label2 = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:64];
    label2.position = ccp(selectedSprite.contentSize.width * 0.5, selectedSprite.contentSize.height * 0.5);
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
        
//        CCMenu *menu = nil;
//        NSMutableArray *menuItems = nil;
        int row = 0;
        
        for (int i = 0; i < LEVELS_IN_PACK; i++) {
            
            NSMutableArray *menuItems;
            
            if ((i % RAWS_COUNT) == 0) {
                menuItems = [NSMutableArray array];
            }
            CCMenuItemSprite *button = [self createButtonWithNormalSprite:@"levelSelectButtonBase.png"
                                                           selectedSprite:@"levelSelectButtonBase.png"
                                                                     Text:[NSString stringWithFormat:@"%d", i + 1]
                                                                 Selector:@selector(buttonPressed:)];
            
            button.color = FLOWERS_COLOR_GREEN;
            button.opacity = DEFAULT_OPACITY;
            button.tag = i + 1;
            [menuItems addObject:button];
            
            if ( ( i + 1 ) % RAWS_COUNT == 0) {
                CCMenu *menu = [CCMenu menuWithArray:menuItems];
                [menu alignItemsHorizontallyWithPadding:50];
                [menu setPosition:ccp( WIN_SIZE.width / 2.0, WIN_SIZE.height * ( 0.8 - 0.2 * row ) )];
                row++;
                [self addChild:menu];
                [menuItems removeAllObjects];
            }
        }
        
//        NSMutableArray *menuItems = [NSMutableArray array];
//        for (int j = 0; j < 5; j++) {
//            CCMenuItemSprite *button = [self createButtonWithNormalSprite:@"levelSelectButtonBase.png"
//                                                           selectedSprite:@"levelSelectButtonBase.png"
//                                                                     Text:[NSString stringWithFormat:@"%d", j + 1]
//                                                                 Selector:@selector(buttonPressed:)];
//            button.color = FLOWERS_COLOR_GREEN;
//            button.opacity = DEFAULT_OPACITY;
//            button.tag = j + 1;
//            [menuItems addObject:button];
//        }
        
//		CCMenu *menu = [CCMenu menuWithArray:menuItems];
//		[menu alignItemsHorizontallyWithPadding:20];
//		[menu setPosition:ccp( WIN_SIZE.width / 2.0, WIN_SIZE.height * 0.7)];
//		
//        NSMutableArray *menuItems2 = [NSMutableArray array];
//        for (int j = 5; j < 10; j++) {
//            CCMenuItemSprite *button = [self createButtonWithNormalSprite:@"levelSelectButtonBase.png"
//                                                           selectedSprite:@"levelSelectButtonBase.png"
//                                                                     Text:[NSString stringWithFormat:@"%d", j + 1]
//                                                                 Selector:@selector(buttonPressed:)];
//            button.color = FLOWERS_COLOR_GREEN;
//            button.opacity = DEFAULT_OPACITY;
//            button.tag = j + 1;
//            [menuItems2 addObject:button];
//        }
//        
//		CCMenu *menu2 = [CCMenu menuWithArray:menuItems2];
//		[menu2 alignItemsHorizontallyWithPadding:20];
//		[menu2 setPosition:ccp( WIN_SIZE.width / 2.0, WIN_SIZE.height * 0.3)];
		
        
                
        CCMenuItemSprite *backButton = [self createButtonWithNormalSprite:@"flowerBase.png"
                                                           selectedSprite:@"flowerBase.png"
                                                                     Text:@"<-"
                                                                 Selector:@selector(backPressed)];
        backButton.color = FLOWERS_COLOR_PURPLE;
        backButton.opacity = DEFAULT_OPACITY;
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
		[backMenu alignItemsHorizontallyWithPadding:20];
		[backMenu setPosition:ccp( WIN_SIZE.width * 0.1, WIN_SIZE.height * 0.1)];

        [self addChild:backMenu];
        
        self.currentPageNumber = 1;
        [self updatePageNumber];
        
//        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
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

//
//  HUDLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 27.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"
#import "Constants.h"
#import "cocos2d.h"

@implementation HUDLayer

- (id)init
{
    if (self = [super init])
    {
        [self recreateInterface];
    }
    
    return self;
}

- (void)updateResources
{
    [self recreateInterface];
}

- (void)recreateInterface
{
    
    [self removeAllChildrenWithCleanup:YES];
    
    int resType1 = [self.delegate getNumberOfResource:RESOURCE_TYPE_1];
    int resType2 = [self.delegate getNumberOfResource:RESOURCE_TYPE_2];
    int resType3 = [self.delegate getNumberOfResource:RESOURCE_TYPE_3];
    int resType4 = [self.delegate getNumberOfResource:RESOURCE_TYPE_4];
    int resType5 = [self.delegate getNumberOfResource:RESOURCE_TYPE_5];
    
    int totalResources = resType1 + resType2 + resType3 + resType4 + resType5;
    
    for (int i = 0; i < totalResources; i++) {
        CCSprite *cell = [CCSprite spriteWithFile:@"energySegmentFrameBase.png"];
        cell.color = UI_COLOR_GREY;
        cell.position = ccp( WIN_SIZE.width * ( 0.07 + i * 0.03 ), WIN_SIZE.height * ( 0.95 - ( i % 2) * 0.02 ) );
        [self addChild:cell];
        
        ccColor3B energyColor;
        if (i < resType1) energyColor = flowerColors[0];
        else if (i < resType1 + resType2) energyColor = flowerColors[1];
        else if (i < resType1 + resType2 + resType3) energyColor = flowerColors[2];
        else if (i < resType1 + resType2 + resType3 + resType4) energyColor = flowerColors[3];
        else energyColor = flowerColors[4];
        
        CCSprite *energyBar = [CCSprite spriteWithFile:@"energySegmentCellBase.png"];
        energyBar.color = energyColor;
        energyBar.position = ccp( cell.contentSize.width/2., cell.contentSize.height/2. );
        energyBar.opacity = DEFAULT_OPACITY;
        [cell addChild:energyBar];
    }
    
    
    CCSprite *pauseButtonUnpressed = [CCSprite spriteWithFile:@"pauseButtonBase.png"];
    CCSprite *pauseButtonPressed = [CCSprite spriteWithFile:@"pauseButtonBase.png"];
    pauseButtonPressed.color = pauseButtonUnpressed.color = UI_COLOR_GREY;
    
    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemWithNormalSprite:pauseButtonUnpressed
                                                            selectedSprite:pauseButtonPressed
                                                                    target:self
                                                                  selector:@selector(pauseButtonPressed)];
    CCMenu *pauseMenu = [CCMenu menuWithItems:pauseButton, nil];
    pauseMenu.position = ccp( WIN_SIZE.width * 0.95, WIN_SIZE.height * 0.95);
    [self addChild:pauseMenu];
}

- (void)pauseButtonPressed
{
    [self.delegate pauseButtonPressed];
}

@end



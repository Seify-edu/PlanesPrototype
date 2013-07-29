//
//  HudNode.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HudNode.h"

@implementation HudNode

- (void)updateResources
{
    [self recreateInterface];
}

- (void)blinkEnergyBar
{
    if ([self.energyBar numberOfRunningActions] == 0)
    {
        CCBlink *blink = [CCBlink actionWithDuration:0.5 blinks:2];
        [self.energyBar runAction:blink];
    }
}

- (void)recreateStars
{
    [self.starsParent removeAllChildrenWithCleanup:YES];
    
    NSMutableArray *tempArrayStars = [NSMutableArray array];
    
    for (int i = 0; i < [self.delegate getStarsCollected]; i++)
    {
        CCSprite *starFrame = [CCSprite spriteWithFile:@"starFrameBase.png"];
        starFrame.color = UI_COLOR_GREY;
        starFrame.position = ccp(WIN_SIZE.width * (0.44 + 0.08 * i), WIN_SIZE.height * 0.95);
        [self.starsParent addChild:starFrame];
        
        CCSprite *star = [CCSprite spriteWithFile:@"starBase.png"];
        star.color = SIGNS_COLOR_ORANGE;
        star.opacity = DEFAULT_OPACITY;
        star.position = ccp( starFrame.contentSize.width/2. , starFrame.contentSize.height/2. );
        [starFrame addChild:star];
        
        [tempArrayStars addObject:starFrame];
    }
    
    self.stars = [NSArray arrayWithArray:tempArrayStars];
}

- (void)recreateInterface
{
    [self removeAllChildrenWithCleanup:YES];
    self.energyBars = nil;
    self.stars = nil;
    
    // create energy bars
    self.energyBar = [CCNode node];
    [self addChild: self.energyBar];
    
    int resType1 = [self.delegate getNumberOfResource:RESOURCE_TYPE_PINK];
    int resType2 = [self.delegate getNumberOfResource:RESOURCE_TYPE_GREEN];
    int resType3 = [self.delegate getNumberOfResource:RESOURCE_TYPE_BLUE];
    int resType4 = [self.delegate getNumberOfResource:RESOURCE_TYPE_PURPLE];
    int resType5 = [self.delegate getNumberOfResource:RESOURCE_TYPE_YELLOW];
    
    int totalResources = resType1 + resType2 + resType3 + resType4 + resType5;
    
    NSMutableArray *tempArrayEnergy = [NSMutableArray array];
    
    for (int i = 0; i < totalResources; i++)
    {
        EnergyIndicator *indicator = [EnergyIndicator node];
        indicator.position = ccp( WIN_SIZE.width * ( 0.07 + i * 0.03 ), WIN_SIZE.height * ( 0.95 - ( i % 2) * 0.02 ) );
        [self.energyBar addChild:indicator];
        
        if (i < resType1) indicator.resourceType = RESOURCE_TYPE_PINK;
        else if (i < resType1 + resType2) indicator.resourceType = RESOURCE_TYPE_GREEN;
        else if (i < resType1 + resType2 + resType3) indicator.resourceType = RESOURCE_TYPE_BLUE;
        else if (i < resType1 + resType2 + resType3 + resType4) indicator.resourceType = RESOURCE_TYPE_PURPLE;
        else indicator.resourceType = RESOURCE_TYPE_YELLOW;
                
        [tempArrayEnergy addObject:indicator];
    }
    
    self.energyBars = [NSArray arrayWithArray:tempArrayEnergy];
    
    self.starsParent = [CCNode node];
    [self addChild:self.starsParent];

    [self recreateStars];
    
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

- (void)animateResourceRemoved:(int)removedRes ResourceAdded:(int)addedRes Duration:(float)duration
{
    EnergyIndicator *indicatorToHide;
    for (EnergyIndicator *indicator in self.energyBars)
    {
        if (indicator.resourceType == removedRes)
        {
            indicatorToHide = indicator;
        }
    }
    indicatorToHide.cell.opacity = 0;
    
    if (addedRes != UNDEFINED)
    {
        indicatorToHide.resourceType = addedRes;
        CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:duration opacity:DEFAULT_OPACITY];
        [indicatorToHide.cell runAction:fadeTo];
    }
};


- (void)pauseButtonPressed
{
    [self.delegate pauseButtonPressed];
}


@end

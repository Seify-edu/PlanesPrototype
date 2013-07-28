//
//  HudNode.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MapVertex.h"
#import "EnergyIndicator.h"

@protocol HudNodeDelegate
- (int)getNumberOfResource:(int)resourceID;
- (int)getStarsCollected;
- (void)pauseButtonPressed;
@end

@interface HudNode : CCNode {

}
- (void)recreateInterface;
- (void)recreateStars;
- (void)blinkEnergyBar;
- (void)animateResourceRemoved:(int)removedRes ResourceAdded:(int)addedRes Duration:(float)duration;

@property (assign) id<HudNodeDelegate> delegate;
@property (assign) CCNode *energyBar;
@property (assign) CCNode *starsParent;
@property (retain) NSArray *energyBars;
@property (retain) NSArray *stars;

@end

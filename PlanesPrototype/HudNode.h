//
//  HudNode.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapVertex.h"
#import "cocos2d.h"

@protocol HudNodeDelegate
- (int)getNumberOfResource:(int)resourceID;
- (int)getStarsCollected;
- (void)pauseButtonPressed;
@end

@interface HudNode : CCNode {

}
- (void)updateResources;
- (void)blinkEnergyBar;

@property (assign) id<HudNodeDelegate> delegate;
@property (assign) CCNode *energyBar;

@end

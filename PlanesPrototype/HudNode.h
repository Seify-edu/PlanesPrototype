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

@property (assign) id<HudNodeDelegate> delegate;
@property (assign) MapVertex *resIndicator1;
@property (assign) MapVertex *resIndicator2;
@property (assign) MapVertex *resIndicator3;
@property (assign) MapVertex *resIndicator4;
@property (assign) MapVertex *resIndicator5;

@end

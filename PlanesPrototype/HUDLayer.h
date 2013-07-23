//
//  HUDLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 27.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapVertex.h"
#import "cocos2d.h"

@protocol HUDLayerDelegate
- (int)getNumberOfResource:(int)resourceID;
- (void)pauseButtonPressed;
@end


@interface HUDLayer : CCLayer {

}

@property (assign) id<HUDLayerDelegate> delegate;
@property (assign) MapVertex *resIndicator1;
@property (assign) MapVertex *resIndicator2;
@property (assign) MapVertex *resIndicator3;
@property (assign) MapVertex *resIndicator4;
@property (assign) MapVertex *resIndicator5;


- (void)updateResources;

@end

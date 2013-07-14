//
//  Player.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 27.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MapVertex.h"

@interface Player : CCNode {
    
}

@property (assign) CCSprite *sprite;
@property (assign) MapVertex *currentVertex;
@property (assign) MapVertex *nextVertex;

@end

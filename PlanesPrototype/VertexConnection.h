//
//  VertexConnection.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 26.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MapVertex.h"

@interface VertexConnection : CCNode {
    
}

@property (assign) CCSprite *sprite;
@property (assign) MapVertex *startVertex;
@property (assign) MapVertex *endVertex;
@property int resourceType;

- (VertexConnection *)initWithStartVertex:(MapVertex *)startVertex EndVertex:(MapVertex *)endVertex ResourceType:(int)resourceType;
- (void)recalcPosition;

@end

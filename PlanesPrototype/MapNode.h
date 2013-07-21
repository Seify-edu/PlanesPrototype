//
//  MapNode.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 22.07.13.
//
//

#import "CCNode.h"
#import "cocos2d.h"
#import "Player.h"

@interface MapNode : CCNode

@property (retain) CCRenderTexture *renderTexture;
@property (assign) Player *player;

@end

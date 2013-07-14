//
//  GameLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapVertex.h"
#import "VertexConnection.h"
#import "Player.h"
#import "HUDLayer.h"
#import "cocos2d.h"
#import "Constants.h"
#import "MainMenuLayer.h"

enum {
    PLAYER_EASY_MOVE_TAG
};

@interface GameLayer : CCLayer <HUDLayerDelegate> {
    int resources[NUMBER_OF_RESOURCES];
}
@property (assign) CCNode *hud;

@property (assign) CCLabelTTF *console;

@property (assign) CCNode *map;
@property (retain) NSMutableArray *vertexes;
@property (retain) NSMutableArray *connections;

@property (assign) Player *player;

@property int flowersCollected;

//@property int resCount1;
//@property int resCount2;
//@property int resCount3;
//@property int resCount4;

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;
@end

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
#import "HudNode.h"
#import "cocos2d.h"
#import "Constants.h"
#import "MainMenuLayer.h"
#import "MapNode.h"
#import "Popup.h"

enum {
    PLAYER_EASY_MOVE_TAG
};

enum {
    GAME_STATE_PAUSE,
    GAME_STATE_RUNNING
};

@interface GameLayer : CCLayer <HudNodeDelegate> {
    int resources[NUMBER_OF_RESOURCES];
}

- (NSDictionary *)loadLevel:(NSString *)levelName;
- (void)parseLevel:(NSDictionary *)level;

@property (assign) HudNode *hud;
@property int state;

@property (assign) CCLabelTTF *console;

@property (assign) MapNode *map;
@property (retain) NSMutableArray *vertexes;
@property (retain) NSMutableArray *connections;

@property (assign) Player *player;

@property int flowersCollected;

@property int currentLevel;
@property int currentPack;

@property (retain) NSString *levelName;

@property (assign) Popup *popup;

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;
@end

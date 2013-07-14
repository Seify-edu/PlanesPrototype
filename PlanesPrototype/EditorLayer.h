//
//  EditorLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 30.01.13.
//
//

#import "cocos2d.h"
#import "MapVertex.h"
#import "VertexConnection.h"
#import <Foundation/Foundation.h>
#import "MainMenuLayer.h"
#import "Walkthrough.h"

enum
{
    STATE_RUNNING,
    STATE_WAIT_CONNECTION_VERTEX_1,
    STATE_WAIT_CONNECTION_VERTEX_2,
    STATE_WAIT_DELETE_VERTEX,
    STATE_WAIT_DELETE_CONNECTION,
    STATE_WAIT_COLOR_VERTEX,
    STATE_WAIT_COLOR_CONNECTION,
    STATE_WAIT_MODIFY_VERTEX,
    STATE_WAIT_MODIFY_CONNECTION
};

enum
{
    TAG_VERTEX_INDEX,
};

@interface EditorLayer : CCLayer
{
    int resources[NUMBER_OF_RESOURCES];
}
@property int state;
@property (assign) CCNode *map;
@property (assign) CCNode *mapVerts;
@property (assign) CCNode *mapConns;
@property (retain) NSMutableArray *vertexes;
@property (retain) NSMutableArray *connections;

@property (assign) MapVertex *newConnectionVertexStart;
@property (assign) MapVertex *newConnectionVertexEnd;

@property (assign) CCLabelTTF *console;

@property (assign) CCNode *popup;
@property (assign) CCMenuItemFont *redIndicator;
@property (assign) CCMenuItemFont *greenIndicator;
@property (assign) CCMenuItemFont *blueIndicator;
@property (assign) CCMenuItemFont *brownIndicator;
@property (assign) CCMenuItemFont *goldIndicator;

@property (retain) NSString *levelName;

+(CCScene *) scene;
@end

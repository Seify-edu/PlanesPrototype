//
//  LevelSelectLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 11.02.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum {LEVEL_SELECT_MODE_GAME, LEVEL_SELECT_MODE_EDITOR};

@protocol LevelSelectProtocol
    - (NSDictionary *)loadLevel:(NSString *)levelName;
    - (void)parseLevel:(NSDictionary *)level;
    @property int currentLevel;
    @property int currentPack;
@end

@interface LevelSelectLayer : CCLayer {
    
}
- (id)initWithMode:(int) mode;
@property int mode;
@end

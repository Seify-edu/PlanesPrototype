//
//  LevelSelectLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 11.02.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol LevelSelectProtocol
    @property int currentLevel;
    @property int currentPack;
@end

@interface LevelSelectLayer : CCLayer {
    
}
@property (retain) id nextScene;
//@property (assign) id delegate;
@property (assign) CCMenu *pageMenu;
@property int currentPageNumber;
+(CCScene *) sceneWithNextScene:(id)nextScene;
@end

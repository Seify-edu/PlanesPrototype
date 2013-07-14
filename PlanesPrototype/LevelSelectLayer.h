//
//  LevelSelectLayer.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 11.02.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelSelectLayer : CCLayer {
    
}
@property (retain) id nextScene;
@property (assign) id delegate;
@property (assign) CCMenu *pageMenu;
@property int currentPageNumber;
+(CCScene *) sceneWithNextScene:(id)nextScene;
@end

//
//  EnergyIndicator.h
//  Beegle
//
//  Created by Roman Smirnov on 28.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface EnergyIndicator : CCNode {
    
}
@property (assign) CCSprite *frame;
@property (assign) CCSprite *cell;
@property (nonatomic) int resourceType;
@end

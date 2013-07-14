//
//  MapVertex.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface MapVertex : CCNode {
    
}
@property (assign) CCSprite *pictogramm;
@property (assign) CCSprite *sprite;
@property (assign) CCLabelTTF *label;
@property int resourceType;
@property int pictogrammType;
@property int index;

- (id)initWithPosition:(CGPoint)position SpriteName:(NSString *)spriteName Value:(int)value;
- (id)initWithPosition:(CGPoint)position ResourceType:(int)resourceType;

- (void)recreateSprite;
- (void)recreatePictogramm;

@end

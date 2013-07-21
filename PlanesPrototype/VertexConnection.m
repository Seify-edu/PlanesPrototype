//
//  VertexConnection.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 26.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "VertexConnection.h"


@implementation VertexConnection

//- (VertexConnection *)initWithStartVertex:(MapVertex *)startVertex EndVertex:(MapVertex *)endVertex SpriteName:(NSString *)spriteName
- (VertexConnection *)initWithStartVertex:(MapVertex *)startVertex EndVertex:(MapVertex *)endVertex ResourceType:(int)resourceType;
{
    if (self = [super init])
    {
        self.startVertex = startVertex;
        self.endVertex = endVertex;
        self.resourceType = resourceType;
        
        [self recalcPosition];
        
    }
    return self;
}

- (void)recalcPosition
{
    if (self.sprite) {
        [self removeChild:self.sprite cleanup:YES];
    }
    
    self.position = ccpMidpoint(self.startVertex.position, self.endVertex.position);
        
    CGPoint vectorBetweenVetrexes = ccpSub(self.startVertex.position, self.endVertex.position);
    float distanceBetweenVetrexes = ccpLength(vectorBetweenVetrexes);

    self.sprite = [CCSprite spriteWithFile:@"roadBase.png" rect:CGRectMake(0, 0, distanceBetweenVetrexes, 32)];
//    self.sprite.opacity = DEFAULT_OPACITY;

    switch (self.resourceType) {
        case RESOURCE_TYPE_1:
        {
//            spriteName = @"redLink.png";
            self.sprite.color = flowerColors[FLOWERS_COLOR_PINK];
            break;
        }
            
        case RESOURCE_TYPE_2:
        {
//            spriteName = @"greenLink.png";
            self.sprite.color = flowerColors[FLOWERS_COLOR_GREEN];

            break;
        }
            
        case RESOURCE_TYPE_3:
        {
//            spriteName = @"blueLink.png";
            self.sprite.color = flowerColors[FLOWERS_COLOR_BLUE];
            
            break;
        }
            
        case RESOURCE_TYPE_4:
        {
//            spriteName = @"brownLink.png";
            self.sprite.color = flowerColors[FLOWERS_COLOR_PURPLE];
            
            break;
        }

        case RESOURCE_TYPE_5:
        {
//            spriteName = @"goldLink.png";
            self.sprite.color = flowerColors[FLOWERS_COLOR_YELLOW];

            break;
        }
            
        default:
            break;
    }

    ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [self.sprite.texture setTexParameters:&params];
    float angle = -CC_RADIANS_TO_DEGREES(ccpToAngle(vectorBetweenVetrexes));
    self.sprite.rotation = angle + 180.0f;
    [self addChild:self.sprite];
}


@end

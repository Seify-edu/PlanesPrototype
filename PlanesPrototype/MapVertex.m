//
//  MapVertex.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MapVertex.h"


@implementation MapVertex

- (id)initWithPosition:(CGPoint)position SpriteName:(NSString *)spriteName Value:(int)value
{
    if (self = [super init]) {
        self.position = position;
        self.sprite = [CCSprite spriteWithFile:spriteName];
		self.label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", value] fontName:@"Marker Felt" fontSize:64];
        self.label.color = ccBLUE;
		self.label.position =  ccp( self.sprite.contentSize.width / 2.0 , self.sprite.contentSize.height / 2.0 );
		[self.sprite addChild: self.label];
        [self addChild:self.sprite];
    }
    return self;
}

- (void)recreatePictogramm
{
    if (self.pictogramm){
        [self removeChild:self.pictogramm cleanup:YES];
        self.pictogramm = nil;
    }
    
    NSString *spriteName;
    switch (self.pictogrammType) {
        case MODIFIER_START:
        {
            spriteName = @"play.png";
            break;
        }

        case MODIFIER_END:
        {
//            spriteName = @"stop.png";
            spriteName = @"bee_home.png";
            break;
        }
            
        case MODIFIER_BONUS:
        {
//            spriteName = @"Flower.png";
            spriteName = @"drop.png";
            break;
        }
            
        default:
        {
            spriteName = nil;
            break;
        }
    }

    if (spriteName)
    {
        self.pictogramm = [CCSprite spriteWithFile:spriteName];
        [self addChild:self.pictogramm];
    }
}

- (void)recreateSprite
{
    if (self.sprite) {
        [self removeChild:self.sprite cleanup:YES];
        self.sprite = nil;
    }
    
    NSString *spriteName;
    switch (self.resourceType) {
        case RESOURCE_TYPE_1:
        {
//            spriteName = @"redVertex.png";
            spriteName = @"flower_red.png";
            break;
        }
            
        case RESOURCE_TYPE_2:
        {
//            spriteName = @"greenVertex.png";
            spriteName = @"flower_green.png";
            break;
        }
            
        case RESOURCE_TYPE_3:
        {
//            spriteName = @"blueVertex.png";
            spriteName = @"flower_blue.png";
            break;
        }
            
        case RESOURCE_TYPE_4:
        {
//            spriteName = @"brownVertex.png";
            spriteName = @"flower_brown.png";
            break;
        }
            
        case RESOURCE_TYPE_5:
        {
//            spriteName = @"goldVertex.png";
            spriteName = @"flower_yellow.png";
            break;
        }
            
        default:
            break;
    }
    NSAssert(spriteName, @"file not found");
    self.sprite = [CCSprite spriteWithFile:spriteName];
    [self addChild:self.sprite];
}

- (id)initWithPosition:(CGPoint)position ResourceType:(int)resourceType
{
    
    if (self = [super init])
    {
        self.position = position;
        self.resourceType = resourceType;
        
        [self recreateSprite];
    }
    return self;
}

@end

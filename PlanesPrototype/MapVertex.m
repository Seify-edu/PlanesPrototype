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
#ifdef EDITOR
            self.pictogramm = [CCSprite spriteWithFile:@"bee.png"];
#endif
            break;
        }

        case MODIFIER_END:
        {
            CCSprite *houseBody = [CCSprite spriteWithFile:@"homeBodyBase.png"];
            houseBody.position = ccp( 0, 16 );
            houseBody.color = SIGNS_COLOR_ORANGE;
            CCSprite *houseEntrance = [CCSprite spriteWithFile:@"homeEnterBase.png"];
            houseEntrance.color = flowerColors[FLOWERS_COLOR_YELLOW];
            houseEntrance.position = ccp(houseBody.contentSize.width / 2., houseBody.contentSize.height / 2. );
            [houseBody addChild:houseEntrance];
            self.pictogramm = houseBody;

            break;
        }
            
        case MODIFIER_BONUS:
        {
            self.pictogramm = [CCSprite spriteWithFile:@"starBase.png"];
            self.pictogramm.color = SIGNS_COLOR_ORANGE;
            self.pictogramm.opacity = DEFAULT_OPACITY;

            break;
        }
            
        default:
        {
            spriteName = nil;
            break;
        }
    }

    if (self.pictogramm)
    {
        [self addChild:self.pictogramm];
    }
}

- (void)recreateSprite
{
    if (self.sprite) {
        [self removeChild:self.sprite cleanup:YES];
        self.sprite = nil;
    }
    
    self.sprite = [CCSprite spriteWithFile:@"flowerBase.png"];
//    self.sprite.opacity = DEFAULT_OPACITY;
    
    switch (self.resourceType) {
        case RESOURCE_TYPE_PINK:
        {
            self.sprite.color = flowerColors[FLOWERS_COLOR_PINK];
            break;
        }
            
        case RESOURCE_TYPE_GREEN:
        {
            self.sprite.color = flowerColors[FLOWERS_COLOR_GREEN];
            break;
        }
            
        case RESOURCE_TYPE_BLUE:
        {
            self.sprite.color = flowerColors[FLOWERS_COLOR_BLUE];
            break;
        }
            
        case RESOURCE_TYPE_PURPLE:
        {
            self.sprite.color = flowerColors[FLOWERS_COLOR_PURPLE];

            break;
        }
            
        case RESOURCE_TYPE_YELLOW:
        {
            self.sprite.color = flowerColors[FLOWERS_COLOR_YELLOW];
            break;
        }
            
        default:
            break;
    }
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

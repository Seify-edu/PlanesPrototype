//
//  EnergyIndicator.m
//  Beegle
//
//  Created by Roman Smirnov on 28.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "EnergyIndicator.h"
#import "Constants.h"

@implementation EnergyIndicator


- (void)setResourceType:(int)newResourceType
{
    _resourceType = newResourceType;
    self.cell.color = flowerColors[newResourceType];
}

- (id)init
{
    if (self = [super init])
    {
        self.frame = [CCSprite spriteWithFile:@"energySegmentFrameBase.png"];
        self.frame.color = UI_COLOR_GREY;
        [self addChild:self.frame];
        
        self.cell = [CCSprite spriteWithFile:@"energySegmentCellBase.png"];
        self.cell.position = ccp( self.frame.contentSize.width/2., self.frame.contentSize.height/2. );
        self.cell.opacity = DEFAULT_OPACITY;
        [self.frame addChild:self.cell];
    }
    
    return self;
}

@end

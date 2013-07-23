//
//  Popup.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 23.07.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Popup.h"
#import "Constants.h"

@implementation Popup
- (id)init
{
    if (self = [super init])
    {
        self.position = ccp( WIN_SIZE.width / 2., WIN_SIZE.height / 2. );
        
        CCSprite *fadeSprite = [CCSprite spriteWithFile:@"background.png"];
        fadeSprite.opacity = 175;
        [self addChild:fadeSprite];
        
        CCSprite *popupBackground = [CCSprite spriteWithFile:@"popupBase.png"];
        popupBackground.opacity = DEFAULT_OPACITY;
        popupBackground.color = UI_COLOR_GREY;
        [self addChild:popupBackground];
    }
    return self;
}
@end

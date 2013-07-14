//
//  HUDLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 27.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

@implementation HUDLayer

- (id)init
{
    if (self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.resIndicator1 = [[[MapVertex alloc] initWithPosition:ccp(winSize.width * 0.07, winSize.height * 0.95) SpriteName:@"redVertex.png" Value:0] autorelease];
        self.resIndicator1.scale = 0.5;
        self.resIndicator2 = [[[MapVertex alloc] initWithPosition:ccp(winSize.width * 0.14, winSize.height * 0.95) SpriteName:@"greenVertex.png" Value:0] autorelease];
        self.resIndicator2.scale = 0.5;
        self.resIndicator3 = [[[MapVertex alloc] initWithPosition:ccp(winSize.width * 0.21, winSize.height * 0.95) SpriteName:@"blueVertex.png" Value:0] autorelease];
        self.resIndicator3.scale = 0.5;
        self.resIndicator4 = [[[MapVertex alloc] initWithPosition:ccp(winSize.width * 0.28, winSize.height * 0.95) SpriteName:@"brownVertex.png" Value:0] autorelease];
        self.resIndicator4.scale = 0.5;
        self.resIndicator5 = [[[MapVertex alloc] initWithPosition:ccp(winSize.width * 0.35, winSize.height * 0.95) SpriteName:@"goldVertex.png" Value:0] autorelease];
        self.resIndicator5.scale = 0.5;
        
        [self addChild:self.resIndicator1];
        [self addChild:self.resIndicator2];
        [self addChild:self.resIndicator3];
        [self addChild:self.resIndicator4];
        [self addChild:self.resIndicator5];
        
        [self updateResources];
    }
    
    return self;
}

- (void)updateResources
{
    [self.resIndicator1.label setString:[NSString stringWithFormat:@"%d", [self.delegate getNumberOfResource:RESOURCE_TYPE_1]]];
    [self.resIndicator2.label setString:[NSString stringWithFormat:@"%d", [self.delegate getNumberOfResource:RESOURCE_TYPE_2]]];
    [self.resIndicator3.label setString:[NSString stringWithFormat:@"%d", [self.delegate getNumberOfResource:RESOURCE_TYPE_3]]];
    [self.resIndicator4.label setString:[NSString stringWithFormat:@"%d", [self.delegate getNumberOfResource:RESOURCE_TYPE_4]]];
    [self.resIndicator5.label setString:[NSString stringWithFormat:@"%d", [self.delegate getNumberOfResource:RESOURCE_TYPE_5]]];
}

@end



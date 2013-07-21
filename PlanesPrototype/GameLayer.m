//
//  GameLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

@implementation GameLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    
	GameLayer *gl = [GameLayer node];
    gl.tag = 0;
	[scene addChild: gl];
    
    HUDLayer *hudl = [HUDLayer node];
    hudl.delegate = gl;
    gl.hud = hudl;
    [hudl updateResources];
    [scene addChild:hudl];
	
	return scene;
}

- (CCMenuItemSprite *)createButtonWithNormalSprite:(NSString *)normS selectedSprite:(NSString *)selS Text:(NSString *)text Selector:(SEL)sel;
{
    CCSprite *normalSprite = [CCSprite spriteWithFile:normS];
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:64];
    label.position = ccp(normalSprite.contentSize.width * 0.5, normalSprite.contentSize.height * 0.5);
    [normalSprite addChild:label];
    
    CCSprite *selectedSprite = [CCSprite spriteWithFile:selS];
    CCLabelTTF *label2 = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:64];
    label2.position = ccp(selectedSprite.contentSize.width * 0.5, selectedSprite.contentSize.height * 0.5);
    [selectedSprite addChild:label2];
    
    CCMenuItemSprite *sp = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector: sel];
    sp.scale = 0.7;
    
    return sp;
}

- (NSDictionary *)loadLevel:(NSString *)levelName
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *levelsDir = [documentsDirectory stringByAppendingPathComponent:@"levels/"];
//    NSString *levelFile = [levelsDir stringByAppendingPathComponent:levelName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:levelsDir])
//        NSLog(@"level file %@ does not exist", levelName);
//    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:levelFile];
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:levelName withExtension:@""];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        NSLog(@"level file %@ does not exist", levelName);
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfURL:url];
    
    return level;
}

- (void)parseLevel:(NSDictionary *)level
{
    //load resources
    NSArray *levelResources = [level objectForKey:@"levelResources"];
    if (!levelResources) {
        NSLog(@"%@ : %@ level parse error : no <levelResources> found", self, NSStringFromSelector(_cmd));
    }
    for (int i = 0; i < [levelResources count]; i++) {
        resources[i] = [[levelResources objectAtIndex:i] intValue];
    }
    [self.hud updateResources];
    
    //load vertexes
    NSArray *vertexes = [level objectForKey:@"vertexes"];
    if (!vertexes) {
        NSLog(@"%@ : %@ level parse error : no <vertexes> found", self, NSStringFromSelector(_cmd));
    }
    for (int i = 0; i < [vertexes count]; i++) {
        NSDictionary *vertDict = [vertexes objectAtIndex:i];
        int vertexResourceType = [[vertDict objectForKey:@"resourceType"] intValue];
        int pictogrammType = [[vertDict objectForKey:@"pictogrammType"] intValue];
        int index = [[vertDict objectForKey:@"index"] intValue];
        int positionX = [[vertDict objectForKey:@"position.x"] intValue];
        int positionY = [[vertDict objectForKey:@"position.y"] intValue];
     
        MapVertex *mv = [[[MapVertex alloc] initWithPosition:CGPointMake(positionX, positionY) ResourceType:vertexResourceType] autorelease];
        mv.index = index;
        mv.pictogrammType = pictogrammType;
//        if (mv.pictogrammType == MODIFIER_END) {
//            mv.sprite.visible = NO;
//        }
        [mv recreatePictogramm];
        [self.vertexes addObject:mv];
    }

    //load connections
    NSArray *connections = [level objectForKey:@"connections"];
    if (!connections) {
        NSLog(@"%@ : %@ level parse error : no <connections> found", self, NSStringFromSelector(_cmd));
    }
    for (int i = 0; i < [connections count]; i++) {
        NSDictionary * connDict = [connections objectAtIndex:i];
        int startVertexIndex = [[connDict objectForKey:@"startVertex.index"] intValue];
        int endVertexIndex = [[connDict objectForKey:@"endVertex.index"] intValue];
        int resourceType = [[connDict objectForKey:@"resourceType"] intValue];
        MapVertex *startVertex = [self.vertexes objectAtIndex:startVertexIndex];
        MapVertex *endVertex = [self.vertexes objectAtIndex:endVertexIndex];
        VertexConnection *vc = [[[VertexConnection alloc] initWithStartVertex:startVertex
                                                                    EndVertex:endVertex
                                                                 ResourceType:resourceType] autorelease];
        [self.connections addObject:vc];
    }
    
    //create player
    MapVertex *mvStart;
    for (MapVertex *mv in self.vertexes) {
        if (mv.pictogrammType == MODIFIER_START) {
            mvStart = mv;
            break;
        }
    }
    if (!mvStart) {
        NSLog(@"%@ : %@ level parse error : no start vertex found found", self, NSStringFromSelector(_cmd));
    }
    
    // remove start pictogramm
    mvStart.pictogrammType = MODIFIER_NONE;
    [mvStart recreatePictogramm];
    
    self.player = [Player node];
    self.player.sprite = [CCSprite spriteWithFile:@"bee.png"];
    self.player.currentVertex = mvStart;
    self.player.position = mvStart.position;
    self.map.position = ccp(WIN_SIZE.width / 2.0, WIN_SIZE.height / 2.0);
    [self.player addChild:self.player.sprite];
    
    for (VertexConnection *vc in self.connections) {
        [self.map addChild:vc];
    }
    
    for (MapVertex *mv in self.vertexes) {
        [self.map addChild:mv];
    }
    
    [self.map addChild:self.player];
    self.map.player = self.player;

    
//    TODO: uncomment this to center map to player
//    self.map.position = ccpSub(self.map.position, self.player.currentVertex.position);
    
//    CCRotateBy *rotateInYan = [CCRotateBy actionWithDuration:5.0 angle:360.0];
//    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotateInYan];
//    [self.player runAction:repeat];
    
//    [self updateAvaiblePathVisual];
    
}

- (id)init
{
	if (self = [super init])
    {        
//        CCSprite *bg = [CCSprite spriteWithFile:@"BlueSkyBg.jpg"];
        CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
        bg.position = ccp (self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        

        
        self.map = [MapNode node];
        self.vertexes = [NSMutableArray array];
        self.connections = [NSMutableArray array];

        [self addChild:self.map];
        

        self.map.position = ccp(WIN_SIZE.width / 2.0, WIN_SIZE.height / 2.0);
        self.map.position = ccpSub(self.map.position, self.player.currentVertex.position);
        
        CCMenuItemSprite *backButton = [self createButtonWithNormalSprite:@"flowerBase.png"
                                                           selectedSprite:@"flowerBase.png"
                                                                     Text:@"<-"
                                                                 Selector:@selector(backPressed)];
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
		[backMenu alignItemsHorizontallyWithPadding:20];
		[backMenu setPosition:ccp( WIN_SIZE.width * 0.1, WIN_SIZE.height * 0.1)];
		[self addChild:backMenu];
        
        [self initResources];
        
        self.console = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
        self.console.color = ccBLACK;
        [self addChild:self.console];
        self.console.position = ccp(self.contentSize.width / 2.0, self.contentSize.height * 0.7);

        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
	}
	return self;
}

- (void)initResources
{
    for (int i=0; i<NUMBER_OF_RESOURCES; i++) {
        resources[i] = 1;
    }
    
    [self.hud updateResources];
}

- (BOOL)point:(CGPoint)point insideMapVertex:(MapVertex *)mv
{
    CGRect testRect = CGRectMake(self.map.position.x + mv.position.x + mv.sprite.boundingBox.origin.x, self.map.position.y + mv.position.y + mv.sprite.boundingBox.origin.y, mv.sprite.boundingBox.size.width, mv.sprite.boundingBox.size.height);
    return CGRectContainsPoint(testRect, point);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    for (MapVertex *mv in self.vertexes)
    {
        if ([self point:location insideMapVertex:mv])
        {
            for (VertexConnection *vc in self.connections) {
                if (
                    (vc.endVertex == self.player.currentVertex && vc.startVertex == mv)
                    ||
                    (vc.startVertex == self.player.currentVertex && vc.endVertex == mv)
                    )
                {
                    BOOL playerMoving = ([self.player getActionByTag:PLAYER_EASY_MOVE_TAG] != nil);
                    
                    if (!playerMoving && resources[vc.resourceType] > 0)
                    {
                        float sc = [CCDirector sharedDirector].contentScaleFactor;
                        float timeToTravel = ccpDistance(vc.startVertex.position, vc.endVertex.position) / sc * 0.003;
                        CCMoveTo *movePlayer = [CCMoveTo actionWithDuration:timeToTravel position:mv.position];
                        CCEaseOut *easyMove = [CCEaseOut actionWithAction:movePlayer rate:2];
                        easyMove.tag = PLAYER_EASY_MOVE_TAG;
                        [self.player runAction:easyMove];
                        self.player.currentVertex = mv;

                        
                        resources[mv.resourceType] += 1;
                        resources[vc.resourceType] -= 1;
                        [self.hud updateResources];

//                        TODO: uncomment this to keep player in the center of the screen
//                        CGPoint mapOffset = ccpSub(self.player.position, mv.position);
//                        CGPoint newMapPosition = ccpAdd(self.map.position, mapOffset);
//                        CCMoveTo *moveMap = [CCMoveTo actionWithDuration:timeToTravel position:newMapPosition];
//                        [self.map runAction:moveMap];
                        
                        if (mv.pictogrammType == MODIFIER_END)
                        {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSString *levelWonKey = [NSString stringWithFormat:@"pack%dlevel%dWon", self.currentPack, self.currentLevel ];
                            [defaults setBool:YES forKey:levelWonKey];
                            NSString *starsCollectedKey = [NSString stringWithFormat:@"starsUnlockedInPack%dLevel%d", self.currentPack, self.currentLevel];
                            int starsCollectedBefore = [defaults integerForKey:starsCollectedKey];
                            if (self.flowersCollected > starsCollectedBefore) {
                                [defaults setInteger:self.flowersCollected forKey:starsCollectedKey];
                            }
                            [defaults synchronize];
                            
                            [self performSelector:@selector(postConsoleMessage:) withObject:@"You Won!" afterDelay:(NSTimeInterval)timeToTravel];
                        } else {
                            BOOL cannotMove = YES;
                            for (VertexConnection *vc2 in self.connections) {
                                if (vc2.startVertex == mv || vc2.endVertex == mv)
                                {
                                    if (resources[vc2.resourceType] > 0) {
                                        cannotMove = NO;
                                        break;
                                    }
                                }
                            }
                            if (cannotMove) {
                                [self performSelector:@selector(postConsoleMessage:) withObject:@"You Lose!" afterDelay:(NSTimeInterval)timeToTravel];
                            }

                            BOOL flowerCollected = (mv.pictogrammType == MODIFIER_BONUS);
                            if (flowerCollected) {
                                [self performSelector:@selector(collectFlowerFromVertex:) withObject:mv afterDelay:(NSTimeInterval)timeToTravel];
                            }
                            
//                            [self performSelector:@selector(updateAvaiblePathVisual) withObject:nil afterDelay:(NSTimeInterval)timeToTravel];
                        }
                    }
                    else
                    {
                        //TODO: play action with resource indicators
                        
//                        CCScaleTo *scaleHUD = [CCScaleTo actionWithDuration:0.1 scale:1.2];
//                        [self.hud runAction:scaleHUD];
                    }

                    
                    break;
                }
            }
            
            return YES;
        }
    }
    return NO;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
}

- (void) collectFlowerFromVertex:(MapVertex *)mv
{
    mv.pictogrammType = MODIFIER_NONE;
    [mv recreatePictogramm];
    self.flowersCollected = self.flowersCollected + 1;
//    CCSprite *flower = [CCSprite spriteWithFile:@"Flower.png"];
    CCSprite *flower = [CCSprite spriteWithFile:@"starBase.png"];
    flower.color = SIGNS_COLOR_ORANGE;
    flower.opacity = DEFAULT_OPACITY;
    [self addChild:flower];
    flower.position = ccp(WIN_SIZE.width * (0.7 + 0.08 * self.flowersCollected), WIN_SIZE.height * 0.92);
}

- (void)updateAvaiblePathVisual
{
    
    for (VertexConnection *vc in self.connections)
    {
        vc.sprite.opacity = 255.0f;
            if (resources[vc.resourceType] <= 0) {
                vc.sprite.opacity = 122.0f;
            }
    }
}

- (void)backPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
}

- (void)dealloc
{
    self.vertexes = nil;
    self.connections = nil;
    [super dealloc];
}

//#pragma mark - Drawing
//
//-(void) visit
//{
//	// quick return if not visible. children won't be drawn.
//	if (!visible_)
//		return;
//    
//	kmGLPushMatrix();
//    
//	if ( grid_ && grid_.active)
//		[grid_ beforeDraw];
//    
//	[self transform];
//    
//	if(children_) {
//        
//		[self sortAllChildren];
//        
//		ccArray *arrayData = children_->data;
//		NSUInteger i = 0;
//        
////		// draw children zOrder < 0
////		for( ; i < arrayData->num; i++ ) {
////			CCNode *child = arrayData->arr[i];
////			if ( [child zOrder] < 0 )
////				[child visit];
////			else
////				break;
////		}
//        
//		// self draw
//		[self draw];
//        
//		// draw children zOrder >= 0
//		for( ; i < arrayData->num; i++ ) {
//			CCNode *child =  arrayData->arr[i];
//            if (child != self.player.sprite){
//                [child visit];
//            }
//		}
//        
//	} else
//		[self draw];
//    
//	// reset for next frame
//	orderOfArrival_ = 0;
//    
//	if ( grid_ && grid_.active)
//		[grid_ afterDraw:self];
//    
//	kmGLPopMatrix();
//
//}
//
//- (void)draw
//{
//    [super draw];
////    [self.player.sprite draw];
//}

#pragma mark - Console

- (void)postConsoleMessage:(NSString *)message
{
    self.console.string = message;
}

- (void)clearConsole
{
    self.console.string = nil;
}

#pragma mark - HUDLayerDelegate protocol methods
- (int)getNumberOfResource:(int)resourceID
{
    return resources[resourceID];
}


@end

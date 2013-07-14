//
//  EditorLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 30.01.13.
//
//

#import "EditorLayer.h"

@interface EditorLayer()
{
    
}
@property (assign) MapVertex *vertexToMove;

@end

@implementation EditorLayer

+ (CCScene *) scene
{
	CCScene *scene = [CCScene node];
    
	EditorLayer *el = [EditorLayer node];
    el.tag = 0;
	[scene addChild: el];
    
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
    self.levelName = levelName;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *levelsDir = [documentsDirectory stringByAppendingPathComponent:@"levels/"];
    NSString *levelFile = [levelsDir stringByAppendingPathComponent:self.levelName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:levelsDir])
        NSLog(@"test level file does not exist");
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:levelFile];
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
    [self updateIndicators];
    
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
        [mv recreatePictogramm];
        [self.vertexes addObject:mv];
    }
    
    [self recalculateVertexIndexes];
    
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
    
    //placing elements on map
    for (VertexConnection *vc in self.connections) {
        [self.mapConns addChild:vc];
    }
    for (MapVertex *mv in self.vertexes) {
        [self.mapVerts addChild:mv];
    }
}



- (id)init
{
    if (self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"BlueSkyBg.jpg"];
        bg.position = ccp(self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
		[CCMenuItemFont setFontSize:28];
        
        CCMenuItemSprite *addVertexButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                                selectedSprite:@"greenVertex.png"
                                                                          Text:@"+V"
                                                                      Selector:@selector(addVertexPressed)];
        
        CCMenuItemSprite *addConnectionButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                                    selectedSprite:@"greenVertex.png"
                                                                              Text:@"+C"
                                                                          Selector:@selector(addConnectionPressed)];
        
        CCMenuItemSprite *deleteVertexButton = [self createButtonWithNormalSprite:@"redVertex.png"
                                                                   selectedSprite:@"redVertex.png"
                                                                             Text:@"-V"
                                                                         Selector:@selector(deleteVertexPressed)];
        
        CCMenuItemSprite *deleteConnectionButton = [self createButtonWithNormalSprite:@"redVertex.png"
                                                                   selectedSprite:@"redVertex.png"
                                                                             Text:@"-C"
                                                                         Selector:@selector(deleteConnectionPressed)];
        
        CCMenuItemSprite *colorVertexButton = [self createButtonWithNormalSprite:@"blueVertex.png"
                                                                   selectedSprite:@"blueVertex.png"
                                                                             Text:@"~V"
                                                                         Selector:@selector(colorVertexPressed)];
        
        CCMenuItemSprite *colorConnectionButton = [self createButtonWithNormalSprite:@"blueVertex.png"
                                                                       selectedSprite:@"blueVertex.png"
                                                                                 Text:@"~C"
                                                                             Selector:@selector(colorConnectionPressed)];
        
        CCMenuItemSprite *modifyVertexButton = [self createButtonWithNormalSprite:@"brownVertex.png"
                                                                  selectedSprite:@"brownVertex.png"
                                                                            Text:@">V"
                                                                        Selector:@selector(modifyVertexPressed)];
        
        CCMenuItemSprite *modifyConnectionButton = [self createButtonWithNormalSprite:@"brownVertex.png"
                                                                      selectedSprite:@"brownVertex.png"
                                                                                Text:@">C"
                                                                            Selector:@selector(modifyConnectionPressed)];
        
        CCMenuItemSprite *recourcesButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                                selectedSprite:@"greenVertex.png"
                                                                          Text:@"R"
                                                                      Selector:@selector(resourcesPressed)];
        
        
		CCMenu *menu = [CCMenu menuWithItems:addVertexButton, addConnectionButton, deleteVertexButton, deleteConnectionButton, colorVertexButton, colorConnectionButton, modifyVertexButton, modifyConnectionButton, recourcesButton, nil];
		[menu alignItemsHorizontallyWithPadding:20];
        CGSize size = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp( size.width / 2.0, size.height * 0.9)];
		

        
        CCMenuItemSprite *saveButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                                selectedSprite:@"greenVertex.png"
                                                                          Text:@"S"
                                                                      Selector:@selector(savePressed)];
        CCMenuItemSprite *testButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                           selectedSprite:@"greenVertex.png"
                                                                     Text:@"T"
                                                                 Selector:@selector(testPressed)];
        
        CCMenu *saveMenu = [CCMenu menuWithItems:saveButton, testButton, nil];
		[saveMenu alignItemsHorizontallyWithPadding:20];
		[saveMenu setPosition:ccp( WIN_SIZE.width * 0.85, WIN_SIZE.height * 0.1)];

        
        CCMenuItemSprite *backButton = [self createButtonWithNormalSprite:@"redVertex.png"
                                                           selectedSprite:@"redVertex.png"
                                                                     Text:@"<-"
                                                                 Selector:@selector(backPressed)];
        CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
		[backMenu alignItemsHorizontallyWithPadding:20];
		[backMenu setPosition:ccp( WIN_SIZE.width * 0.1, WIN_SIZE.height * 0.1)];
        
        self.map = [CCNode node];
        self.mapVerts = [CCNode node];
        self.mapConns = [CCNode node];
        [self.map addChild:self.mapConns];
        [self.map addChild:self.mapVerts];
        
        self.map.position = ccp(winSize.width / 2.0, winSize.height / 2.0);
        self.vertexes = [NSMutableArray array];
        self.connections = [NSMutableArray array];
        
        [self addChild:self.map];
        [self addChild:saveMenu];
        [self addChild:menu];
        [self addChild:backMenu];
        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
        
        self.state = STATE_RUNNING;
        
        self.console = [CCLabelTTF labelWithString:@">.." fontName:@"Marker Felt" fontSize:32];
        self.console.color = ccBLACK;
        [self addChild:self.console];
        self.console.position = ccp(self.contentSize.width / 2.0, self.contentSize.height * 0.1);
        
    }
    return self;
}

- (void)recalculateVertexIndexes
{
    for (MapVertex *mv in self.vertexes) {
        [mv removeChildByTag:TAG_VERTEX_INDEX cleanup:YES];
        mv.index = [self.vertexes indexOfObject:mv];
        NSString *indexName = [NSString stringWithFormat:@"%d", mv.index];
        CCLabelTTF *vertexIndex = [CCLabelTTF labelWithString:indexName fontName:@"Marker Felt" fontSize:24];
        vertexIndex.tag = TAG_VERTEX_INDEX;
        vertexIndex.position = ccp (mv.sprite.contentSize.width * 0.3, - mv.sprite.contentSize.height * 0.3);
        [mv addChild:vertexIndex];
    }
}

#pragma mark - Buttons handlers

- (void)addVertexPressed
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    MapVertex *mv = [[[MapVertex alloc] initWithPosition:ccp(-self.map.position.x + winSize.width / 2.0, -self.map.position.y + winSize.height / 2.0) ResourceType:RESOURCE_TYPE_1] autorelease];
    [self.mapVerts addChild:mv]; [self.vertexes addObject:mv];
    mv.index = [self.vertexes indexOfObject:mv];
    
    mv.resourceType = rand() % (RESOURCE_TYPE_5 + 1);
    [mv recreateSprite];
    
    [self recalculateVertexIndexes];
}

- (void)addConnectionPressed
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    if ([self.vertexes count] > 1) {
        self.state = STATE_WAIT_CONNECTION_VERTEX_1;
        [self.console setString:@"Press start vertex"];
    }
}

- (void)deleteConnectionPressed
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    
    if ([self.connections count] > 0) {
        self.state = STATE_WAIT_DELETE_CONNECTION;
        [self.console setString:@"Press connection to delete"];
    }
}

- (void)deleteVertexPressed
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    
    if ([self.vertexes count] > 0) {
        self.state = STATE_WAIT_DELETE_VERTEX;
        [self.console setString:@"Press vertex to delete"];
    }
}

- (void)colorVertexPressed
{
    if ([self.vertexes count] > 0) {
        self.state = STATE_WAIT_COLOR_VERTEX;
        [self.console setString:@"Press vertex to color"];
    }
}

- (void)colorConnectionPressed
{
    if ([self.connections count] > 0) {
        self.state = STATE_WAIT_COLOR_CONNECTION;
        [self.console setString:@"Press connection to color"];
    }
}

- (void)modifyVertexPressed
{
    if ([self.vertexes count] > 0) {
        self.state = STATE_WAIT_MODIFY_VERTEX;
        [self.console setString:@"Press vertex to modify"];
    }
}

- (void)modifyConnectionPressed
{
    if ([self.connections count] > 0) {

        NSLog(@"modifyConnectionPressed do nothing");
    }
}

- (void)resourcesPressed
{
    self.popup = [CCNode node];
    [self addChild:self.popup];
    self.popup.position = ccp(WIN_SIZE.width * 0.5, WIN_SIZE.height * 0.5);
    
    
    CCSprite *popupBg = [CCSprite spriteWithFile:@"popupBg.jpeg"];
    popupBg.scaleY = 2.5;
    popupBg.scaleX = 1.5;
    [self.popup addChild:popupBg];
    
    CCMenuItemSprite *redPlusButton = [self createButtonWithNormalSprite:@"redVertex.png"
                                                          selectedSprite:@"redVertex.png"
                                                                    Text:@"+"
                                                                Selector:@selector(redPlusPressed)];
    CCMenuItemSprite *redMinusButton = [self createButtonWithNormalSprite:@"redVertex.png"
                                                           selectedSprite:@"redVertex.png"
                                                                     Text:@"-"
                                                                 Selector:@selector(redMinusPressed)];
    self.redIndicator = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", resources[0]]];
    CCMenu *redMenu = [CCMenu menuWithItems:redMinusButton, self.redIndicator, redPlusButton, nil];
    [redMenu alignItemsHorizontallyWithPadding:20];
    [redMenu setPosition:ccp( 0, popupBg.contentSize.height * 0.6)];
    [self.popup addChild:redMenu];
    
    CCMenuItemSprite *greenPlusButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                            selectedSprite:@"greenVertex.png"
                                                                      Text:@"+"
                                                                  Selector:@selector(greenPlusPressed)];
    CCMenuItemSprite *greenMinusButton = [self createButtonWithNormalSprite:@"greenVertex.png"
                                                             selectedSprite:@"greenVertex.png"
                                                                       Text:@"-"
                                                                   Selector:@selector(greenMinusPressed)];
    self.greenIndicator = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", resources[1]]];
    CCMenu *greenMenu = [CCMenu menuWithItems:greenMinusButton, self.greenIndicator, greenPlusButton, nil];
    [greenMenu alignItemsHorizontallyWithPadding:20];
    [greenMenu setPosition:ccp( 0, popupBg.contentSize.height * 0.2)];
    [self.popup addChild:greenMenu];
    
    CCMenuItemSprite *bluePlusButton = [self createButtonWithNormalSprite:@"blueVertex.png"
                                                            selectedSprite:@"blueVertex.png"
                                                                      Text:@"+"
                                                                  Selector:@selector(bluePlusPressed)];
    CCMenuItemSprite *blueMinusButton = [self createButtonWithNormalSprite:@"blueVertex.png"
                                                             selectedSprite:@"blueVertex.png"
                                                                       Text:@"-"
                                                                   Selector:@selector(blueMinusPressed)];
    self.blueIndicator = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", resources[2]]];
    CCMenu *blueMenu = [CCMenu menuWithItems:blueMinusButton, self.blueIndicator, bluePlusButton, nil];
    [blueMenu alignItemsHorizontallyWithPadding:20];
    [blueMenu setPosition:ccp( 0, - popupBg.contentSize.height * 0.2)];
    [self.popup addChild:blueMenu];
    
    CCMenuItemSprite *brownPlusButton = [self createButtonWithNormalSprite:@"brownVertex.png"
                                                            selectedSprite:@"brownVertex.png"
                                                                      Text:@"+"
                                                                  Selector:@selector(brownPlusPressed)];
    CCMenuItemSprite *brownMinusButton = [self createButtonWithNormalSprite:@"brownVertex.png"
                                                             selectedSprite:@"brownVertex.png"
                                                                       Text:@"-"
                                                                   Selector:@selector(brownMinusPressed)];
    self.brownIndicator = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", resources[3]]];
    CCMenu *brownMenu = [CCMenu menuWithItems:brownMinusButton, self.brownIndicator, brownPlusButton, nil];
    [brownMenu alignItemsHorizontallyWithPadding:20];
    [brownMenu setPosition:ccp( 0, - popupBg.contentSize.height * 0.6)];
    [self.popup addChild:brownMenu];
    
    CCMenuItemSprite *goldPlusButton = [self createButtonWithNormalSprite:@"goldVertex.png"
                                                            selectedSprite:@"goldVertex.png"
                                                                      Text:@"+"
                                                                  Selector:@selector(goldPlusPressed)];
    CCMenuItemSprite *goldMinusButton = [self createButtonWithNormalSprite:@"goldVertex.png"
                                                             selectedSprite:@"goldVertex.png"
                                                                       Text:@"-"
                                                                   Selector:@selector(goldMinusPressed)];
    self.goldIndicator = [CCMenuItemFont itemWithString:[NSString stringWithFormat:@"%d", resources[4]]];
    CCMenu *goldMenu = [CCMenu menuWithItems:goldMinusButton, self.goldIndicator, goldPlusButton, nil];
    [goldMenu alignItemsHorizontallyWithPadding:20];
    [goldMenu setPosition:ccp( 0, - popupBg.contentSize.height * 1.0)];
    [self.popup addChild:goldMenu];
    
    CCMenuItemFont *closeB = [CCMenuItemFont itemWithString:@"Close" target:self selector:@selector(closePopupPressed)];
    CCMenu *closeMenu = [CCMenu menuWithItems:closeB, nil];
    [closeMenu alignItemsHorizontallyWithPadding:20];
    [closeMenu setPosition:ccp( popupBg.contentSize.width * 0.5, popupBg.contentSize.height * 1.0)];
    [self.popup addChild:closeMenu];
    
}

- (NSDictionary *)getLevel
{
    NSMutableDictionary *rootObj = [NSMutableDictionary dictionary];
    
    NSArray *levelResources = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:resources[0]],
                               [NSNumber numberWithInt:resources[1]],
                               [NSNumber numberWithInt:resources[2]],
                               [NSNumber numberWithInt:resources[3]],
                               [NSNumber numberWithInt:resources[4]],
                               nil];
    [rootObj setObject:levelResources forKey:@"levelResources"];
    
    NSMutableArray *vertexes = [NSMutableArray array];
    for (MapVertex *mv in self.vertexes) {
        NSMutableDictionary *mvdict = [NSMutableDictionary dictionary];
        [mvdict setObject:[NSNumber numberWithInt:mv.resourceType] forKey:@"resourceType"];
        [mvdict setObject:[NSNumber numberWithInt:mv.pictogrammType] forKey:@"pictogrammType"];
        [mvdict setObject:[NSNumber numberWithInt:mv.index] forKey:@"index"];
        [mvdict setObject:[NSNumber numberWithInt:mv.position.x + self.map.position.x - WIN_SIZE.width / 2.0] forKey:@"position.x"];
        [mvdict setObject:[NSNumber numberWithInt:mv.position.y + self.map.position.y - WIN_SIZE.height / 2.0] forKey:@"position.y"];
        [vertexes addObject:mvdict];
    }
    [rootObj setObject:vertexes forKey:@"vertexes"];
    
    NSMutableArray *connections = [NSMutableArray array];
    for (VertexConnection *vc in self.connections) {
        NSMutableDictionary *vcdict = [NSMutableDictionary dictionary];
        [vcdict setObject:[NSNumber numberWithInt:vc.startVertex.index] forKey:@"startVertex.index"];
        [vcdict setObject:[NSNumber numberWithInt:vc.endVertex.index] forKey:@"endVertex.index"];
        [vcdict setObject:[NSNumber numberWithInt:vc.resourceType] forKey:@"resourceType"];
        [connections addObject:vcdict];
    }
    [rootObj setObject:connections forKey:@"connections"];

    return rootObj;
}

- (void)saveLevel:(NSDictionary *)level
{
    NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *levelsDir = [documentsDirectory stringByAppendingPathComponent:@"levels/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:levelsDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:levelsDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    if (error) {
        NSLog(@"levels dir = %@", levelsDir);
        NSLog(@"error = %@", error);
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:levelsDir]) {
        NSLog(@"Failed to create levels dir");
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:self.levelName];
        [level writeToFile:appFile atomically:YES];
    } else {
        NSString *appFile = [levelsDir stringByAppendingPathComponent:self.levelName];
        [level writeToFile:appFile atomically:YES];
    }

}

- (void)savePressed
{
    //create plist or modify existent;
    NSDictionary *level = [self getLevel];
    
    //save plist to disk
    [self saveLevel:level];
}

- (void)testPressed
{
    
    MapVertex *startVertex;
    MapVertex *endVertex;
    
    for (MapVertex *mv in self.vertexes)
    {
        if (mv.pictogrammType == MODIFIER_START) {
            startVertex = mv;
        } else if (mv.pictogrammType == MODIFIER_END) {
            endVertex = mv;
        }
    }
    
    if (!startVertex) {
        NSLog(@"%@ : %@ no start vertex!", self, NSStringFromSelector(_cmd));
        return;
    }

    if (!endVertex) {
        NSLog(@"%@ : %@ no end vertex!", self, NSStringFromSelector(_cmd));
        return;
    }

    
    NSMutableArray *walkthroughs = [NSMutableArray array];
    for (VertexConnection *vc in self.connections) {
        if (vc.startVertex == startVertex || vc.endVertex == startVertex) {
            MapVertex *nextVertex;
            if (vc.startVertex == startVertex)
                nextVertex = vc.endVertex;
            else
                nextVertex = vc.startVertex;
            
            if (resources[vc.resourceType] > 0) {
                Walkthrough *wt = [[Walkthrough alloc] init];
                for (int i = 0; i < NUMBER_OF_RESOURCES; i++) {
                    wt->resources[i] = resources[i];
                }
                wt->resources[vc.resourceType]--;
                wt->resources[nextVertex.resourceType]++;
                wt.steps = [NSMutableArray array];
                [wt.steps addObject:startVertex];
                [wt.steps addObject:nextVertex];
                wt.stepsCounter = 2;
                
                wt.bonuses = [NSMutableArray array];
                if (startVertex.pictogrammType == MODIFIER_BONUS) {
                    [wt.bonuses addObject:startVertex];
                }
                if (nextVertex.pictogrammType == MODIFIER_BONUS) {
                    if (![wt.bonuses containsObject:nextVertex]) {
                        [wt.bonuses addObject:nextVertex];
                    }
                }
                
                if (nextVertex.pictogrammType == MODIFIER_END) {
                    wt.hasWon = YES;
                }
                
                if (!wt.hasWon) {
                    wt.hasLose = YES;
                    for (VertexConnection *vt2 in self.connections) {
                        if (vt2.startVertex == nextVertex || vt2.endVertex == nextVertex)
                        {
                            if (wt->resources[vt2.resourceType] > 0)
                                wt.hasLose = NO;
                        }
                    }
                }
                
                [walkthroughs addObject:wt];
            }
        }
    }
    
    
    NSMutableArray *wtToRemove = [NSMutableArray array];
    NSMutableArray *wtToAdd = [NSMutableArray array];
    
    
    for (int i = 0; i < 25; i++)
    {
        
//        NSLog(@"=======iteration %d=======", i);
    
    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasWon) continue;
        if (wt.hasLose) continue;
        
        MapVertex *currentVertex = [wt.steps lastObject];
        
        for (VertexConnection *vc in self.connections) {
            if (vc.startVertex == currentVertex || vc.endVertex == currentVertex) {
                MapVertex *nextVertex;
                if (vc.startVertex == currentVertex) {
                    nextVertex = vc.endVertex;
                }
                else {
                    nextVertex = vc.startVertex;
                }
                
                if (wt->resources[vc.resourceType] > 0) {
                    Walkthrough *newwt = [[Walkthrough alloc] init];
                    for (int i = 0; i < NUMBER_OF_RESOURCES; i++) {
                        newwt->resources[i] = wt->resources[i];
                    }
                    newwt->resources[vc.resourceType]--;
                    newwt->resources[nextVertex.resourceType]++;
                    newwt.steps = [NSMutableArray arrayWithArray: wt.steps];
                    [newwt.steps addObject:nextVertex];
                    newwt.stepsCounter = newwt.stepsCounter + 1;
                    
                    newwt.bonuses = [NSMutableArray arrayWithArray:wt.bonuses];
                    if (nextVertex.pictogrammType == MODIFIER_BONUS) {
                        if (![newwt.bonuses containsObject:nextVertex]) {
                            [newwt.bonuses addObject:nextVertex];
                        }
                    }

                    
                    
                    if (nextVertex.pictogrammType == MODIFIER_END) {
                        newwt.hasWon = YES;
                    }
                    
                    if (!newwt.hasWon) {
                        newwt.hasLose = YES;
                        for (VertexConnection *vt2 in self.connections) {
                            if (vt2.startVertex == nextVertex || vt2.endVertex == nextVertex)
                            {
                                if (newwt->resources[vt2.resourceType] > 0)
                                    newwt.hasLose = NO;
                            }
                        }
                    }
                                        
                    [wtToAdd addObject:newwt];
                }
            }
        }
        [wtToRemove addObject:wt];
    }
    
    [walkthroughs addObjectsFromArray:wtToAdd];
    [walkthroughs removeObjectsInArray:wtToRemove];
    [wtToAdd removeAllObjects];
    [wtToRemove removeAllObjects];
    }
    
    int winWithBonuses0 = 0;
    int winWithBonuses1 = 0;
    int winWithBonuses2 = 0;
    int winWithBonuses3 = 0;
    int lose = 0;
    int unfinished = 0;

    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasLose) {
            lose++;
        }
        else if (wt.hasWon) {
            if ([wt.bonuses count] == 0) {
                winWithBonuses0++;
            } else if ([wt.bonuses count] == 1) {
                winWithBonuses1++;
            } else if ([wt.bonuses count] == 2) {
                winWithBonuses2++;
            } else if ([wt.bonuses count] == 3) {
                winWithBonuses3++;
            } else {
                NSLog(@"Warning! too many bonuses collected");
            }
        }
        else {
            unfinished++;
        }
    }
    
    NSLog(@"winWithBonuses0 = %d", winWithBonuses0);
    NSLog(@"winWithBonuses1 = %d", winWithBonuses1);
    NSLog(@"winWithBonuses2 = %d", winWithBonuses2);
    NSLog(@"winWithBonuses3 = %d", winWithBonuses3);
    NSLog(@"lose = %d", lose);
    NSLog(@"unfinished = %d", unfinished);
    
    int printCounter = 0;

    int lengthCounter = INT_MAX;
    Walkthrough *bestWT = nil;
    
    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasWon == YES && wt.bonuses.count == 3 && [wt.steps count] < lengthCounter) {
            lengthCounter = [wt.steps count];
            bestWT = wt;
        }
    }
    
    NSLog(@"Shortest Win strategy with 3 bonuses:");
    NSLog(@"------------------");
        if (bestWT) {
            for (MapVertex *mv in bestWT.steps) {
                NSLog(@"step %d : vertex %d", [bestWT.steps indexOfObject:mv], mv.index);
            }
        }
    NSLog(@"------------------");
    
    
    
    
    printCounter = 0;
    lengthCounter = INT_MAX;
    bestWT = nil;
    
    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasWon == YES && wt.bonuses.count == 2 && [wt.steps count] < lengthCounter) {
            lengthCounter = [wt.steps count];
            bestWT = wt;
        }
    }
    
    NSLog(@"Shortest Win strategy with 2 bonuses:");
    NSLog(@"------------------");
    if (bestWT) {
        for (MapVertex *mv in bestWT.steps) {
            NSLog(@"step %d : vertex %d", [bestWT.steps indexOfObject:mv], mv.index);
        }
    }
    NSLog(@"------------------");
    
    
    
    
    printCounter = 0;
    lengthCounter = INT_MAX;
    bestWT = nil;
    
    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasWon == YES && wt.bonuses.count == 1 && [wt.steps count] < lengthCounter) {
            lengthCounter = [wt.steps count];
            bestWT = wt;
        }
    }
    
    NSLog(@"Shortest Win strategy with 1 bonuses:");
    NSLog(@"------------------");
    if (bestWT) {
        for (MapVertex *mv in bestWT.steps) {
            NSLog(@"step %d : vertex %d", [bestWT.steps indexOfObject:mv], mv.index);
        }
    }
    NSLog(@"------------------");
    
    
    
    
    printCounter = 0;
    lengthCounter = INT_MAX;
    bestWT = nil;
    
    for (Walkthrough *wt in walkthroughs) {
        if (wt.hasWon == YES && wt.bonuses.count == 0 && [wt.steps count] < lengthCounter) {
            lengthCounter = [wt.steps count];
            bestWT = wt;
        }
    }
    
    NSLog(@"Shortest Win strategy with 0 bonuses:");
    NSLog(@"------------------");
    if (bestWT) {
        for (MapVertex *mv in bestWT.steps) {
            NSLog(@"step %d : vertex %d", [bestWT.steps indexOfObject:mv], mv.index);
        }
    }
    NSLog(@"------------------");
    
    

//    printCounter = 0;
//
//    NSLog(@"Win strategy with 2 bonuses:");
//    NSLog(@"------------------");
//    for (Walkthrough *wt in walkthroughs) {
//        if (printCounter > 2) break;
//
//        if (wt.hasWon == YES && wt.bonuses.count == 2) {
//            for (MapVertex *mv in wt.steps) {
//                NSLog(@"step %d : vertex %d", [wt.steps indexOfObject:mv], mv.index);
//            }
//            NSLog(@"------------------");
//            printCounter++;
//        }
//    }
//    
//    printCounter = 0;
//    
//    NSLog(@"Win strategy with 1 bonus:");
//    NSLog(@"------------------");
//    for (Walkthrough *wt in walkthroughs) {
//        if (printCounter > 2) break;
//
//        if (wt.hasWon == YES && wt.bonuses.count == 1) {
//            for (MapVertex *mv in wt.steps) {
//                NSLog(@"step %d : vertex %d", [wt.steps indexOfObject:mv], mv.index);
//            }
//            NSLog(@"------------------");
//            printCounter++;
//        }
//    }
//    
//    printCounter = 0;
//    
//    NSLog(@"Win strategy with 0 bonus:");
//    NSLog(@"------------------");
//    for (Walkthrough *wt in walkthroughs) {
//        if (printCounter > 2) break;
//
//        if (wt.hasWon == YES && wt.bonuses.count == 0) {
//            for (MapVertex *mv in wt.steps) {
//                NSLog(@"step %d : vertex %d", [wt.steps indexOfObject:mv], mv.index);
//            }
//            NSLog(@"------------------");
//            printCounter++;
//        }
//    }
//    
//    printCounter = 0;
//    
//    NSLog(@"Lose strategy:");
//    NSLog(@"------------------");
//    for (Walkthrough *wt in walkthroughs) {
//        if (printCounter > 2) break;
//        if (wt.hasWon == NO) {
//            for (MapVertex *mv in wt.steps) {
//                NSLog(@"step %d : vertex %d", [wt.steps indexOfObject:mv], mv.index);
//            }
//            NSLog(@"------------------");
//            printCounter++;
//        }
//    }
    
    
    
    
}

- (void)backPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
}

#pragma mark - Resources popup handlers

- (void)updateIndicators
{
    [self.redIndicator setString:[NSString stringWithFormat:@"%d", resources[0]]];
    [self.greenIndicator setString:[NSString stringWithFormat:@"%d", resources[1]]];
    [self.blueIndicator setString:[NSString stringWithFormat:@"%d", resources[2]]];
    [self.brownIndicator setString:[NSString stringWithFormat:@"%d", resources[3]]];
    [self.goldIndicator setString:[NSString stringWithFormat:@"%d", resources[4]]];
}

- (void)redPlusPressed {
    resources[0]++;
    [self updateIndicators];
}

- (void)redMinusPressed {
    resources[0]--;
    [self updateIndicators];
}

- (void)greenPlusPressed {
    resources[1]++;
    [self updateIndicators];
}

- (void)greenMinusPressed {
    resources[1]--;
    [self updateIndicators];
}

- (void)bluePlusPressed {
    resources[2]++;
    [self updateIndicators];
}

- (void)blueMinusPressed {
    resources[2]--;
    [self updateIndicators];
}

- (void)brownPlusPressed {
    resources[3]++;
    [self updateIndicators];
}

- (void)brownMinusPressed {
    resources[3]--;
    [self updateIndicators];
}

- (void)goldPlusPressed {
    resources[4]++;
    [self updateIndicators];
}

- (void)goldMinusPressed {
    resources[4]--;
    [self updateIndicators];
}

- (void)closePopupPressed {
    [self removeChild:self.popup cleanup:YES];
    self.popup = nil;
}


#pragma mark -

- (BOOL)point:(CGPoint)point insideMapVertex:(MapVertex *)mv
{
    CGRect testRect = CGRectMake(self.map.position.x + self.mapVerts.position.x + mv.position.x + mv.sprite.boundingBox.origin.x,
                                 self.map.position.y + self.mapVerts.position.y + mv.position.y + mv.sprite.boundingBox.origin.y,
                                 mv.sprite.boundingBox.size.width,
                                 mv.sprite.boundingBox.size.height);
    return CGRectContainsPoint(testRect, point);
}

- (BOOL)point:(CGPoint)location insideConnection:(VertexConnection *)vc
{
    CGPoint rotCenter = ccpAdd(self.map.position, vc.position);
    CGPoint rotatedLocation = ccpRotateByAngle(location, rotCenter, CC_DEGREES_TO_RADIANS(vc.sprite.rotation) );
    
    CGRect testRect = CGRectMake(self.map.position.x + self.mapConns.position.x + vc.position.x - vc.sprite.boundingBox.size.width / 2.0,
                                 self.map.position.y + self.mapConns.position.y + vc.position.y - 64 * [CCDirector sharedDirector].contentScaleFactor / 2.0,
                                 vc.sprite.boundingBox.size.width,
                                 64 * [CCDirector sharedDirector].contentScaleFactor);

//    NSLog(@"-----");
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
//    NSLog(@"location = (%f, %f)", location.x, location.y);
//    NSLog(@"vc.startVertex = %d", vc.startVertex.index);
//    NSLog(@"vc.endVertex = %d", vc.endVertex.index);
//    NSLog(@"vc.position = (%f, %f)", vc.position.x, vc.position.y);
//    NSLog(@"vc.sprite.position = (%f, %f)", vc.sprite.position.x, vc.sprite.position.y);
//    NSLog(@"vc.sprite.rotation = %f", vc.sprite.rotation);
//    NSLog(@"self.map.position = (%f, %f)", self.map.position.x, self.map.position.y);
//    NSLog(@"rotCenter = (%f, %f)", rotCenter.x, rotCenter.y);
//    NSLog(@"rotatedLocation = (%f, %f)", rotatedLocation.x, rotatedLocation.y);
//    NSLog(@"testRect = (%f, %f, %f, %f)", testRect.origin.x, testRect.origin.y, testRect.size.width, testRect.size.height);
//    NSLog(@"result = %d", CGRectContainsPoint(testRect, rotatedLocation));
//    NSLog(@"-----");
    
    return CGRectContainsPoint(testRect, rotatedLocation);

//    //TODO: replace this workaround to working solution
//    float distance = ccpLength(ccpSub(location, ccpAdd(self.map.position, vc.position)) );
//    if (distance < 15) return YES;
//    
//    return NO;

}

#pragma mark - Touch handlers

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    switch (self.state) {
        case STATE_RUNNING:
        {
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    self.vertexToMove = mv;
                    return YES;
                }
            }
            return YES;
            break;
        }
            
        case STATE_WAIT_CONNECTION_VERTEX_1:
        {
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    self.newConnectionVertexStart = mv;
                    self.state = STATE_WAIT_CONNECTION_VERTEX_2;
                    [self.console setString:@"Press end vertex"];

                    return YES;
                }
            }
            return YES;
            break;
        }
            
        case STATE_WAIT_CONNECTION_VERTEX_2:
        {
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    if (mv != self.newConnectionVertexStart)
                    {
                        self.newConnectionVertexEnd = mv;
                        
                        uint newResType = rand() % (RESOURCE_TYPE_5 + 1);
                        while (newResType == self.newConnectionVertexStart.resourceType || newResType == self.newConnectionVertexEnd.resourceType) {
                        newResType = rand() % (RESOURCE_TYPE_5 + 1);                        }
                        
                        VertexConnection *newConnection = [[[VertexConnection alloc] initWithStartVertex:self.newConnectionVertexStart EndVertex:self.newConnectionVertexEnd ResourceType:newResType] autorelease];
                        self.newConnectionVertexEnd = self.newConnectionVertexStart = nil;
                        [self.connections addObject:newConnection];
                        [self.mapConns addChild:newConnection];
                        self.state = STATE_RUNNING;
                        [self.console setString:@">"];
                        return YES;
                    }
                }
            }
            return YES;
            break;
        }
            
        case STATE_WAIT_DELETE_VERTEX:
        {
            MapVertex *vertexToRemove = nil;
            NSMutableArray *connectionsToRemove = [NSMutableArray array];
            
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    vertexToRemove = mv;
                    [self.mapVerts removeChild:mv cleanup:YES];;
                                        
                    for (VertexConnection *vc in self.connections)
                    {
                        if ( mv == vc.startVertex || mv == vc.endVertex )
                        {
                            [connectionsToRemove addObject:vc];
                            [self.mapConns removeChild:vc cleanup:YES];
                        }

                    }
                    
                    self.state = STATE_RUNNING;
                    [self.console setString:@">"];
                    

                }
            }
            
            [self.vertexes removeObject:vertexToRemove];
            [self recalculateVertexIndexes];
            [self.connections removeObjectsInArray:connectionsToRemove];
            
            return YES;
            break;
        }
            
        case STATE_WAIT_DELETE_CONNECTION:
        {
            VertexConnection *vcToDelete = nil;
            for (VertexConnection *vc in self.connections) {
                if ([self point:location insideConnection:vc]) {
                    vcToDelete = vc;
                    break;
                }
            }
            
            if (vcToDelete) {
                [self.connections removeObject:vcToDelete];
                [self.mapConns removeChild:vcToDelete cleanup:YES];
                
                self.state = STATE_RUNNING;
                [self.console setString:@">"];
            }
            
            return YES;
        }  
            
        case STATE_WAIT_COLOR_VERTEX:
        {
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    mv.resourceType++;
                    if (mv.resourceType > RESOURCE_TYPE_5) {
                        mv.resourceType = RESOURCE_TYPE_1;
                    }
                    
                    [mv recreateSprite];
                    [mv recreatePictogramm];
                    [self recalculateVertexIndexes]; //to restore label


                    self.state = STATE_RUNNING;
                    [self.console setString:@">"];
                    return YES;
                }
            }
            return YES;
            break;

        }

        case STATE_WAIT_COLOR_CONNECTION:
        {
            for (VertexConnection *vc in self.connections) {
                if ([self point:location insideConnection:vc]) {
                    
//                    NSLog(@"location = (%f, %f)", location.x, location.y);
//                    NSLog(@"vc.position = (%f, %f)", vc.position.x, vc.position.y);
//                    NSLog(@"vc.sprite.rotation = %f", vc.sprite.rotation);
//                    NSLog(@"self.map.position = (%f, %f)", self.map.position.x, self.map.position.y);
//                    NSLog(@"self.mapConns.position = (%f, %f)", self.mapConns.position.x, self.mapConns.position.y);
                    
                    vc.resourceType++;
                    if (vc.resourceType > RESOURCE_TYPE_5) {
                        vc.resourceType = RESOURCE_TYPE_1;
                    }
                    
                    [vc recalcPosition]; //recreates sprite;
                    
                    self.state = STATE_RUNNING;
                    [self.console setString:@">"];
                    return YES;
                }
            }
            
            return YES;
            break;
        }
            
        case STATE_WAIT_MODIFY_VERTEX:
        {
            for (MapVertex *mv in self.vertexes)
            {
                if ([self point:location insideMapVertex:mv])
                {
                    mv.pictogrammType++;
                    if (mv.pictogrammType > MODIFIER_BONUS) {
                        mv.pictogrammType = MODIFIER_NONE;
                    }
                    
                    [mv recreatePictogramm];
                    
//                    [mv recreateSprite];
//                    [self recalculateVertexIndexes]; //to restore label
                    
                    
                    self.state = STATE_RUNNING;
                    [self.console setString:@">"];
                    return YES;
                }
            }
            return YES;
            break;
        }

            
        default:
        {
            NSLog(@"Unexpected state in %@ : %@", self, NSStringFromSelector(_cmd));
            return YES;
            break;
        }
    }
    

}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    
    CGPoint locationInMap = [self convertTouchToNodeSpace:touch];
    CGPoint locationInTouchView = [self convertToNodeSpace:[touch locationInView:[touch view]]];
    CGPoint prevLocationInTouchView = [self convertToNodeSpace:[touch previousLocationInView:[touch view]]];
    
    
    if (self.vertexToMove)
    {
        self.vertexToMove.position = ccpAdd(locationInMap, ccp(-self.map.position.x, -self.map.position.y));
        for (VertexConnection *vc in self.connections)
        {
            if ( self.vertexToMove == vc.startVertex || self.vertexToMove == vc.endVertex )
                [vc recalcPosition];
        }
        
    } else {
        CGPoint mapOffset = ccpSub(locationInTouchView, prevLocationInTouchView);
        mapOffset = ccp(mapOffset.x, -mapOffset.y);
        self.map.position = ccpAdd(self.map.position, mapOffset);
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
//    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    self.vertexToMove = nil;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"%@ : %@", self, NSStringFromSelector(_cmd));
    self.vertexToMove = nil;

}

#pragma mark -

- (void)dealloc
{
    [_vertexToMove release];
    [_vertexes release];
    [_connections release];
    
    [super dealloc];
}

@end

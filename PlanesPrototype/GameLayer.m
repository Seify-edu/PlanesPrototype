//
//  GameLayer.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 24.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameLayer.h"
#import "Popup.h"
#import "EditorLayer.h"

#define MAX_LEVEL 20

@implementation GameLayer

+(CCScene *)scene
{
	CCScene *scene = [CCScene node];
    
	GameLayer *gl = [GameLayer node];
    gl.tag = 0;
	[scene addChild: gl];
    
	return scene;
}

- (NSDictionary *)loadLevel:(NSString *)levelName
{
    
    self.levelName = levelName;
    
#ifdef EDITOR
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *levelsDir = [documentsDirectory stringByAppendingPathComponent:@"levels/"];
    NSString *levelFile = [levelsDir stringByAppendingPathComponent:self.levelName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:levelsDir])
        NSLog(@"test level file does not exist");
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:levelFile];
    return level;
#else
    NSURL* url = [[NSBundle mainBundle] URLForResource:levelName withExtension:@""];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        NSLog(@"level file %@ does not exist", levelName);
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfURL:url];
#endif
    
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
    [self updateAvaiblePathVisual];

    
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
    
    [self updateAvaiblePathVisual];
    
}

- (id)init
{
	if (self = [super init])
    {
        self.state = GAME_STATE_RUNNING;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
        bg.position = ccp (self.contentSize.width / 2.0, self.contentSize.height / 2.0);
        [self addChild:bg];
        
        self.map = [MapNode node];
        self.vertexes = [NSMutableArray array];
        self.connections = [NSMutableArray array];

        [self addChild:self.map];

        self.map.position = ccp(WIN_SIZE.width / 2.0, WIN_SIZE.height / 2.0);
        self.map.position = ccpSub(self.map.position, self.player.currentVertex.position);
        
        HudNode *hudl = [HudNode node];
        hudl.delegate = self;
        self.hud = hudl;
        [hudl updateResources];
        [self addChild:hudl];
        
        [self updateAvaiblePathVisual];
        
        self.console = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
        self.console.color = ccBLACK;
        [self addChild:self.console];
        self.console.position = ccp(self.contentSize.width / 2.0, self.contentSize.height * 0.7);

        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
	}
	return self;
}

- (BOOL)point:(CGPoint)point insideMapVertex:(MapVertex *)mv
{
    CGRect testRect = CGRectMake(self.map.position.x + mv.position.x + mv.sprite.boundingBox.origin.x, self.map.position.y + mv.position.y + mv.sprite.boundingBox.origin.y, mv.sprite.boundingBox.size.width, mv.sprite.boundingBox.size.height);
    return CGRectContainsPoint(testRect, point);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.state == GAME_STATE_PAUSE) {
        return YES;
    }
    
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
                    BOOL enoughResources = ( resources[vc.resourceType] > 0 );
                    
                    if (!playerMoving && enoughResources)
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
                        
                        [self updateAvaiblePathVisual];


//                        TODO: uncomment this to keep player in the center of the screen
//                        CGPoint mapOffset = ccpSub(self.player.position, mv.position);
//                        CGPoint newMapPosition = ccpAdd(self.map.position, mapOffset);
//                        CCMoveTo *moveMap = [CCMoveTo actionWithDuration:timeToTravel position:newMapPosition];
//                        [self.map runAction:moveMap];
                        
                        if (mv.pictogrammType == MODIFIER_END)
                        {
                            [self performSelector:@selector(levelWon) withObject:nil afterDelay:(NSTimeInterval)timeToTravel];
                        }
                        else
                        {
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
                            if (cannotMove)
                            {
                                [self performSelector:@selector(levelLose) withObject:nil afterDelay:(NSTimeInterval)timeToTravel];
                            }

                            BOOL flowerCollected = (mv.pictogrammType == MODIFIER_BONUS);
                            if (flowerCollected) {
                                [self performSelector:@selector(collectFlowerFromVertex:) withObject:mv afterDelay:(NSTimeInterval)timeToTravel];
                            }                            
                        }
                    }
                    else
                    {
                        //TODO: play action with resource indicators
                        if (!enoughResources)
                        {
                            [self.hud blinkEnergyBar];
                        }
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
    [self.hud updateResources];
    [self updateAvaiblePathVisual];
}

- (void)updateAvaiblePathVisual
{
    for (VertexConnection *vc in self.connections)
    {
//        vc.sprite.opacity = 255.0f;
//            if (resources[vc.resourceType] <= 0) {
//                vc.sprite.opacity = 122.0f;
//            }
        
//        vc.sprite.scaleX = 1.0f;
//        if (resources[vc.resourceType] <= 0) {
//            vc.sprite.scaleX = 0.2f;
//        }

//        vc.sprite.scaleY = 1.0f;
//        if (resources[vc.resourceType] <= 0) {
//            vc.sprite.scaleY = 0.2f;
//        }        
    }
}

- (int)getStarsCollected
{
    return self.flowersCollected;
}

- (CCMenuItemSprite *)createButtonWithFile:(NSString *)filename Color:(ccColor3B)color Selector:(SEL)sel Text:(NSString *)text
{
    CCSprite *resumeButtonUnpressed = [CCSprite spriteWithFile:filename];
    CCSprite *resumeButtonPressed = [CCSprite spriteWithFile:filename];
    resumeButtonUnpressed.color = resumeButtonPressed.color = color;
    resumeButtonUnpressed.opacity = resumeButtonPressed.opacity = DEFAULT_OPACITY;
    CCMenuItemSprite *resumeButton = [CCMenuItemSprite itemWithNormalSprite:resumeButtonUnpressed selectedSprite:resumeButtonPressed target:self selector:sel];
    CCLabelTTF *resumeButtonText = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:48];
    resumeButtonText.position = ccp( resumeButton.contentSize.width * 0.5, resumeButton.contentSize.height * 0.5);
    [resumeButton addChild:resumeButtonText];
    
    return resumeButton;
}

- (void)pauseButtonPressed
{
    if (self.state == GAME_STATE_PAUSE) return;
    
    self.state = GAME_STATE_PAUSE;
    
    self.popup = [Popup node];
    
    CCMenuItemSprite *resumeButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_GREEN] Selector:@selector(resumeButtonPressed) Text:@"Resume"];
    CCMenuItemSprite *restartButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_PINK] Selector:@selector(restartButtonPressed) Text:@"Restart"];
    CCMenuItemSprite *levelSelectButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_BLUE] Selector:@selector(levelSelectButtonPressed) Text:@"Select level"];
#ifdef EDITOR
    CCMenuItemSprite *editorButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_PINK] Selector:@selector(editorButtonPressed) Text:@"Editor"];
    CCMenuItemSprite *mainMenuButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_PINK] Selector:@selector(mainMenuButtonPressed) Text:@"Main Menu"];
    
#endif
    CCMenu *popupMenu = [CCMenu menuWithItems:resumeButton, restartButton, levelSelectButton,
#ifdef EDITOR
                                editorButton, mainMenuButton,
#endif
                         nil];
    [popupMenu alignItemsVerticallyWithPadding:50];
    popupMenu.position = ccp( 0, 0 );
    [self.popup addChild:popupMenu];
    [self addChild:self.popup];
}

- (void)resumeButtonPressed
{
    self.state = GAME_STATE_RUNNING;
    
    [self removeChild:self.popup cleanup:YES];
}

- (void)restartLevel
{
    self.flowersCollected = 0;
    for (int i = 0; i < 5; i++)
        resources[i] = 0;
    [self.map removeAllChildrenWithCleanup:YES];
    [self.hud removeAllChildrenWithCleanup:YES];
    [self.vertexes removeAllObjects];
    [self.connections removeAllObjects];
    self.player = nil;
    [self.hud updateResources];
    [self updateAvaiblePathVisual];
    
//    NSString *levelName = [NSString stringWithFormat:@"level%d_%d", self.currentPack, self.currentLevel];
    NSDictionary *level = [self loadLevel:self.levelName];
    [self parseLevel:level];
}

- (void)restartButtonPressed
{
    [self restartLevel];
    
    self.state = GAME_STATE_RUNNING;
    
    [self removeChild:self.popup cleanup:YES];
}

- (void)levelSelectButtonPressed
{
    LevelSelectLayer *newLayer = [[[LevelSelectLayer alloc] initWithMode:LEVEL_SELECT_MODE_GAME] autorelease];
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

- (void)editorButtonPressed
{
    EditorLayer *newLayer = [EditorLayer node];
    CCScene *newScene = [CCScene node];
    NSDictionary *level = [newLayer loadLevel:self.levelName];
    [newLayer parseLevel:level];
	[newScene addChild: newLayer];

    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

- (void)mainMenuButtonPressed
{
    MainMenuLayer *newLayer = [MainMenuLayer node];
    CCScene *newScene = [CCScene node];
	[newScene addChild: newLayer];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:newScene withColor:ccWHITE]];
}

- (void)nextLevelButtonPressed
{
    [self removeChild:self.popup cleanup:YES];

    if ( self.currentLevel < MAX_LEVEL)
    {
        self.currentLevel++;
        self.levelName = [NSString stringWithFormat:@"level%d_%d", self.currentPack, self.currentLevel];
        [self restartLevel];
        self.state = GAME_STATE_RUNNING;
    }
    else
    {
        [self showComingSoon];
    }
}

- (void)showComingSoon
{
    self.state = GAME_STATE_PAUSE;
    
    self.popup = [Popup node];
    
    CCLabelTTF *wonText = [CCLabelTTF labelWithString:@"You won!" fontName:@"Marker Felt" fontSize:48];
    CCMenuItemLabel *title = [CCMenuItemLabel itemWithLabel:wonText];

    CCLabelTTF *thxText = [CCLabelTTF labelWithString:@"Thx for playing :)" fontName:@"Marker Felt" fontSize:48];
    CCMenuItemLabel *textThx = [CCMenuItemLabel itemWithLabel:thxText];
    
    CCLabelTTF *newLevelsText = [CCLabelTTF labelWithString:@"New levels coming soon..." fontName:@"Marker Felt" fontSize:48];
    CCMenuItemLabel *textNewLevels = [CCMenuItemLabel itemWithLabel:newLevelsText];

    CCMenuItemSprite *levelSelectButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[1] Selector:@selector(levelSelectButtonPressed) Text:@"Select level"];
    CCMenu *popupMenu = [CCMenu menuWithItems: title, textThx, textNewLevels, levelSelectButton, nil];
    [popupMenu alignItemsVerticallyWithPadding:50];
    popupMenu.position = ccp( 0, 0 );
    [self.popup addChild:popupMenu];
    [self addChild:self.popup];

}

- (void)levelWon
{
    self.state = GAME_STATE_PAUSE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *levelWonKey = [NSString stringWithFormat:@"pack%dlevel%dWon", self.currentPack, self.currentLevel ];
    [defaults setBool:YES forKey:levelWonKey];
    NSString *starsCollectedKey = [NSString stringWithFormat:@"starsUnlockedInPack%dLevel%d", self.currentPack, self.currentLevel];
    int starsCollectedBefore = [defaults integerForKey:starsCollectedKey];
    if (self.flowersCollected > starsCollectedBefore) {
        [defaults setInteger:self.flowersCollected forKey:starsCollectedKey];
    }
    [defaults synchronize];
        
    self.popup = [Popup node];

    CCLabelTTF *wonText = [CCLabelTTF labelWithString:@"You won!" fontName:@"Marker Felt" fontSize:48];
    CCMenuItemLabel *title = [CCMenuItemLabel itemWithLabel:wonText];
    title.isEnabled = NO;
    title.color = UI_COLOR_WHITE;
    
    CCMenuItemSprite *nextLevelButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[0] Selector:@selector(nextLevelButtonPressed) Text:@"Next level"];
    CCMenuItemSprite *restartButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[1] Selector:@selector(restartButtonPressed) Text:@"Restart"];
    
    CCSprite *starsContainer = [CCSprite spriteWithFile:@"starFrameBase.png"];
    starsContainer.opacity = 0;
    CCSprite *starsContainerPressed = [CCSprite spriteWithFile:@"starFrameBase.png"];
    starsContainerPressed.opacity = 0;
    for (int i = 0; i < 3; i++) {
        CCSprite *starFrame = [CCSprite spriteWithFile:@"starFrameBase.png"];
        starFrame.color = UI_COLOR_WHITE;
        starFrame.position = ccp( starFrame.contentSize.height * ( -1.0 + 1.5 * i ), starFrame.contentSize.height / 2. );
        [starsContainer addChild:starFrame];
        
        if (i + 1 <= self.flowersCollected)
        {
            CCSprite *star = [CCSprite spriteWithFile:@"starBase.png"];
            star.color = SIGNS_COLOR_ORANGE;
            star.opacity = DEFAULT_OPACITY;
            star.position = ccp( starFrame.contentSize.width/2. , starFrame.contentSize.height/2. );
            [starFrame addChild:star];
        }
    }
    CCMenuItemSprite *stars = [CCMenuItemSprite itemWithNormalSprite:starsContainer selectedSprite:starsContainerPressed];
    stars.isEnabled = NO;
                                        
    CCMenu *popupMenu = [CCMenu menuWithItems:title, stars, nextLevelButton, restartButton, nil];
    [popupMenu alignItemsVerticallyWithPadding:50];
    popupMenu.position = ccp( 0, 0 );
    [self.popup addChild:popupMenu];
    

    
    [self addChild:self.popup];
}

- (void)levelLose
{
    self.state = GAME_STATE_PAUSE;
    
    self.popup = [Popup node];
    
    CCLabelTTF *loseText = [CCLabelTTF labelWithString:@"You lose..." fontName:@"Marker Felt" fontSize:48];
    CCMenuItemLabel *title = [CCMenuItemLabel itemWithLabel:loseText];
    title.isEnabled = NO;
    title.color = UI_COLOR_WHITE;
    
    CCMenuItemSprite *restartButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_PINK] Selector:@selector(restartButtonPressed) Text:@"Restart"];
    CCMenuItemSprite *levelSelectButton = [self createButtonWithFile:@"popupButtonBase.png" Color:flowerColors[FLOWERS_COLOR_BLUE] Selector:@selector(levelSelectButtonPressed) Text:@"Select level"];
    
    CCMenu *popupMenu = [CCMenu menuWithItems:title, restartButton, levelSelectButton, nil];
    [popupMenu alignItemsVerticallyWithPadding:50];
    popupMenu.position = ccp( 0, 0 );
    [self.popup addChild:popupMenu];
    
    [self addChild:self.popup];
}

- (void)dealloc
{
    self.vertexes = nil;
    self.connections = nil;
    [super dealloc];
}

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

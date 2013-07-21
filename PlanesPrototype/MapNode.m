//
//  MapNode.m
//  PlanesPrototype
//
//  Created by Roman Smirnov on 22.07.13.
//
//

#import "MapNode.h"
#import "cocos2d.h"
#import "Constants.h"

@implementation MapNode

-(id)init
{
    if ( self = [super init] ) {
        self.renderTexture = [CCRenderTexture renderTextureWithWidth:2048 height:2048];
        self.renderTexture.position = ccp(WIN_SIZE.width / 2., WIN_SIZE.height / 2.);
        self.renderTexture.sprite.opacity = DEFAULT_OPACITY;
    }
    return self;
}

-(void) visit
{
	// quick return if not visible. children won't be drawn.
	if (!visible_)
		return;
    
	kmGLPushMatrix();
    
	if ( grid_ && grid_.active)
		[grid_ beforeDraw];
    
	[self transform];
    
	if(children_) {
        
		[self sortAllChildren];
        
		ccArray *arrayData = children_->data;
		NSUInteger i = 0;
        

        
		// draw children zOrder < 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child = arrayData->arr[i];
			if ( [child zOrder] < 0 )
				[child visit];
			else
				break;
		}
        
		// self draw
		[self draw];
        
        [self.renderTexture beginWithClear:0 g:0 b:0 a:0];
        
		// draw children zOrder >= 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child = arrayData->arr[i];
            if (child != self.player) {
                [child visit];
            }
        }
        
        [self.renderTexture end];        
        [self.renderTexture visit];

        //rendering to texture somehow resets player's position. Hack to fix this.
        self.player.position = ccpAdd(self.player.position, self.position);
        [self.player visit];
        self.player.position = ccpSub(self.player.position, self.position);
        
	} else
		[self draw];
    
	// reset for next frame
	orderOfArrival_ = 0;
    
	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];
    
	kmGLPopMatrix();
}


@end

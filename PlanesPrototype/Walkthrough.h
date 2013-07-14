//
//  Walkthrough.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 04.03.13.
//
//

#import <Foundation/Foundation.h>
#import "EditorLayer.h"

@interface Walkthrough : NSObject
{
@public
    int resources[NUMBER_OF_RESOURCES];
}
@property BOOL hasWon;
@property BOOL hasLose;
@property int stepsCounter;
@property (retain) NSMutableArray *steps;
@property (retain) NSMutableArray *bonuses;

@end

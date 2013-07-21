//
//  Constants.h
//  PlanesPrototype
//
//  Created by Roman Smirnov on 27.01.13.
//
//

#define NUMBER_OF_RESOURCES 5

#define WIN_SIZE [[CCDirector sharedDirector] winSize]

enum
{
    RESOURCE_TYPE_1,
    RESOURCE_TYPE_2,
    RESOURCE_TYPE_3,
    RESOURCE_TYPE_4,
    RESOURCE_TYPE_5,
};

enum
{
    MODIFIER_NONE,
    MODIFIER_START,
    MODIFIER_END,
    MODIFIER_BONUS
};

#define BEE_COLOR_ORANGE ccc3(181, 123, 23);
#define BEE_COLOR_BROWN ccc3(47, 34, 15);

#define UI_COLOR_BLUE ccc3(34, 64, 162);
#define UI_COLOR_GREY ccc3(122, 125, 136);

#define SIGNS_COLOR_ORANGE ccc3(150, 87, 20);

//#define FLOWERS_COLOR_PINK ccc3(222, 140, 160);
//#define FLOWERS_COLOR_PURPLE ccc3(169, 140, 222);
//#define FLOWERS_COLOR_BLUE ccc3(140, 206, 222);
//#define FLOWERS_COLOR_GREEN ccc3(144, 222, 140);
//#define FLOWERS_COLOR_YELLOW ccc3(222, 221, 140);

enum {FLOWERS_COLOR_PINK, FLOWERS_COLOR_PURPLE, FLOWERS_COLOR_BLUE, FLOWERS_COLOR_GREEN, FLOWERS_COLOR_YELLOW};

static ccColor3B flowerColors[5] = {{222, 140, 160}, {169, 140, 222}, {140, 206, 222}, {144, 222, 140}, {222, 221, 140}};

#define DEFAULT_OPACITY (204)
#define DEFAULT_OPACITY_DISABLED (50)

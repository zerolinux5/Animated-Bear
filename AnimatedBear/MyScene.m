//
//  MyScene.m
//  AnimatedBear
//
//  Created by Jesus Magana on 7/1/14.
//  Copyright (c) 2014 ZeroLinux5. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MyScene.h"

@implementation MyScene
{
    
    SKSpriteNode *_bear;
    NSArray *_bearWalkingFrames;
    
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        
        // TODO...
        NSMutableArray *walkFrames = [NSMutableArray array];
        SKTextureAtlas *bearAnimatedAtlas = [SKTextureAtlas atlasNamed:@"BearImages"];
        int numImages = bearAnimatedAtlas.textureNames.count;
        for (int i=1; i <= numImages/2; i++) {
            NSString *textureName = [NSString stringWithFormat:@"bear%d", i];
            SKTexture *temp = [bearAnimatedAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        _bearWalkingFrames = walkFrames;
        
        SKTexture *temp = _bearWalkingFrames[0];
        _bear = [SKSpriteNode spriteNodeWithTexture:temp];
        _bear.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:_bear];
        //[self walkingBear];
        
    }
    return self;
}

-(void)walkingBear
{
    //This is our general runAction method to make our bear walk.
    [_bear runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_bearWalkingFrames
                                       timePerFrame:0.1f
                                             resize:NO
                                            restore:YES]] withKey:@"walkingInPlaceBear"];
    return;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGFloat multiplierForDirection;
    
    if (location.x <= CGRectGetMidX(self.frame)) {
        //walk left
        multiplierForDirection = 1;
    } else {
        //walk right
        multiplierForDirection = -1;
    }
    
    _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
    [self walkingBear];
     */
    
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGFloat multiplierForDirection;
    CGSize screenSize = self.frame.size;
    float bearVelocity = screenSize.width / 3.0;
    CGPoint moveDifference = CGPointMake(location.x - _bear.position.x, location.y - _bear.position.y);
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    float moveDuration = distanceToMove / bearVelocity;
    if (moveDifference.x < 0) {
        multiplierForDirection = 1;
    } else {
        multiplierForDirection = -1;
    }
    _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
    
    if ([_bear actionForKey:@"bearMoving"]) {
        //stop just the moving to a new location, but leave the walking legs movement running
        [_bear removeActionForKey:@"bearMoving"];
    } //1
    
    if (![_bear actionForKey:@"walkingInPlaceBear"]) {
        //if legs are not moving go ahead and start them
        [self walkingBear];  //start the bear walking
    } //2
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];  //3
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        [self bearMoveEnded];
    }]; //4
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction]]; //5
    
    [_bear runAction:moveActionWithDone withKey:@"bearMoving"]; //6
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
}

-(void)bearMoveEnded
{
    [_bear removeAllActions];
}


@end

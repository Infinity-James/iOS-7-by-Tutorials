//
//  FlipAnimationController.h
//  ILoveCatz
//
//  Created by James Valaitis on 01/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#pragma mark - Flip Animation Controller Public Interface

@interface FlipAnimationController : NSObject <UIViewControllerAnimatedTransitioning> {}

#pragma mark - Public Properties

/**	Whether or not to do the animation in reverse.	*/
@property (nonatomic, assign)	BOOL	reverse;

@end
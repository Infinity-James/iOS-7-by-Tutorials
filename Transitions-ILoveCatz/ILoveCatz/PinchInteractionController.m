//
//  PinchInteractionController.m
//  ILoveCatz
//
//  Created by James Valaitis on 02/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "PinchInteractionController.h"

#pragma mark - Pinch Interaction Controller Implementation

@interface PinchInteractionController () {}

/**	When used in a dimissal animation, we keep a pointer to the from view controller.	*/
@property (nonatomic, weak)		UIViewController		*fromViewController;
/**	Whether or the animation should now be completed.	*/
@property (nonatomic, assign)	BOOL					shouldCompleteTransition;

@end

#pragma mark - Pinch Interaction Controller Private Class Extension

@implementation PinchInteractionController {}

#pragma mark - Gesture Handling

/**
 *	Handles a given gesture recogniser.
 *
 *	@param	pinchGesture				The gesture which sent this message.
 */
- (void)handleGesture:(UIPinchGestureRecognizer *)pinchGesture
{
	CGFloat scale						= pinchGesture.scale;
	
	switch (pinchGesture.state)
	{
		case UIGestureRecognizerStateBegan:
			self.interactionInProgress	= YES;
			[self.fromViewController dismissViewControllerAnimated:YES completion:nil];
			break;
		case UIGestureRecognizerStateChanged:
			//	get current progress through transition
			scale						= 1.0f - fminf(fmaxf(scale, 0.0f), 1.0f);
			
			//	are we far enough to complete?
			self.shouldCompleteTransition	= scale > 0.5f;
			
			NSLog(@"SCALEZ: %f", scale);
			
			//	update completion percentage of the animation
			[self updateInteractiveTransition:scale];
			
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			self.interactionInProgress		= NO;
			if (!self.shouldCompleteTransition || pinchGesture.state == UIGestureRecognizerStateCancelled)
				[self cancelInteractiveTransition];
			else
				[self finishInteractiveTransition];
			break;
		default:
			break;
	}
}

#pragma mark - Interaction Setup

/**
 *	Adds the appropriate gesture recogniser to the given view.
 *
 *	@param	view						The view which requires the gesture recogniser.
 */
- (void)prepareGestureRecogniserInView:(UIView *)view
{
	UIPinchGestureRecognizer *pinchGesture	= [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
	[view addGestureRecognizer:pinchGesture];
}

/**
 *	Attaches this interaction controller to the given view controller.
 *
 *	@param	viewController				The view controller to be attached to this interaction controller.
 */
- (void)wireToViewController:(UIViewController *)viewController
{
	self.fromViewController					= viewController;
	[self prepareGestureRecogniserInView:viewController.view];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The speed of the transition animation.
 *
 *	@return	The speed of the transition animation.
 */
- (CGFloat)completionSpeed
{
	return 1.0f - self.percentComplete;
}

@end
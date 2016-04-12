//
//  SwipeInteractionController.m
//  ILoveCatz
//
//  Created by James Valaitis on 02/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "SwipeInteractionController.h"

#pragma mark - Swipe Interaction Controller Private Class Extension

@interface SwipeInteractionController () {}

#pragma mark - Private Properties

/**	The navigation controller of the view controllers transitioning.	*/
@property (nonatomic, weak)	UINavigationController		*navigationController;
/**	Whether or the animation should now be completed.	*/
@property (nonatomic, assign)	BOOL					shouldCompleteTransition;

@end

#pragma mark - Swipe Interaction Controller Implementation

@implementation SwipeInteractionController {}

#pragma mark - Gesture Handling

/**
 *	Handles a given gesture recogniser.
 *
 *	@param	panGesture						The gesture which sent this message.
 */
- (void)handleGesture:(UIPanGestureRecognizer *)panGesture
{
	//	get the translation of the pan in the superview of the view
	CGPoint translation						= [panGesture translationInView:panGesture.view.superview];
	
	switch (panGesture.state)
	{
		case UIGestureRecognizerStateBegan:
			self.interactionInProgress		= YES;
			[self.navigationController popViewControllerAnimated:YES];
			break;
		case UIGestureRecognizerStateChanged:
		{
			//	get current progress through transition
			CGFloat fraction				= - (translation.x / 200.0f);
			fraction						= fminf(fmaxf(fraction, 0.0f), 1.0f);
			
			//	are we far enough to complete?
			self.shouldCompleteTransition	= fraction > 0.5f;
			
			//	update completion percentage of the animation
			[self updateInteractiveTransition:fraction];
			
			break;
		}
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			self.interactionInProgress		= NO;
			if (!self.shouldCompleteTransition || panGesture.state == UIGestureRecognizerStateCancelled)
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
 *	@param	view							The view which requires the gesture recogniser.
 */
- (void)prepareGestureRecogniserInView:(UIView *)view
{
	UIPanGestureRecognizer *panGesture		= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
	[view addGestureRecognizer:panGesture];
}

/**
 *	Attaches this interaction controller to the given view controller.
 *
 *	@param	viewController					The View controller to be attached to this interaction controller.
 */
- (void)wireToViewController:(UIViewController *)viewController
{
	self.navigationController				= viewController.navigationController;
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
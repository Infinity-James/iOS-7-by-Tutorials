//
//  BouncePresentAnimationController.m
//  ILoveCatz
//
//  Created by James Valaitis on 26/09/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "BouncePresentAnimationController.h"

#pragma mark - Bounce Present Animation Controller Implementation

@implementation BouncePresentAnimationController {}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

/**
 *	Performs a custom view controller transition animation.
 *
 *	@param	transitionContext			The context object containing information about the transition.
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	NSLog(@"BATTERY LEVEL: %f", [UIDevice currentDevice].batteryLevel);
	NSLog(@"ID: %@", [UIDevice currentDevice].identifierForVendor);
	NSLog(@"LOCALISED MODEL: %@", [UIDevice currentDevice].localizedModel);
	NSLog(@"MODEL: %@", [UIDevice currentDevice].model);
	NSLog(@"SYSTEM NAME: %@", [UIDevice currentDevice].systemName);
	NSLog(@"SYSTEM VERSION: %@", [UIDevice currentDevice].systemVersion);
	
	//	obtain state from context
	UIViewController *toViewController	= [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIViewController *fromViewController= [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	CGRect finalFrame					= [transitionContext finalFrameForViewController:toViewController];
	
	//	obtain the container view and 'to view'
	UIView *containerView				= [transitionContext containerView];
	UIView *toView						= toViewController.view;
	
	//	place the 'toViewController' outside of the screen
	CGRect screenBounds					= [UIScreen mainScreen].bounds;
	toView.frame						= CGRectOffset(finalFrame, 0.0f, screenBounds.size.height);
	
	//	add the view
	[containerView addSubview:toView];
	
	//	animate it all
	NSTimeInterval animationDuration	= [self transitionDuration:transitionContext];
	
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
		 usingSpringWithDamping:0.6f
		  initialSpringVelocity:0.0f
						options:UIViewAnimationOptionCurveLinear
					 animations:
	^{
		fromViewController.view.alpha	= 0.5f;
		toView.frame					= finalFrame;
	}
					 completion:^(BOOL finished)
	{
		fromViewController.view.alpha	= 1.0f;
		[transitionContext completeTransition:YES];
	}];
}

/**
 *	Called when the system needs the duration, in seconds, of the transition animation.
 *
 *	@param	transitionContext			The context object containing information to use during the transition.
 *
 *	@return	The duration, in seconds, of your custom transition animation.
 */
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return 0.5f;
}

@end
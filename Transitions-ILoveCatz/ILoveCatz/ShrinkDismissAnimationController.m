//
//  ShrinkDismissAnimationController.m
//  ILoveCatz
//
//  Created by James Valaitis on 01/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "ShrinkDismissAnimationController.h"

#pragma mark - Shrink Dismiss Animation Controller Implementation

@implementation ShrinkDismissAnimationController {}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

/**
 *	Performs a custom view controller transition animation.
 *
 *	@param	transitionContext			The context object containing information about the transition.
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	//	obtain state from context
	UIViewController *toViewController	= [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIViewController *fromViewController= [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	CGRect finalFrame					= [transitionContext finalFrameForViewController:toViewController];
	
	//	obtain the container view, 'to view' and 'from view'
	UIView *containerView				= [transitionContext containerView];
	UIView *fromView					= fromViewController.view;
	UIView *toView						= toViewController.view;
	
	//	the to view controller will be stationary so we set it's position
	toView.frame						= finalFrame;
	toView.alpha						= 0.5f;
	
	//	add view to container view
	[containerView addSubview:toView];
	[containerView sendSubviewToBack:toView];
	
	//	determine frames
	CGRect screenBounds					= [UIScreen mainScreen].bounds;
	CGRect shrunkenFrame				= CGRectInset(fromView.frame, fromView.frame.size.width / 4.0f, fromView.frame.size.height / 4.0f);
	CGRect fromFinalFrame				= CGRectOffset(shrunkenFrame, 0.0f, screenBounds.size.height);
	
	//	create a snapshot
	UIView *intermediateView			= [fromView snapshotViewAfterScreenUpdates:NO];
	intermediateView.frame				= fromView.frame;
	
	//	add	snapshot view and remove real view
	[containerView addSubview:intermediateView];
	//[fromView removeFromSuperview];
	fromView.hidden						= YES;
	
	//	animate it all
	NSTimeInterval animationDuration	= [self transitionDuration:transitionContext];
	
	[UIView animateKeyframesWithDuration:animationDuration
								   delay:0.0f
								 options:UIViewKeyframeAnimationOptionCalculationModeCubic
							  animations:
	^{
		[UIView addKeyframeWithRelativeStartTime:0.0f
								relativeDuration:0.5f
									  animations:
		^{
			intermediateView.frame		= shrunkenFrame;
		}];
		[UIView addKeyframeWithRelativeStartTime:0.5f
								relativeDuration:0.5f
									  animations:
		^{
			intermediateView.frame		= fromFinalFrame;
			toView.alpha				= 1.0f;
		}];
	}
							  completion:^(BOOL finished)
	{
		fromView.hidden					= NO;
		//	remove intermediate view
		[intermediateView removeFromSuperview];
		[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
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
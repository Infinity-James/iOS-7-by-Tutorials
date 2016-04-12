//
//  FlipAnimationController.m
//  ILoveCatz
//
//  Created by James Valaitis on 01/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "FlipAnimationController.h"

#pragma mark - Flip Animation Controller Private Class Extension

@interface FlipAnimationController () {}

#pragma mark - Private Properties

@end

#pragma mark - Flip Animation Controller Implementation

@implementation FlipAnimationController {}

#pragma mark - Convenience & Helper Methods

/**
 *	Convenient way to get a transform for a given angle.
 *
 *	@param	angle						The rotation around the y axis to get the angle for.
 *
 *	@return	A CATransform3D for the given rotation.
 */
- (CATransform3D)yRotation:(CGFloat)angle
{
	return CATransform3DMakeRotation(angle, 0.0f, 1.0f, 0.0f);
}

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
	
	//	obtain the container view, 'to view' and 'from view'
	UIView *containerView				= [transitionContext containerView];
	UIView *fromView					= fromViewController.view;
	UIView *toView						= toViewController.view;
	
	//	add view to container view
	[containerView addSubview:toView];
	
	//	add a perspective transform
	CATransform3D transform				= CATransform3DIdentity;
	transform.m34						= -0.002f;
	containerView.layer.sublayerTransform	= transform;
	
	//	give both views the same start frame
	CGRect initialFrame					= [transitionContext initialFrameForViewController:fromViewController];
	fromView.frame						= initialFrame;
	toView.frame						= initialFrame;
	
	//	do we reverse the animation?
	CGFloat factor						= self.reverse ? 1.0f : -1.0f;
	
	//	flip the view controller half way, hiding it
	toView.layer.transform				= [self yRotation:factor * -M_PI_2];
	
	//	animate it all
	NSTimeInterval animationDuration	= [self transitionDuration:transitionContext];
	
	[UIView animateKeyframesWithDuration:animationDuration
								   delay:0.0f
								 options:kNilOptions
							  animations:
	^{
		[UIView addKeyframeWithRelativeStartTime:0.0f
								relativeDuration:0.5f
									  animations:
		^{
			//	rotate the from view
			fromView.layer.transform		= [self yRotation:factor * M_PI_2];
		}];
		[UIView addKeyframeWithRelativeStartTime:0.5f
								relativeDuration:0.5f
									  animations:
		^{
			//	rotate the from view
			toView.layer.transform		= [self yRotation:0.0f];
		}];
	}
							  completion:^(BOOL finished)
	{
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
	return 1.0f;
}

@end
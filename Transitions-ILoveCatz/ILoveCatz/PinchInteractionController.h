//
//  PinchInteractionController.h
//  ILoveCatz
//
//  Created by James Valaitis on 02/10/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#pragma mark - Pinch Interaction Controller Public Interface

@interface PinchInteractionController : UIPercentDrivenInteractiveTransition {}

#pragma mark - Public Properties

/**	Whether or not an interaction is currently taking place.	*/
@property (nonatomic, assign)	BOOL		interactionInProgress;

#pragma mark - Public Methods

/**
 *	Attaches this interaction controller to the given view controller.
 *
 *	@param	viewController					The View controller to be attached to this interaction controller.
 */
- (void)wireToViewController:(UIViewController *)viewController;

@end
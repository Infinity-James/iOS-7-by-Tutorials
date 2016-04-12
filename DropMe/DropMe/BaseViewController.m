//
//  BaseViewController.m
//  DropMe
//
//  Created by James Valaitis on 27/11/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "NSString+Additions.h"

#pragma mark - Base View Controller Private Class Extension

@interface BaseViewController () {}

@end

#pragma mark - Base View Controller Implementation

@implementation BaseViewController {}

#pragma mark - Action Button

/**
 *	This message has been sent because the user has tapped the button to share object.
 *
 *	@param	actionButton				The button sending this message.
 */
- (void)actionButtonTapped:(UIBarButtonItem *)actionButton
{
	[self presentActivityViewControllerWithObjects:self.objectsToShare];
    
    [NSString ordersFilledForMaxLength:10 withLengths:@[@(5), @(10), @(3), @(11)]];
}

/**
 *	Create UIBarButtonItem for an action and display it in the navigation bar.
 */
- (void)displayActionButton
{
	UIBarButtonItem *actionButton		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				   target:self
																				   action:@selector(actionButtonTapped:)];
	[self.navigationItem setLeftBarButtonItem:actionButton animated:YES];
}

/**
 *	Removes the action bar button item.
 */
- (void)hideActionButton
{
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark - Acitivity Controller Management

/**
 *	Present an instance of the UIActivityViewController for Airdrop.
 *
 *	@param	objects						The objects to display in the UIActivityViewController.
 */
- (void)presentActivityViewControllerWithObjects:(NSArray *)objects
{
	//	create instance of UIActivityViewController
	UIActivityViewController *activityVC= [[UIActivityViewController alloc] initWithActivityItems:objects applicationActivities:nil];
	
	//	exclude all activities except airdrop
	activityVC.excludedActivityTypes	= @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard,
											UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr,
											UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo,
											UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
	
	//	present it
	[self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	An array of objects to be shared via Airdrop.
 *
 *	@param	objectsToShare				An array of objects to be shared via Airdrop.
 */
- (void)setObjectsToShare:(NSArray *)objectsToShare
{
	_objectsToShare						= [objectsToShare copy];
	
	if (_objectsToShare.count)
		[self displayActionButton];
	else
		[self hideActionButton];
}

@end
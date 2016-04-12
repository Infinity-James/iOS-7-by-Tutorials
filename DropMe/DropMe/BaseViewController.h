//
//  BaseViewController.h
//  DropMe
//
//  Created by James Valaitis on 27/11/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#pragma mark - Base View Controller Public Interface

@interface BaseViewController : UIViewController {}

#pragma mark - Public Properties

/**	An array of objects to be shared via Airdrop.	*/
@property (nonatomic, copy)		NSArray		*objectsToShare;

@end
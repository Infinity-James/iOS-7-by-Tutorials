//
//  MasterViewController.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "AppDelegate.h"
#import "BouncePresentAnimationController.h"
#import "Cat.h"
#import "DetailViewController.h"
#import "FlipAnimationController.h"
#import "MasterViewController.h"
#import "PinchInteractionController.h"
#import "ShrinkDismissAnimationController.h"
#import "SwipeInteractionController.h"

@interface MasterViewController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate> {}

/**	The controller of the bounce animation transitions.	*/
@property (nonatomic, strong)	BouncePresentAnimationController	*bounceAnimationController;
/**	The controller of the flip navigation animation transitions.	*/
@property (nonatomic, strong)	FlipAnimationController				*flipAnimationController;
/**	The controller of interactive animation dismissals.	*/
@property (nonatomic, strong)	PinchInteractionController			*pinchInteractionController;
/**	The controller of shrink animation transitions.	*/
@property (nonatomic, strong)	ShrinkDismissAnimationController	*shrinkAnimationController;
/**	The controller of interactive navigation animation transitions.	*/
@property (nonatomic, strong)	SwipeInteractionController			*swipeInteractionController;

@end

@implementation MasterViewController

- (NSArray *)cats {
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).cats;
}

/**
 *	Called after the controller’s view is loaded into memory.
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	see a cat image as a title
    UIImageView* imageView				= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat"]];
    self.navigationItem.titleView		= imageView;
	
	self.navigationController.delegate	= self;
}

/**
 *	Returns an object initialized from data in a given unarchiver.
 *
 *	@param	aDecoder					An unarchiver object.
 *
 *	@return	self, initialized using the data in decoder.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		self.bounceAnimationController	= [[BouncePresentAnimationController alloc] init];
		self.flipAnimationController	= [[FlipAnimationController alloc] init];
		self.pinchInteractionController	= [[PinchInteractionController alloc] init];
		self.shrinkAnimationController	= [[ShrinkDismissAnimationController alloc] init];
		self.swipeInteractionController	= [[SwipeInteractionController alloc] init];
	}
	
	return self;
}

#pragma mark - UINavigationControllerDelegate Methods

/**
 *	Called to allow the delegate to return a noninteractive animator object for use during view controller transitions.
 *
 *	@param	navigationController		The navigation controller whose navigation stack is changing.
 *	@param	operation					The type of transition operation that is occurring.
 *	@param	fromViewController			The currently visible view controller.
 *	@param	toViewController			The view controller that should be visible at the end of the transition.
 *
 *	@return	The animator object responsible for managing the transition animations, or nil to use the standard navigation controller transitions.
 */
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								   animationControllerForOperation:(UINavigationControllerOperation)operation
												fromViewController:(UIViewController *)fromViewController
												  toViewController:(UIViewController *)toViewController
{
	self.flipAnimationController.reverse= operation == UINavigationControllerOperationPop;
	if (operation == UINavigationControllerOperationPush)
		[self.swipeInteractionController wireToViewController:toViewController];
	return self.flipAnimationController;
}

/**
 *	Called to allow the delegate to return an interactive animator object for use during view controller transitions.
 *
 *	@param	navigationController		The navigation controller whose navigation stack is changing.
 *	@param	animationController			The noninteractive animator object provided by the delegate.
 *
 *	@return	The animator object responsible for managing the transition animations, or nil to use the standard navigation controller transitions.
 */
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
						  interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
	return self.swipeInteractionController.interactionInProgress ? self.swipeInteractionController : nil;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

/**
 *	Called when a transition requires the animator object to use when dismissing a view controller.
 *
 *	@param	dismissed					The view controller object that is about to be dismissed.
 *
 *	@return	The animator object to use when dismissing the view controller or nil if you do not want to dismiss using a custom transition.
 */
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	return self.shrinkAnimationController;
}

/**
 *	Called when a transition requires the animator object to use when presenting a view controller.
 *
 *	@param	presented					The view controller object that is about to be presented onscreen.
 *	@param	presenting					The view controller object that represents the current context for presentation.
 *	@param	source						The view controller whose presentViewController:animated:completion: method was called.
 *
 *	@return	The animator object to use when presenting the view controller or nil if you don't want to present using a custom transition.
 */
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																   presentingController:(UIViewController *)presenting
																	   sourceController:(UIViewController *)source
{
	return self.bounceAnimationController;
}

/**
 *	Called when a transition requires the animator object that can manage an interactive transition when dismissing a view controller.
 *
 *	@param	animator					The standard animator object being used to manage the transition.
 *
 *	@return	The animator object that implements the code needed specifically to manage interactive transitions.
 */
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
	return self.pinchInteractionController.interactionInProgress ? self.pinchInteractionController : nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self cats].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Cat* cat = [self cats][indexPath.row];
    cell.textLabel.text = cat.title;
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        // find the tapped cat
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Cat *cat = [self cats][indexPath.row];
        
        // provide this to the detail view
        [[segue destinationViewController] setCat:cat];
    }
	
	if ([segue.identifier isEqualToString:@"ShowAbout"])
	{
		UIViewController *toVC		= segue.destinationViewController;
		[self.pinchInteractionController wireToViewController:toVC];
		toVC.transitioningDelegate	= self;
	}
}

@end

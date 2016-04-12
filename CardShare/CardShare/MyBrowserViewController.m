//
//  MyBrowserViewController.m
//  GreatExchange
//
//  Created by Christine Abernathy on 7/1/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "MyBrowserViewController.h"
#import "AppDelegate.h"
#import "MyBrowserTableViewCell.h"
@import ObjectiveC;

@import MultipeerConnectivity;

@interface MyBrowserViewController ()
<MCNearbyServiceBrowserDelegate, UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *nearbyPeers;
@property (strong, nonatomic) NSMutableArray *acceptedPeers;
@property (strong, nonatomic) NSMutableArray *declinedPeers;

/**	*/
@property (nonatomic, strong)	MCNearbyServiceBrowser		*browser;
/**	*/
@property (nonatomic, strong)	MCPeerID					*peerID;
/**	*/
@property (nonatomic, strong)	NSString					*serviceType;
/**	*/
@property (nonatomic, strong)	MCSession					*session;

@end

@implementation MyBrowserViewController

#pragma mark Initialization methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Default maximum and minimum number of
        // peers allowed in a session
        self.maximumNumberOfPeers = 8;
        self.minimumNumberOfPeers = 2;
    }
	
    return self;
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)setupWithServiceType:(NSString *)serviceType session:(MCSession *)session peer:(MCPeerID *)peerID
{
	self.peerID							= peerID;
	self.serviceType					= serviceType;
	self.session						= session;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set the toolbar delegate to be able
    // to position it to the top of the view.
    self.toolbar.delegate = self;
    
    self.nearbyPeers = [@[] mutableCopy];
    self.acceptedPeers = [@[] mutableCopy];
    self.declinedPeers = [@[] mutableCopy];
    
    [self showDoneButton:NO];
	
	self.browser						= [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:self.serviceType];
	self.browser.delegate				= self;
	[self.browser startBrowsingForPeers];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerConnected:)
												 name:PeerConnectionAcceptedNotification
											   object:nil];
}

/**
 *	Notifies the view controller that its view is about to be removed from a view hierarchy.
 *
 *	@param	animated					If YES, the disappearance of the view is being animated.
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIToolbarDelegate methods
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
    
}

#pragma mark - Helper methods
- (void)showDoneButton:(BOOL)display
{
    NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
    if (display) {
        // Show the done button
        if (![toolbarButtons containsObject:self.doneButton]) {
            [toolbarButtons addObject:self.doneButton];
            [self.toolbar setItems:toolbarButtons animated:NO];
        }
    } else {
        // Hide the done button
        [toolbarButtons removeObject:self.doneButton];
        [self.toolbar setItems:toolbarButtons animated:NO];
    }
}

#pragma mark - Action methods

- (IBAction)cancelButtonPressed:(id)sender {
    // Send the delegate a message that the controller was canceled.
    if ([self.delegate respondsToSelector:@selector(myBrowserViewControllerWasCancelled:)]) {
        [self.delegate myBrowserViewControllerWasCancelled:self];
    }
	
	[self.browser stopBrowsingForPeers];
	self.browser.delegate				= nil;
}

- (IBAction)doneButtonPressed:(id)sender {
    // Send the delegate a message that the controller was done browsing.
    if ([self.delegate respondsToSelector:@selector(myBrowserViewControllerDidFinish:)]) {
        [self.delegate myBrowserViewControllerDidFinish:self];
    }
	
	[self.browser stopBrowsingForPeers];
	self.browser.delegate				= nil;
}

- (void)peerConnected:(NSNotification *)notification
{
	MCPeerID *peerID					= notification.userInfo[@"peer"];
	BOOL nearbyDeviceDecision			=[notification.userInfo[@"accept"] boolValue];
	
	if (nearbyDeviceDecision)
		[self.acceptedPeers addObject:peerID];
	else
		[self.declinedPeers addObject:peerID];
	
	if (self.acceptedPeers.count >= self.maximumNumberOfPeers - 1)
		[self doneButtonPressed:nil];
	else
	{
		if (self.acceptedPeers.count < self.minimumNumberOfPeers - 1)
			[self showDoneButton:NO];
		else
			[self showDoneButton:YES];
		
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyPeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyDevicesCell";
    MyBrowserTableViewCell *cell = (MyBrowserTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyBrowserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
	
	MCPeerID *peerID				= self.nearbyPeers[indexPath.row];
	
	if ([self.acceptedPeers containsObject:peerID])
	{
		if ([cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]])
			[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
		
		UILabel *checkmarkLabel		= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
		checkmarkLabel.text			= @"✓";
		cell.accessoryView			= checkmarkLabel;
	}
	else if ([self.declinedPeers containsObject:peerID])
	{
		if ([cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]])
			[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
		
		UILabel *declineLabel		= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
		declineLabel.text			= @"X";
		cell.accessoryView			= declineLabel;
	}
	else
	{
		UIActivityIndicatorView *activityIndicatorView	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicatorView.hidesWhenStopped			= YES;
		activityIndicatorView.color						= ((AppDelegate *)[UIApplication sharedApplication].delegate).mainColor;
		[activityIndicatorView startAnimating];
		cell.accessoryView								= activityIndicatorView;
		
		[self.browser invitePeer:peerID
					   toSession:self.session
					 withContext:[@"Making Contact" dataUsingEncoding:NSUTF8StringEncoding]
						 timeout:10.0f];
	}
	
	cell.textLabel.text				= peerID.displayName;
    
    return cell;
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
	NSLog(@"Errow when attempting to browse: %@", error);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
	[self.nearbyPeers addObject:peerID];
	[self.tableView reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
	[self.nearbyPeers removeObject:peerID];
	[self.acceptedPeers removeObject:peerID];
	[self.declinedPeers removeObject:peerID];
	
	if (self.acceptedPeers.count < (self.minimumNumberOfPeers - 1))
		[self showDoneButton:NO];
	
	[self.tableView reloadData];
}

@end

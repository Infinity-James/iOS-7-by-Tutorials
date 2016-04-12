//
//  AppDelegate.m
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "AppDelegate.h"

NSString *const DataReceivedNotification			= @"com.razeware.apps.CardShare:DataReceivedNotification";
NSString *const kServiceType						= @"rw-cardshare";
NSString *const	PeerConnectionAcceptedNotification	= @"com.razeware.apps.CardShare:PeerConnectionAcceptedNotification";

NSString *const SecretCodeKey						= @"secretCode";
static NSUInteger const SecretCodeValue				= 4456;

BOOL const kProgrammaticDiscovery		= YES;

typedef void(^InvitationHandler)(BOOL accept, MCSession *session);

@interface AppDelegate () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, UIAlertViewDelegate> {}

/**	*/
@property (nonatomic, strong)		MCNearbyServiceAdvertiser	*advertiser;
/**	*/
@property (nonatomic, strong)		MCAdvertiserAssistant		*advertiserAssistant;
/**	*/
@property (nonatomic, copy)			InvitationHandler			handler;

@end

@implementation AppDelegate {}

#pragma mark - UIApplicationDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set appearance info
    [[UITabBar appearance] setBarTintColor:[self mainColor]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[self mainColor]];
    
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UIToolbar appearance] setBarTintColor:[self mainColor]];
    
    // Initialize properties
    self.cards = [@[] mutableCopy];
    
    // Initialize any stored data
    self.myCard = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"myCard"]) {
        NSData *myCardData = [defaults objectForKey:@"myCard"];
        self.myCard = (Card *)[NSKeyedUnarchiver unarchiveObjectWithData:myCardData];
    }
    self.otherCards = [@[] mutableCopy];
    if ([defaults objectForKey:@"otherCards"]) {
        NSData *otherCardsData = [defaults objectForKey:@"otherCards"];
        self.otherCards = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:otherCardsData];
    }
	
	//	create peer id with appropriate name
	NSString *peerName					= self.myCard.firstName ? self.myCard.firstName : [[UIDevice currentDevice] name];
	self.peerID							= [[MCPeerID alloc] initWithDisplayName:peerName];
	//	initialise session
	self.session						= [[MCSession alloc] initWithPeer:self.peerID
									   securityIdentity:nil
								   encryptionPreference:MCEncryptionNone];
	self.session.delegate				= self;
	NSDictionary *info					= @{SecretCodeKey	: @(SecretCodeValue)};
	
	if (kProgrammaticDiscovery)
	{
		self.advertiser					= [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
																discoveryInfo:info
																  serviceType:kServiceType];
		self.advertiser.delegate		= self;
		[self.advertiser startAdvertisingPeer];
	}
	else
	{
		self.advertiserAssistant		= [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType
																		 discoveryInfo:info
																			   session:self.session];
		[self.advertiserAssistant start];
	}
    
    return YES;
}

#pragma mark - Helper methods
- (UIColor *)mainColor
{
    return [UIColor colorWithRed:28/255.0f green:171/255.0f blue:116/255.0f alpha:1.0f];
}

/*
 * Implement the setter for the user's card
 * so as to set the value in storage as well.
 */
- (void)setMyCard:(Card *)aCard
{
    if (aCard != _myCard) {
        _myCard = aCard;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Create an NSData representation
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aCard];
        [defaults setObject:data forKey:@"myCard"];
        [defaults synchronize];
    }
}

- (void)addToOtherCardsList:(Card *)card
{
    [self.otherCards addObject:card];
    // Update stored value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.otherCards];
    [defaults setObject:data forKey:@"otherCards"];
    [defaults synchronize];
}

- (void) removeCardFromExchangeList:(Card *)card
{
    NSMutableSet *cardsSet = [NSMutableSet setWithArray:self.cards];
    [cardsSet removeObject:card];
    self.cards = [[cardsSet allObjects] mutableCopy];
}

/**
 *	Sends the user's card to connected peers.
 */
- (void)sendCardToPeer
{
	NSData *data						= [NSKeyedArchiver archivedDataWithRootObject:self.myCard];
	NSError *error;
	[self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
	   withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
	self.handler						= invitationHandler;
	
	[[[UIAlertView alloc] initWithTitle:@"Invitation"
							   message:[[NSString alloc] initWithFormat:@"%@ wants to connect.", peerID.displayName]
							   delegate:self
					  cancelButtonTitle:@"Nope"
					  otherButtonTitles:@"Sure", nil] show];
}

#pragma mark - MCSessionDelegate Methods

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
	Card *card							= [NSKeyedUnarchiver unarchiveObjectWithData:data];
	[self.cards addObject:card];
	[[NSNotificationCenter defaultCenter] postNotificationName:DataReceivedNotification object:nil];
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
	
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
	
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
	
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
	if (self.session)
		switch (state)
		{
			case MCSessionStateConnected:
				[[NSNotificationCenter defaultCenter] postNotificationName:PeerConnectionAcceptedNotification
																	object:nil
																  userInfo:@{@"peer"	: peerID,
																			 @"accept"	: @YES}];
				break;
			case MCSessionStateConnecting:	break;
			case MCSessionStateNotConnected:
				[[NSNotificationCenter defaultCenter] postNotificationName:PeerConnectionAcceptedNotification
																	object:nil
																  userInfo:@{@"peer"	: peerID,
																			 @"accept"	: @NO}];
				
		}
}

#pragma mark - UIAlertViewDelegate Methods

/**
 *	Sent to the delegate when the user clicks a button on an alert view
 *
 *	@param	alertView					The alert view containing the button.
 *	@param	buttonIndex					The index of the button that was clicked.
 */
- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	BOOL accept							= !(buttonIndex == alertView.cancelButtonIndex);
	
	self.handler(accept, self.session);
}

@end
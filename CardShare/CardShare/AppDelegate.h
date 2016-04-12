//
//  AppDelegate.h
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

@import MultipeerConnectivity;
#import "Card.h"

extern NSString *const DataReceivedNotification;
extern NSString *const kServiceType;
extern NSString *const PeerConnectionAcceptedNotification;
extern BOOL const kProgrammaticDiscovery;
extern NSString *const SecretCodeKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) Card *myCard;
@property (strong, nonatomic) NSMutableArray *otherCards;

/**	*/
@property (nonatomic, strong)		MCPeerID		*peerID;
/**	*/
@property (nonatomic, strong)		MCSession		*session;

- (void) addToOtherCardsList:(Card *)card;
- (void) removeCardFromExchangeList:(Card *)card;
- (UIColor *) mainColor;
/**
 *	Sends the user's card to connected peers.
 */
- (void)sendCardToPeer;

@end

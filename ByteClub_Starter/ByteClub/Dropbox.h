//
//  Dropbox.h
//  ByteClub
//
//  Created by Charlie Fulton on 7/26/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#pragma mark - Constants & Static Variables - OAuth

extern NSString *const oauthTokenKey;
extern NSString *const oauthTokenKeySecret;
extern NSString *const requestToken;
extern NSString *const requestTokenSecret;
extern NSString *const accessToken;
extern NSString *const accessTokenSecret;
extern NSString *const dropboxUIDKey;
extern NSString *const dropboxTokenReceivedNotification;

#pragma mark - Constants & Static Variables - Dropbox Directories

extern NSString *const appFolder;

/**	A block called upon the completion of a token fetch.	*/
typedef void (^DropboxRequestTokenCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);

#pragma mark - Dropbox Public Interface

@interface Dropbox : NSObject

/**
 *	Returns a header to be used for autohorisation in a request.
 *
 *	@return	An NSString to be used as a header in an NSURLRequest for authorisation.
 */
+ (NSString *)apiAuthorizationHeader;
/**
 *	A url pointing to the root Dropbox directory for this app.
 *
 *	@return	An NSURL for the location of the root directory for this app.
 */
+ (NSURL *)appRootURL;
/**
 *	Creates a URL to be used for uploading a photo to Dropbox.
 *
 *	@return	An NSURL to be used for uploading a photo.
 */
+ (NSURL *)createPhotoUploadURL;
/**
 *	Returns a dictionary of the OAuth tokens extracted from the response.
 *
 *	@param	response					The response holding the tokens.
 *
 *	@return	A dictionary holding the OAuth tokens from the response.
 */
+ (NSDictionary *)dictionaryFromOAuthResponseString:(NSString *)response;
/**
 *	Requests the access token assuming a request token has been retrieved.
 *
 *	@param	completionBlock				A block called upon completion of the token request.
 */
+ (void)exchangeTokenForUserAccessTokenURLWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock;
/**
 *	Asynchronously fetches a request token for Dropbox.
 *
 *	@param	completionBlock				A block called upon completion of the token request.
 */
+ (void)requestTokenWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock;
/**
 *	Returns a URL to use for uploading to a specific path in the Dropbox folder.
 *
 *	@param	path						The path with which the URL must pertain.
 *
 *	@return	An NSURL to use for uploading to a specific path.
 */
+ (NSURL *)uploadURLForPath:(NSString *)path;

@end
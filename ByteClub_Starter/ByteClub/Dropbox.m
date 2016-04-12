//
//  Dropbox.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/26/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "Dropbox.h"

#pragma mark - Constants & Static Variables - API Keys

static NSString *const apiKey			= @"1167nw8iqjgxnus";
static NSString *const appSecret		= @"bljrzhk6o6gz5kz";

#pragma mark - Constants & Static Variables - Dropbox Directories

NSString *const appFolder				= @"GrabAByte";

#pragma mark - Constants & Static Variables - Dropbox OAuth Tokens

NSString *const oauthTokenKey			= @"oauth_token";
NSString *const oauthTokenKeySecret		= @"oauth_token_secret";
NSString *const dropboxUIDKey			= @"uid";

#pragma mark - Constants & Static Variables - Notification Keys

NSString *const dropboxTokenReceivedNotification	= @"have_user_request_token";

#pragma mark - Constants & Static Variables - NSUserDefaults Keys

NSString *const requestToken			= @"requestToken";
NSString *const requestTokenSecret		= @"requestTokenSecret";

NSString *const accessToken				= @"accessToken";
NSString *const accessTokenSecret		= @"accessTokenSecret";

#pragma mark - Dropbox Implementation

@implementation Dropbox

#pragma mark - Token Fetching

/**
 *	Requests the access token assuming a request token has been retrieved.
 *
 *	@param	completionBlock				A block called upon completion of the token request.
 */
+ (void)exchangeTokenForUserAccessTokenURLWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock
{
	//	create the request token url
    NSString *urlString					= [[NSString alloc] initWithFormat:@"https://api.dropbox.com/1/oauth/access_token?"];
    NSURL *requestTokenURL				= [[NSURL alloc] initWithString:urlString];
    
	//	get the request token and secret from the user defaults
    NSString *reqToken					= [[NSUserDefaults standardUserDefaults] valueForKey:requestToken];
    NSString *reqTokenSecret			= [[NSUserDefaults standardUserDefaults] valueForKey:requestTokenSecret];
    
	
    NSString *authorizationHeader		= [self plainTextAuthorizationHeaderForAppKey:apiKey
																	   appSecret:appSecret
																		   token:reqToken
																	 tokenSecret:reqTokenSecret];
    
	//	gets a copy of the default session configuration and adds the header
    NSURLSessionConfiguration *config	= [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{@"Authorization": authorizationHeader}];
    
    NSMutableURLRequest *request		= [[NSMutableURLRequest alloc] initWithURL:requestTokenURL];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session				= [NSURLSession sessionWithConfiguration:config];
    [[session dataTaskWithRequest:request completionHandler:completionBlock] resume];
}

/**
 *	Asynchronously fetches a request token for Dropbox.
 *
 *	@param	completionBlock				A block called upon completion of the token request.
 */
+ (void)requestTokenWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock
{
	//	gets the authorisation header for the request
    NSString *authorizationHeader		= [self plainTextAuthorizationHeaderForAppKey:apiKey
																	   appSecret:appSecret
																		   token:nil
																	 tokenSecret:nil];
    
	//	gets a copy of the default session configuration and adds the header
    NSURLSessionConfiguration *config	= [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{@"Authorization": authorizationHeader}];
    
	//	create the url request with the url for OAuth
    NSMutableURLRequest *request		= [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"https://api.dropbox.com/1/oauth/request_token"]];
    [request setHTTPMethod:@"POST"];
    
	//	creates the session with the pre-made configuration and executes the request on it
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [[session dataTaskWithRequest:request completionHandler:completionBlock] resume];
}

#pragma mark - Utilities: Authorisation

/**
 *	Returns a header to be used for autohorisation in a request.
 *
 *	@return	An NSString to be used as a header in an NSURLRequest for authorisation.
 */
+ (NSString *)apiAuthorizationHeader
{
    NSString *token						= [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSString *tokenSecret				= [[NSUserDefaults standardUserDefaults] valueForKey:accessTokenSecret];
	
    return [self plainTextAuthorizationHeaderForAppKey:apiKey
                                             appSecret:appSecret
                                                 token:token
                                           tokenSecret:tokenSecret];
}

/**
 *	Returns a dictionary of the OAuth tokens extracted from the response.
 *
 *	@param	response					The response holding the tokens.
 *
 *	@return	A dictionary holding the OAuth tokens from the response.
 */
+ (NSDictionary *)dictionaryFromOAuthResponseString:(NSString *)response
{
	//	split the reponse up into the array of tokens
    NSArray *tokens						= [response componentsSeparatedByString:@"&"];
    NSMutableDictionary *oauthDict		= [[NSMutableDictionary alloc] initWithCapacity:tokens.count];
    
	//	for each token we split it up into key and value and set the dictionary with them
    for(NSString *token in tokens)
	{
        NSArray *entry					= [token componentsSeparatedByString:@"="];
        NSString *key					= entry[0];
        NSString *value					= entry[1];
		oauthDict[key]					= value;
    }
    
    return [oauthDict copy];
}

/**
 *	Get an authorisation header in plain text for the given key, secret and token details.
 *
 *	@param	appKey						The key for this app.
 *	@param	appSecret					The secret for this app.
 *	@param	token						The token for the OAuth.
 *	@param	tokenSecret					The scret for the OAuth.
 *
 *	@return	A plain text authroisation header in the form of an NSString.
 */
+ (NSString *)plainTextAuthorizationHeaderForAppKey:(NSString *)appKey
										  appSecret:(NSString *)appSecret
											  token:(NSString *)token
										tokenSecret:(NSString *)tokenSecret
{
    // version, method, and oauth_consumer_key are always present
    NSString *header					= [[NSString alloc] initWithFormat:@"OAuth oauth_version=\"1.0\",oauth_signature_method=\"PLAINTEXT\",oauth_consumer_key=\"%@\"", apiKey];
    
    // look for oauth_token, include if one is passed in
    if (token)
        header							= [header stringByAppendingString:[[NSString alloc] initWithFormat:@",oauth_token=\"%@\"", token]];
    
    // add oauth_signature which is app_secret&token_secret , token_secret may not be there yet, just include @"" if it's not there
    header								= [header stringByAppendingString:[[NSString alloc] initWithFormat:@",oauth_signature=\"%@&%@\"",
																		   appSecret, tokenSecret ? tokenSecret : @""]];
    return header;
}

#pragma mark - Utilities: URLs

/**
 *	A url pointing to the root Dropbox directory for this app.
 *
 *	@return	An NSURL for the location of the root directory for this app.
 */
+ (NSURL *)appRootURL
{
    NSString *url						= [[NSString alloc] initWithFormat:@"https://api.dropbox.com/1/metadata/dropbox/%@", appFolder];
    NSLog(@"Listing files using URL: %@", url);
    return [[NSURL alloc] initWithString:url];
}

/**
 *	Creates a random URL to be used for uploading a photo to Dropbox.
 *
 *	@return	A unique NSURL to be used for uploading a photo.
 */
+ (NSURL *)createPhotoUploadURL
{
    NSString *urlWithParams				= [[NSString alloc] initWithFormat:@"https://api-content.dropbox.com/1/files_put/dropbox/%@/photos/byteclub_pano_%i.jpg", appFolder, arc4random() % 1000];
    NSURL *url							= [[NSURL alloc] initWithString:urlWithParams];
	
    return url;
}

/**
 *	Returns a URL to use for uploading to a specific path in the Dropbox folder.
 *
 *	@param	path						The path with which the URL must pertain.
 *
 *	@return	An NSURL to use for uploading to a specific path.
 */
+ (NSURL *)uploadURLForPath:(NSString *)path
{
    NSString *urlWithParams				= [[NSString alloc] initWithFormat:@"https://api-content.dropbox.com/1/files_put/dropbox/%@/%@",
										   appFolder, [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url							= [[NSURL alloc] initWithString:urlWithParams];
	
    return url;
}

@end

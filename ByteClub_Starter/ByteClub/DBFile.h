//
//  DBFile.h
//  DropShare
//
//  Created by Charles Fulton on 7/11/13.
//  Copyright (c) 2013 RayWenderlich.com. All rights reserved.
//

#pragma mark - Type Definitions

/**	A block called upon the completion of a thumbnail fetch.	*/
typedef void(^ThumbnailCompletionBlock)();

#pragma mark - Dropbox File Public Interface

@interface DBFile : NSObject {}

/**	The path of this file.	*/
@property (nonatomic, strong)		NSString		*path;
/**	The root direcotry for this file	*/
@property (nonatomic, strong)		NSString		*root;
/**	Whether or not a thumbnail exists for this file.	*/
@property (atomic, assign)			BOOL			thumbExists;
/**	The last modification date for this file.	*/
@property (nonatomic, strong)		NSDate			*modified;
/**	The contents of this file.	*/
@property (nonatomic, strong)		NSString		*contents;
/**	The MIME type for this file.	*/
@property (nonatomic, strong)		NSString		*mimeType;
/**	The thumbnail for this file if one exists.	*/
@property (nonatomic, strong)		UIImage			*thumbnail;


#pragma mark - Public Methods

/**
 *	Indicates the modified date of the receiver compared to the given DBFile, or whether the files are the same.
 *
 *	@param	otherFile					The other file
 *
 *	@return	An NSComparisonResult indicating if the file is identical, or the relationship between the modified dates of the files.
 */
- (NSComparisonResult)compare:(DBFile *)otherFile;
/**
 *	Get the name of this file with or without the extension.
 *
 *	@param	showExtension				Whether to return the filename with the extension or not.
 *
 *	@return	An NSString with this file's name either with or without the extension.
 */
- (NSString *)fileNameShowExtension:(BOOL)showExtension;
/**
 *	Implemented by subclasses to initialize a new file object with the given data.
 *
 *	@param	data						The JSON data with which to initialise this file.
 *
 *	@return	An initialized object.
 */
- (id)initWithJSONData:(NSDictionary*)data;

@end

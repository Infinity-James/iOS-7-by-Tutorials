//
//  DBFile.m
//  DropShare
//
//  Created by Charles Fulton on 7/11/13.
//  Copyright (c) 2013 RayWenderlich.com. All rights reserved.
//

#import "DBFile.h"
#import "Dropbox.h"

#pragma mark - Type Definitions

/**	A block called upon the completion of a file update.	*/
typedef void(^DBFileUpdateCompletionBlock)(DBFile* updatedFile);

#pragma mark - Dropbox File Implementation

@implementation DBFile

#pragma mark - File Identification

/**
 *	Indicates the modified date of the receiver compared to the given DBFile, or whether the files are the same.
 *
 *	@param	otherFile					The other file
 *
 *	@return	An NSComparisonResult indicating if the file is identical, or the relationship between the modified dates of the files.
 */
- (NSComparisonResult)compare:(DBFile *)otherFile
{
    NSComparisonResult order;
    
    // first compare modified
    order								= [otherFile.modified compare:self.modified];
    
    // if same modified alpha by path
    if (order == NSOrderedSame)
        order							= [otherFile.path compare:self.path];
    
    return order;
}

/**
 *	Returns a string that describes the contents of the receiver.
 *
 *	@return	A string that describes the contents of the receiver.
 */
- (NSString *)description
{
    return [NSString stringWithFormat:@"File from %@ %@", self.root, self.path];
}

/**
 *	Get the name of this file with or without the extension.
 *
 *	@param	showExtension				Whether to return the filename with the extension or not.
 *
 *	@return	An NSString with this file's name either with or without the extension.
 */
- (NSString *)fileNameShowExtension:(BOOL)showExtension
{
    NSString *path						= self.path;
    NSString *filePath					= [[path componentsSeparatedByString:@"/"] lastObject];
    if (!showExtension)
        filePath						= [[filePath componentsSeparatedByString:@"."] firstObject];
    
    return filePath;
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new file object with the given data.
 *
 *	@param	data						The JSON data with which to initialise this file.
 *
 *	@return	An initialized object.
 */
- (id)initWithJSONData:(NSDictionary*)data
{
    if (self = [super init])
	{
		//	get the properties from the JSON data
		self.path						= data[@"path"];
        self.root						= data[@"root"];
        self.thumbExists				= [data[@"thumb_exists"] boolValue];
        NSDateFormatter *formatter		= [[NSDateFormatter alloc] init];
        formatter.dateFormat			= @"EEE, dd MMM yyyy HH:mm:ss Z";
        NSDate *date					= [formatter dateFromString:data[@"modified"]];
        if (date)
            self.modified				= date;
        self.mimeType					= data[@"mime_type"];
    }
	
    return self;
}

@end

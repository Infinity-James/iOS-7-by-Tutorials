//
//  PhotosViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoCell.h"
#import "Dropbox.h"
#import "DBFile.h"

@interface PhotosViewController () <NSURLSessionTaskDelegate, UITableViewDelegate, UITableViewDataSource,
									UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *uploadView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *photoThumbnails;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong)	NSURLSessionUploadTask		*uploadTask;



@end

@implementation PhotosViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // 1
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // 2
        [config setHTTPAdditionalHeaders:@{@"Authorization": [Dropbox apiAuthorizationHeader]}];
        
        // 3
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self refreshPhotos];
}

- (void)refreshPhotos
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	NSString *photoDirectory			= [[NSString alloc] initWithFormat:@"https://api.dropbox.com/1/search/dropbox/%@/photos?query=.jpg",
										   appFolder];
	NSURL *url							= [[NSURL alloc] initWithString:photoDirectory];
	
	NSURLSessionDataTask *dataTask		= [self.session dataTaskWithURL:url
												  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
	{
		NSHTTPURLResponse *httpResponse	= (NSHTTPURLResponse *)response;
		if (error || httpResponse.statusCode != 200)
			return;
		
		NSError *jsonError;
		NSArray *filesJSON				= [NSJSONSerialization JSONObjectWithData:data
																options:NSJSONReadingAllowFragments
																  error:&jsonError];
		if (jsonError)					return;
		
		NSMutableArray *dropboxFiles	= [[NSMutableArray alloc] init];
		for (NSDictionary *fileMetadata in filesJSON)
			[dropboxFiles addObject:[[DBFile alloc] initWithJSONData:fileMetadata]];
		
		//	sort the photos
		[dropboxFiles sortUsingComparator:^NSComparisonResult(DBFile *fileA, DBFile *fileB)
		{
			return [fileA compare:fileB];
		}];
		
		self.photoThumbnails			= dropboxFiles;
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
			[self.tableView reloadData];
		});
	}];
	
	[dataTask resume];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDatasource and UITableViewDelegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_photoThumbnails count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DBFile *photo = _photoThumbnails[indexPath.row];
    
    if (!photo.thumbnail) {
        // only download if we are moving
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            if(photo.thumbExists) {
                NSString *urlString = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/thumbnails/dropbox%@?size=xl",photo.path];
                NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:encodedUrl];
                NSLog(@"logging this url so no warning in starter project %@",url);
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
                NSURLSessionDataTask *dataTask	= [self.session dataTaskWithURL:url
															 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
				{
					if (error)			return;
					
					UIImage *image		= [[UIImage alloc] initWithData:data];
					photo.thumbnail		= image;
					
					dispatch_async(dispatch_get_main_queue(),
					^{
						[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
						cell.thumbnailImage.image	= photo.thumbnail;
					});
				}];
                
				[dataTask resume];
            }
        }
    }
    
    // Configure the cell...
    return cell;
}

- (IBAction)choosePhoto:(UIBarButtonItem *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage:image];
}

// stop upload
- (IBAction)cancelUpload:(id)sender
{
    if (self.uploadTask.state == NSURLSessionTaskStateRunning)
		[self.uploadTask cancel];
}

- (void)uploadImage:(UIImage*)image
{
	NSData *imageData					= UIImageJPEGRepresentation(image, 0.6f);
	
	//
	NSURLSessionConfiguration *config	= [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPMaximumConnectionsPerHost= 1;
	config.HTTPAdditionalHeaders		= @{@"Authorization"	: [Dropbox apiAuthorizationHeader]};
	
	NSURLSession *uploadSession			= [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
	
	//	create random file name for now
	NSURL *url							= [Dropbox createPhotoUploadURL];
	NSMutableURLRequest *urlRequest		= [[NSMutableURLRequest alloc] initWithURL:url];
	urlRequest.HTTPMethod				= @"PUT";
	
	self.uploadTask						= [uploadSession uploadTaskWithRequest:urlRequest fromData:imageData];
	
	self.uploadView.hidden				= NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	[self.uploadTask resume];
}

#pragma mark - NSURLSessionTaskDelegate Methods

/**
 *
 *
 *	@param
 *	@param
 *	@param
 *	@param
 *	@param
 */
- (void)	  URLSession:(NSURLSession *)session
					task:(NSURLSessionTask *)task
		 didSendBodyData:(int64_t)bytesSent
		  totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:
	^{
		[self.progress setProgress:totalBytesSent / totalBytesExpectedToSend animated:YES];
	}];
}

/**
 *
 *
 *	@param
 *	@param
 *	@param
 */
- (void)  URLSession:(NSURLSession *)session
				task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(),
	^{
		[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
		self.uploadView.hidden			= YES;
		self.progress.progress			= 0.5f;
		
		if (error)						return;
		
		[self refreshPhotos];
	});
}

@end

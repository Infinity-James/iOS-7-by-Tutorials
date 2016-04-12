//
//  NotesViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NotesViewController.h"
#import "DBFile.h"
#import "NoteDetailsViewController.h"
#import "Dropbox.h"

@interface NotesViewController ()<NoteDetailsViewControllerDelegate>

@property (nonatomic, strong)	NSArray				*notes;
@property (nonatomic, strong)	NSURLSession		*session;

@end

@implementation NotesViewController

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
		//	create session configuration so that no caching or persistence occurs
		NSURLSessionConfiguration *sessionConfiguration	= [NSURLSessionConfiguration ephemeralSessionConfiguration];
		//	add the authorisation header
		sessionConfiguration.HTTPAdditionalHeaders		= @{@"Authorization"	: [Dropbox apiAuthorizationHeader]};
		//	create the NSURLSession with the above configuration
		self.session									= [NSURLSession sessionWithConfiguration:sessionConfiguration];
	}
	
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self notesOnDropbox];
}

// list files found in the root dir of appFolder
- (void)notesOnDropbox
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	//	get the url for the root folder in Dropbox
	NSURL *url							= [Dropbox appRootURL];
	
	//	create a data task to perform a GET request to the URL obtained above
	NSURLSessionDataTask *dataTask		= [self.session dataTaskWithURL:url
												  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
	{
		if (error)						return;
		NSHTTPURLResponse *httpResponse	= (NSHTTPURLResponse *)response;
		if (httpResponse.statusCode != 200)
			return;
		
		NSError *jsonError;
		
		//	serialise the data into a JSON dictionary
		NSDictionary *notesJSON			= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
		
		if (jsonError)					return;
		
		NSMutableArray *notesFound		= [[NSMutableArray alloc] init];
		
		//	get the contents of the root directory and iterate through it to find a piece of data which is not a directory
		NSArray *contentsOfRootDirectory= notesJSON[@"contents"];
		for (NSDictionary *data in contentsOfRootDirectory)
			if (![data[@"is_dir"] boolValue])
				[notesFound addObject:[[DBFile alloc] initWithJSONData:data]];
		
		//	sort the notes
		[notesFound sortUsingComparator:^NSComparisonResult(DBFile *fileA, DBFile *fileB)
		{
			return [fileA compare:fileB];
		}];
		
		//	get a strong pointer to the notes array
		self.notes						= notesFound;
		
		//	on the main thread update the view with the notes and stuff
		dispatch_async(dispatch_get_main_queue(),
		^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
			[self.tableView reloadData];
		});
	}];
	
	//	start the task
	[dataTask resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DBFile *note = _notes[indexPath.row];
    cell.textLabel.text = [[note fileNameShowExtension:YES]lowercaseString];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    NoteDetailsViewController *showNote = (NoteDetailsViewController*) [navigationController viewControllers][0];
    showNote.delegate = self;
    showNote.session					= self.session;

    if ([segue.identifier isEqualToString:@"editNote"]) {
        
        // pass selected note to be edited //
        if ([segue.identifier isEqualToString:@"editNote"]) {
            DBFile *note =  _notes[[self.tableView indexPathForSelectedRow].row];
            showNote.note = note;
        }
    }
}

#pragma mark - NoteDetailsViewController Delegate methods

-(void)noteDetailsViewControllerDoneWithDetails:(NoteDetailsViewController *)controller
{
    // refresh to get latest
    [self dismissViewControllerAnimated:YES completion:nil];
    [self notesOnDropbox];
}

-(void)noteDetailsViewControllerDidCancel:(NoteDetailsViewController *)controller
{
    // just close modal vc
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

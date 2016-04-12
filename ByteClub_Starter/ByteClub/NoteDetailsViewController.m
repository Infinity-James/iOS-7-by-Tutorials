//
//  NoteDetailsViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "Dropbox.h"
#import "DBFile.h"

@interface NoteDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *filename;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation NoteDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.note) {
        self.filename.text = [[_note fileNameShowExtension:YES] lowercaseString];
        [self retreiveNoteText];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)retreiveNoteText
{
	//
	NSString *fileAPI					= @"https://api-content.dropbox.com/1/files/dropbox";
	NSString *escapedPath				= [self.note.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString					= [[NSString alloc] initWithFormat:@"%@/%@", fileAPI, escapedPath];
	NSURL *url							= [[NSURL alloc] initWithString:urlString];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	
	//
	NSURLSessionDataTask *dataTask		= [self.session dataTaskWithURL:url
												  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
	{
		if (error)						return;
		
		NSHTTPURLResponse *httpResponse	= (NSHTTPURLResponse *)response;
		
		if (httpResponse.statusCode != 200)
			return;
		
		NSString *text					= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		
		dispatch_async(dispatch_get_main_queue(),
		^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
			self.textView.text			= text;
		});
	}];
	[dataTask resume];
}

#pragma mark - send messages to delegate

- (IBAction)done:(id)sender
{
    // must contain text in textview
    if (![_textView.text isEqualToString:@""]) {
        
        // check to see if we are adding a new note
        if (!self.note) {
            DBFile *newNote = [[DBFile alloc] init];
            newNote.root = @"dropbox";
            self.note = newNote;
        }
        
        _note.contents = _textView.text;
        _note.path = _filename.text;
        
		//	get the upload url for the path of this note
        NSURL *url						= [Dropbox uploadURLForPath:self.note.path];
		
		//	create a PUT url request
		NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL:url];
		request.HTTPMethod				= @"PUT";
		
		//	encode the note contents
		NSData *noteContents			= [self.note.contents dataUsingEncoding:NSUTF8StringEncoding];
		
		//	create an upload task with the data
		NSURLSessionUploadTask *uploadTask	= [self.session uploadTaskWithRequest:request
																		fromData:noteContents
															   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
		{
			NSHTTPURLResponse *httpResponse	= (NSHTTPURLResponse *)response;
			if (error || httpResponse.statusCode != 200)
				return;
			
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self.delegate noteDetailsViewControllerDoneWithDetails:self];
			});
		}];
		
		//
		[uploadTask resume];
        
    } else {
        UIAlertView *noTextAlert = [[UIAlertView alloc] initWithTitle:@"No text"
                                                              message:@"Need to enter text"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
        [noTextAlert show];
    }
}

- (IBAction)cancel:(id)sender
{
    
    [self.delegate noteDetailsViewControllerDidCancel:self];
}

@end

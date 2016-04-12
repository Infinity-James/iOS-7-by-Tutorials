//
//  DetailViewController.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "DetailViewController.h"
#import "Cat.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *attributionText;

@end

@implementation DetailViewController

/**
 *
 */
- (void)pushNew
{
	[self.navigationController pushViewController:[[DetailViewController alloc] init] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:self.cat.image];
    self.attributionText.text = self.cat.attribution;
	
	UIButton *button		= [[UIButton alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 50.0f, 50.0f)];
	[button addTarget:self action:@selector(pushNew) forControlEvents:UIControlEventTouchUpInside];
	button.backgroundColor	= [UIColor blackColor];
	[self.view addSubview:button];
	[self.view bringSubviewToFront:button];
	
    self.title = self.cat.title;
}

@end

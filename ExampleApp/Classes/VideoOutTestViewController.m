//
//  VideoOutTestViewController.m
//  VideoOutTest
//
//  Created by Scott Lawrence on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "VideoOutTestViewController.h"
#import "BLVideoOut.h"

@implementation VideoOutTestViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)updateStatus:(NSString *)txt
{
	statusLabel.text = [NSString stringWithFormat:@"(%d screen%s) %@", 
						[[UIScreen screens] count], 
						([[UIScreen screens] count]>1)?"s":"",
						txt];
}

#pragma mark video out text display
- (void)screenDidConnect
{
	[self updateStatus:@"screenDidConnect"];
	textView.text = [[BLVideoOut sharedVideoOut] description];
}

- (void)screenDidDisconnect
{
	[self updateStatus:@"screenDidDisconnect"];
	textView.text = [[BLVideoOut sharedVideoOut] description];
}

- (void) startUpExternalDisplayHandling
{
	// update our labels
	logLabel.text = @"Ready.";
	[self updateStatus:@"Ready."];
	textView.text = [[BLVideoOut sharedVideoOut] description];

	// register to listen for screen count notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(screenDidConnect) 
												 name:UIScreenDidConnectNotification 
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(screenDidDisconnect) 
												 name:UIScreenDidDisconnectNotification 
											   object:nil];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self startUpExternalDisplayHandling];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end

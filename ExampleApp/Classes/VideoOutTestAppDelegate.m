//
//  VideoOutTestAppDelegate.m
//  VideoOutTest
//
//  Created by Scott Lawrence on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "VideoOutTestAppDelegate.h"
#import "VideoOutTestViewController.h"

@implementation VideoOutTestAppDelegate

@synthesize window;
@synthesize viewController;

#pragma mark -
#pragma mark base stuff

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{        
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	[BLVideoOut sharedVideoOut].delegate = self;
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
	[BLVideoOut shutdown];
}

#pragma mark -
#pragma mark Video out stuff



-(void)screenDidConnect:(NSArray*)screens toWindow:(UIWindow*)_window 
{	
	[_window setBackgroundColor:[UIColor yellowColor]];
}

-(void)screenDidDisconnect:(NSArray*)screens fromWindow:(UIWindow*)_window 
{
}

// let's just cycle the color here, to show something happening.
float hue = 0;
-(void)displayLink:(CADisplayLink*)dispLink forWindow:(UIWindow*)_window 
{
	hue += 0.01;
	if( hue>1.0) hue=0.0;
	UIColor * bgColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
	[_window setBackgroundColor:bgColor];
}


@end

// BLVideoOut
//		- a helper to simplify Video Out connections for iPhoneOS 3.2+ SDK
//
//  v1.2 2010-Sep-04	fix so it will run properly on 3.x devices
//						(so you can build it into one app to be run on new
//						and old devices alike.
//						added .canProvideVideoOut
//
//  v1.1 2010-May-25	fix to get reconnections working.  now works 100%
//						thanks to Steve Doss!
//
//	v1.0 2010-May-02	Initial version
//						based on Erica Sadun's VTM talk sketchnotes
//						fixes and corrections by go2 and Steven Smith
//

/*
 Copyright (c) 2010 Scott Lawrence / Umlautllama.com
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "BLVideoOut.h"

// for sysctlbyname, for setting 'canProvideVideoOut'
#include <sys/types.h>
#include <sys/sysctl.h>


@interface BLVideoOut()
- (void)startExternalScreen;
- (void)terminateExternalScreen;
- (void)determineIfCanProvideVideoOut;
@end


static BLVideoOut * _sharedVideoOut;

@implementation BLVideoOut
@synthesize delegate, extScreenActive, extWindow;
@synthesize canProvideVideoOut;

#pragma mark - 
#pragma mark classy stuff

- (id)init {
    if (self = [super init]) {
        // Initialization code
		extScreenActive = NO;
		
		[self determineIfCanProvideVideoOut];
		
		if( !canProvideVideoOut ) return self; // return before we crash
		

		// register to listen for screen count notifications
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(screenDidConnect) 
													 name:UIScreenDidConnectNotification 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(screenDidDisconnect) 
													 name:UIScreenDidDisconnectNotification 
												   object:nil];
		
		// start it up, if it's already connected
		if( [[UIScreen screens] count] > 1 )
		{
			[self startExternalScreen];
		}
    }
    return self;
}


- (void)dealloc 
{
	if( !canProvideVideoOut )
	{
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
		
		if (extScreenActive) {
			[self terminateExternalScreen];
		}
	}
	[self.extWindow release];
    [super dealloc];
}


+ (BLVideoOut *) sharedVideoOut
{
	if( !_sharedVideoOut ) {
		_sharedVideoOut = [[BLVideoOut alloc] init];
	}
	return _sharedVideoOut;
}

+ (void) shutdown
{
	if( _sharedVideoOut.extWindow ) 
	{
		[_sharedVideoOut.extWindow setBackgroundColor:[UIColor blackColor]]; // just in case.
	}
	[_sharedVideoOut terminateExternalScreen];
	[_sharedVideoOut release];
	_sharedVideoOut = nil;
}


- (NSString *)description
{
	NSMutableString * s = [[NSMutableString alloc] initWithString:@"Screens:\n" ];
	
	NSArray * scrs = [UIScreen screens];
	
	for( int i=0 ; i< [scrs count] ; i++ )
	{
		[s appendFormat:@"Screen %d:\n", i];
		NSArray * modes = [[scrs objectAtIndex:i] availableModes];
		for( int j=0 ; j<[modes count] ; j++ )
		{
			UIScreenMode * uism = [modes objectAtIndex:j];
			[s appendFormat:@"     %f x %f - %f\n", 
			 [uism size].width, 
			 [uism size].height, 
			 [uism pixelAspectRatio]];
		}
	}
	return( s );
}

- (void) determineIfCanProvideVideoOut
{
	canProvideVideoOut = NO; // guilty until proven innocent.

	// first, get the current device - (NOTE: This is low-level, but SDK-OK!)
    char buffer[32]; // 32 bytes is plenty for our needs
	buffer[0] = '\0'; // just in case
    size_t length = sizeof(buffer);
	
    if (sysctlbyname("hw.machine", &buffer, &length, NULL, 0) == 0) 
	{
		// we have valid info, set our flag if need be		
		if( !strcmp( buffer, "iPhone3,1" )) canProvideVideoOut = YES;	// iPhone 4
		if( !strcmp( buffer, "iPad1,1" ))	canProvideVideoOut = YES;	// iPad 1 WiFi (*)
		if( !strcmp( buffer, "iPad1,2" ))	canProvideVideoOut = YES;	// iPad 1 3G   (*)
		if( !strcmp( buffer, "i386" ))		canProvideVideoOut = YES;	// simulator
		
		// (*) NOTE: Untested
		
		// Ref: http://umlautllama.com/w2/?action=view&page=iPhone%20Helpful%20Coding%20Tips#s_13
    }
}


#pragma mark -
#pragma mark video on/off functionality

- (void)startExternalScreen
{	
	// reset this
	extScreenActive = NO;
	
	// determine the correct resolution
	NSArray * scrs = [UIScreen screens];
	
	if( !scrs || [scrs count] < 2 ) return;	// fail
	UIScreen * extScreen = [[UIScreen screens] objectAtIndex:[scrs count]-1];
	
	
	NSArray * modes = [extScreen availableModes];
	if( !modes || [modes count] == 0 ) return; // fail
	
#ifdef kVideoPreferLowRes
	UIScreenMode * uism = [modes objectAtIndex:0];
#else
	UIScreenMode * uism = [modes lastObject];
#endif
	
	// allocate a new window
	CGRect frm = CGRectMake(0, 0, [uism size].width, [uism size].height);
	self.extWindow = [[UIWindow alloc] initWithFrame:frm];
	
	// attach the display link
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderAndUpdate)];
	[displayLink setFrameInterval:kBLVideoOutFrameInterval]; // interval is like frameskip
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	self.extWindow.screen = extScreen;
	[self.extWindow.screen setCurrentMode:uism];  // not intuitive, but necessary
	[self.extWindow makeKeyAndVisible];
	extScreenActive = YES;	
}

- (void)terminateExternalScreen
{		
	[displayLink invalidate];
	displayLink = nil;
	self.extWindow = nil;
	extScreenActive = NO;
}

#pragma mark -
#pragma mark delegate methods

- (void)renderAndUpdate
{
	if ([delegate respondsToSelector:@selector(displayLink:forWindow:)])
	{
		[delegate displayLink:displayLink 
					forWindow:self.extWindow];
	}
}


- (void)screenDidConnect
{
	[self startExternalScreen];
	if ([delegate respondsToSelector:@selector(screenDidConnect:toWindow:)])
	{
		[delegate screenDidConnect:[UIScreen screens] 
						  toWindow:self.extWindow];
	}
}

- (void)screenDidDisconnect
{
	[self terminateExternalScreen];
	if ([delegate respondsToSelector:@selector(screenDidDisconnect:fromWindow:)])
	{
		[delegate screenDidDisconnect:[UIScreen screens] 
						   fromWindow:self.extWindow];
	}
}


@end

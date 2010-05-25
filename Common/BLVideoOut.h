// BLVideoOut
//		- a helper to simplify Video Out connections for iPhoneOS 3.2+ SDK
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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol BLVideoOutDelegate;

// kVideoOutFrameInterval - refresh interval to update
//	1 = update every frame
//	2 = update every second (every other) frame
//	etc.
#define kBLVideoOutFrameInterval		(2)

// kVideoPreferLowRes - prefer a low res on the external display
//	#define = Configure for the smallest available resolution on the external
//  #undef = Configure for the largest available res on the extneral
#undef kVideoPreferLowRes


@interface BLVideoOut : NSObject 
{	
	<BLVideoOutDelegate>	delegate;
	UIWindow				*extWindow;
	CADisplayLink			*displayLink;
	BOOL					extScreenActive;

}
@property (nonatomic, retain) 	<BLVideoOutDelegate> delegate;	// handler for connect/disconnect/update
@property (nonatomic, retain) 	UIWindow *extWindow;
@property (nonatomic) BOOL		extScreenActive;

// use this to access it all - singletoney goodness
+ (BLVideoOut *) sharedVideoOut;

// use this to terminate - it frees up some stuff inside
+ (void) shutdown;

@end


@protocol BLVideoOutDelegate <NSObject>
@optional
// screenDidConnect::
//		gets called when a new screen is connected to the device
//		'screens' is the array of now available screens
//		'_window' is the external window
-(void)screenDidConnect:(NSArray*)screens toWindow:(UIWindow*)_window;

// screenDidDisconnect::
//		gets called when a screen is detached from the device
//		'screens' is the array of now available screens
//		'_window' is the external window
-(void)screenDidDisconnect:(NSArray*)screens fromWindow:(UIWindow*)_window;

// displayLink:forWindow
//		gets called when the new screen is to be updated
//		'dispLink' is the CADisplayLink in question
//		'_window' is the external window
-(void)displayLink:(CADisplayLink*)dispLink forWindow:(UIWindow*)_window;
@end
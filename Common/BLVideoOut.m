#import "BLVideoOut.h"

@interface BLVideoOut()
- (void)startExternalScreen;
- (void)terminateExternalScreen;
@end


static BLVideoOut * _sharedVideoOut;

@implementation BLVideoOut
@synthesize delegate, extScreenActive, extWindow;

#pragma mark - 
#pragma mark classy stuff

- (id)init {
    if (self = [super init]) {
        // Initialization code
		extScreenActive = NO;

		// register to listen for screen count notifications
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(screenDidConnect) 
													 name:UIScreenDidConnectNotification 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(screenDidDisconnect) 
													 name:UIScreenDidDisconnectNotification 
												   object:nil];
		
		if( [[UIScreen screens] count] > 1 )
		{
			[self startExternalScreen];
		}
    }
    return self;
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
	
	if (extScreenActive) {
		[self terminateExternalScreen];
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

#pragma mark -
#pragma mark video on/off functionality

- (void)startExternalScreen
{
	// determine the correct resolution
	NSArray * scrs = [UIScreen screens];
	UIScreen * extScreen = [[UIScreen screens] objectAtIndex:[scrs count]-1];
	NSArray * modes = [extScreen availableModes];
	UIScreenMode * uism = [modes objectAtIndex:0];
	
	// allocate a new window
	CGRect frm = CGRectMake(0, 0, [uism size].width, [uism size].height);
	self.extWindow = [[UIWindow alloc] initWithFrame:frm];
	
	// attach the display link
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderAndUpdate)];
	[displayLink setFrameInterval:kBLVideoOutFrameInterval]; // interval is like frameskip
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	self.extWindow.screen = extScreen;
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

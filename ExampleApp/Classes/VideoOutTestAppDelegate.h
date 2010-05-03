//
//  VideoOutTestAppDelegate.h
//  VideoOutTest
//
//  Created by Scott Lawrence on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BLVideoOut.h"

@class VideoOutTestViewController;

@interface VideoOutTestAppDelegate : NSObject 
<UIApplicationDelegate, BLVideoOutDelegate> 
{
    UIWindow *window;
    VideoOutTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet VideoOutTestViewController *viewController;

@end


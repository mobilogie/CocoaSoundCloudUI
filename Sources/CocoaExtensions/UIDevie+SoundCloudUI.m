//
//  UIDevie+SoundCloudUI.m
//  SoundCloudUI
//
//  Created by Tobias Kräntzer on 15.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "UIDevie+SoundCloudUI.h"

@implementation UIDevice (SoundCloudUI)

+ (BOOL)isIPad;
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES; 
	}
#endif
	return NO;
}

@end

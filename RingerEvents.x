/**
 * This file is part of RingerEvents
 * Copyright 2014 Oliver Kuckertz <oliver.kuckertz@mologie.de>
 * See COPYING for licensing information.
 *
 * This application uses code from https://github.com/a3tweaks/Flipswitch, which
 * is licensed under the LGPL 2.1.
 */

#import <libactivator/libactivator.h>

static NSString *kRERingerMuteEvent = @"com.mologie.ringerevents.muted";
static NSString *kRERingerUnmuteEvent = @"com.mologie.ringerevents.unmuted";

@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)isRingerMuted;
@end

static LAEvent *SendEventWithName(NSString *eventName) {
	LAEvent *event = [[LAEvent alloc] initWithName:eventName mode:LASharedActivator.currentEventMode];
	[LASharedActivator sendEventToListener:event];
	return event;
}

static void RingerSettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	SBMediaController *mediaController = (SBMediaController *)[%c(SBMediaController) sharedInstance];
	BOOL ringerIsMuted = [mediaController isRingerMuted];
#ifdef DEBUG
	NSLog(@"[RingerEvents] The ringer is now %@", ringerIsMuted ? @"muted" : @"active");
#endif
	if (ringerIsMuted) {
		SendEventWithName(kRERingerMuteEvent);
	} else {
		SendEventWithName(kRERingerUnmuteEvent);
	}
}

%ctor {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, NULL, RingerSettingsChanged, CFSTR("com.apple.springboard.ringerstate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}

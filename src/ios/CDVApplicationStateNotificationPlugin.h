#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>


@interface CDVApplicationStateNotificationPlugin : CDVPlugin {
	NSString*          _callbackId;
}

- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;

@end


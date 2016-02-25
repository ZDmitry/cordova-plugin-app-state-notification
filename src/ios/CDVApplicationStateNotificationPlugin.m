#import "CDVApplicationStateNotificationPlugin.h"

static void displayStatusChanged(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    if (name == CFSTR("com.apple.springboard.lockcomplete")) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@implementation CDVApplicationStateNotificationPlugin

- (void) init:(CDVInvokedUrlCommand*)command
{
    _callbackId = [command callbackId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    NSDictionary* json = @{
        @"event":  @"init"
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
    pluginResult.keepCallback = @(YES);
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
}

- (void) pluginInitialize
{
    _callbackId = nil;
    
    // Override point for customization after application launch.
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockcomplete"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}


- (void) applicationDidEnterBackground
{
    UIApplication* app = [UIApplication sharedApplication];

    __block UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if([app respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        bgTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"background task %lu expired", (unsigned long)bgTaskId);
            
            [app endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }];
    }
    
    NSString *message;
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state == UIApplicationStateInactive) {
        message = @"lock";
    } else if (state == UIApplicationStateBackground) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"]) {
            message = @"home";
        } else {
            message = @"lock";
        }
    }
    
    NSDictionary* json = @{
        @"event":  @"stateChange",
        @"reason": message
    };
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
    pluginResult.keepCallback = @(YES);
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];

    if (bgTaskId != UIBackgroundTaskInvalid) [app endBackgroundTask:bgTaskId];
}

- (void) applicationWillEnterForeground
{
    UIApplication* app = [UIApplication sharedApplication];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end

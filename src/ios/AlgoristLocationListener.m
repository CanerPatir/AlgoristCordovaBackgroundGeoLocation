/********* AlgoristLocationListener.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "AppDelegate+LocationListener.h"
#import "LocationListenerConfig.h"

@interface AlgoristLocationListener : CDVPlugin <UIApplicationDelegate> {
  // Member variables go here.
}

- (void)startLocationListener:(CDVInvokedUrlCommand*)command;
- (void)stopLocationListener:(CDVInvokedUrlCommand*)command;
@end

@implementation AlgoristLocationListener

- (void)pluginInitialize
{

}

- (void)startLocationListener:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* postUrl = [command.arguments objectAtIndex:0];
    NSDictionary* headers = [command.arguments objectAtIndex:1];
    //BOOL isDebug = [[command.arguments objectAtIndex:2]  isEqual: [NSNumber numberWithInt:1]];
    
    @try {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate setEnabledLocationManager:YES];
        
        LocationListenerConfig * lConfig = [[LocationListenerConfig alloc] init];
        lConfig.postUrl = postUrl;
        lConfig.headers = headers;
        [lConfig saveConfig];
        
        [appDelegate.shareModel startMonitoringLocation];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    @catch (NSException *exception) {
        NSLog(@"startLocationListener exception. %@", exception.reason);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stopLocationListener:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    @try {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.shareModel stopMonitoringLocation];
        
        [appDelegate setEnabledLocationManager:NO];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    @catch (NSException *exception) {
        NSLog(@"stopLocationListener exception. %@", exception.reason);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end

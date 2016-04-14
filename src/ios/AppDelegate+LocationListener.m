
//
//  AppDelegate+LocationListener.m
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AppDelegate+LocationListener.h"

@implementation AppDelegate (LocationListener)

- (ALGLocationManager *)shareModel
{
    return objc_getAssociatedObject(self, @"shareModel");
}

- (void)setShareModel:(ALGLocationManager *)aShareModel
{
    objc_setAssociatedObject(self, @"shareModel", aShareModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) setEnabledLocationManager:(BOOL)val
{
    NSNumber *number = [NSNumber numberWithBool: val];
    objc_setAssociatedObject(self, @"enabledLocationManager", number , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) enabledLocationManager
{
    NSNumber *number = objc_getAssociatedObject(self, @"enabledLocationManager");
    return [number boolValue];
}


+ (void)load {
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    swizzled = class_getInstanceMethod(self, @selector(xx_app:didFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
}

-(BOOL)xx_app:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    // do whatever you need here
    
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.shareModel = [ALGLocationManager sharedManager];
    self.shareModel.afterResume = NO;
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]);
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            [self.shareModel startMonitoringLocation];
            
        }
    }
    //return YES;
    // looks like it's just calling itself, but the implementations were swapped so we're actually
    // calling the original once we're done
    return [self xx_app:application didFinishLaunchingWithOptions:launchOptions];
}

/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.shareModel = [LocationManager sharedManager];
    self.shareModel.afterResume = NO;
    
    [self.shareModel addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];
    
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]);
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
                // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            [self.shareModel startMonitoringLocation];
            [self.shareModel addResumeLocationToPList];
            
        }
    }
    
    return YES;
}
*/

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    
    [self.shareModel restartMonitoringLocation];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    [self.shareModel startMonitoringLocation];
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
}

@end


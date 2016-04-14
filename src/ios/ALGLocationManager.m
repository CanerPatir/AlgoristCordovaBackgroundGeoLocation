//
//  ALGLocationManager.m
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//

#import "ALGLocationManager.h"
#import <UIKit/UIKit.h>
#import "LocationListenerConfig.h"


@interface ALGLocationManager () <CLLocationManagerDelegate>

@end


@implementation ALGLocationManager

//Class method to make sure the share model is synch across the app
+ (id)sharedManager {
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}


#pragma mark - CLLocationManager

- (void)startMonitoringLocation {
    if (_anotherLocationManager)
        [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.anotherLocationManager = [[CLLocationManager alloc]init];
    _anotherLocationManager.delegate = self;
    _anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [_anotherLocationManager requestAlwaysAuthorization];
    }
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)restartMonitoringLocation {
    [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if (IS_OS_8_OR_LATER) {
        [_anotherLocationManager requestAlwaysAuthorization];
    }
    
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringLocation{
    [_anotherLocationManager stopMonitoringSignificantLocationChanges];
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations: %@",locations);
    
    for (int i = 0; i < locations.count; i++) {
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
        
        BOOL isInBackground = NO;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            isInBackground = YES;
        }
        
        // Handle location updates as normal, code omitted for brevity.
        // The omitted code should determine whether to reject the location update for being too
        // old, too close to the previous one, too inaccurate and so forth according to your own
        // application design.
        [self postLocation:theLocation isBackground:isInBackground];
    }
    
    //[self addLocationToPList:_afterResume];
}

UIBackgroundTaskIdentifier bgTask;

- (void)postLocation:(CLLocationCoordinate2D)location isBackground:(BOOL)isBackground{
    
    if (isBackground) {
        // REMEMBER. We are running in the background if this is being executed.
        // We can't assume normal network access.
        // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
        
        // Note that the expiration handler block simply ends the task. It is important that we always
        // end tasks that we have started.
        
        UIApplication  *app = [UIApplication sharedApplication];
        /*
        UIBackgroundTaskIdentifier __block bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"Operation did not finish!!!");
            
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
            
            
            
        }];*/
        
        bgTask = [app beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK
        
        // For example, I can do a series of SYNCHRONOUS network methods (we're in the background, there is
        // no UI to block so synchronous is the correct approach here).
        
        [self locationHttpOperation:location isBackground:isBackground];
        
    }else{
        [self locationHttpOperation:location isBackground:isBackground];
    }
}

- (void)locationHttpOperation:(CLLocationCoordinate2D)location isBackground:(BOOL)isBackground{
    
    NSString* postUrl = nil;
    NSDictionary* headers = nil;
    
    LocationListenerConfig* lConfig = [[LocationListenerConfig alloc]init];
    [lConfig loadConfig];
    if (lConfig.postUrl != nil) {
        postUrl = lConfig.postUrl;
        headers = lConfig.headers;
        
    }
    if (postUrl == nil) {
        NSLog(@"postUrl is null");
        return;
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:postUrl]];
    
    [request setHTTPMethod:@"POST"];
    
    for(id key in headers){
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        NSLog(@"key=%@ value=%@", key, [headers objectForKey:key]);
    }
    
    
    NSString* latStr=[NSString stringWithFormat:@"%f", location.latitude ];
    NSString* lngStr=[NSString stringWithFormat:@"%f", location.longitude ];
    
    
    NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:latStr,@"lat",
                         lngStr, @"long", nil];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postdata];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        
        NSURLResponse *response;
        NSError *errorResp = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&errorResp];
        if (errorResp) {
            // Deal with your error
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, errorResp);
            }
            NSLog(@"Error %@", errorResp);
        }else{
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"HTTP: %ld", (long)httpResponse.statusCode);
            }
        }
        
        NSString *responeString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        // Assume lowercase
        if ([responeString isEqualToString:@""]) {
            // Deal with true
            //return;
        }
        
        if (isBackground) {
            
            // AFTER ALL THE UPDATES, close the task
            NSLog(@"http bg operation finished");
            
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }else{
            NSLog(@"http operation finished");
        }
    });
    
    //NSString* strData = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
  
}


#pragma mark - Plist helper methods

// Below are 3 functions that add location and Application status to PList
// The purpose is to collect location information locally

- (NSString *)appState {
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    return appState;
}

/*

- (void)addResumeLocationToPList {
    
    NSLog(@"addResumeLocationToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}

- (void)addLocationToPList:(BOOL)fromResume {
    NSLog(@"addLocationToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];
    
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    if (fromResume) {
        [_myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
    } else {
        [_myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];
    }
    
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}

- (void)addApplicationStatusToPList:(NSString*)applicationStatus {
    
    NSLog(@"addApplicationStatusToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}

- (void)saveLocationsToPlist {
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile) {
        savedProfile = [[NSMutableDictionary alloc] init];
        self.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    } else {
        self.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(_myLocationDictInPlist) {
        [_myLocationArrayInPlist addObject:_myLocationDictInPlist];
        [savedProfile setObject:_myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE]) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}
*/

@end


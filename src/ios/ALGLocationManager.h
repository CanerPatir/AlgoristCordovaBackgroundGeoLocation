//
//  ALGLocationMnager.h
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ALGLocationManager : NSObject

@property (nonatomic) CLLocationManager * anotherLocationManager;

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

//@property (nonatomic) NSMutableDictionary *myLocationDictInPlist;
//@property (nonatomic) NSMutableArray *myLocationArrayInPlist;

@property (nonatomic) BOOL afterResume;

//@property (nonatomic) NSString * postUrl;
//@property (nonatomic) NSDictionary * headers;

+ (id)sharedManager;

- (void)startMonitoringLocation;
- (void)restartMonitoringLocation;
- (void)stopMonitoringLocation;

//- (void)addResumeLocationToPList;
//- (void)addLocationToPList:(BOOL)fromResume;
//- (void)addApplicationStatusToPList:(NSString*)applicationStatus;

@end


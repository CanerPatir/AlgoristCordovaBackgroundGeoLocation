//
//  AppDelegate+LocationListener.h
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//

#import "AppDelegate.h"
#import "ALGLocationManager.h"

@interface AppDelegate (LocationListener)

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ALGLocationManager * shareModel;
@property (readwrite,nonatomic) BOOL enabledLocationManager;

@end
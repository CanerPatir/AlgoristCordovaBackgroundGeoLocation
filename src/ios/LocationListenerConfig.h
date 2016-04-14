//
//  LocationListenerConfig.h
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//

#import <Foundation/Foundation.h>

@interface LocationListenerConfig : NSObject<NSXMLParserDelegate> 

@property (nonatomic) NSString *postUrl;
@property (nonatomic) NSDictionary *headers;

- (void)loadConfig;
- (void)saveConfig;
@end

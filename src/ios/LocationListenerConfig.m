//
//  LocationListenerConfig.m
//  HelloCordova
//
//  Created by algorist on 10.04.2016.
//
//
#import <Foundation/Foundation.h>
#import "LocationListenerConfig.h"
//#import "Party.h"

@implementation LocationListenerConfig

@synthesize postUrl,headers;

+ (NSString *)dataFilePath {
    
    return [[NSBundle mainBundle] pathForResource:@"cfg" ofType:@"xml"];
}

- (void)loadConfig {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filepath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"bg_config.xml"];
    
    //NSString *filepath = [[NSBundle mainBundle] pathForResource:@"bg_config" ofType:@"xml"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error){
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return;
    }
    
    NSData * XMLData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:XMLData];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO]; // if you need to
    [parser parse]; // start parsing

    
    
    
    //NSError * err;
    //NSData *data =[myString dataUsingEncoding:NSUTF8StringEncoding];
    //NSDictionary * response;
    //if(data!=nil){
    //    response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    //}
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict{
    
    /* handle namespaces here if you want */
    
    elementoCorrente = nil;
    
    
    if([elementName isEqualToString:@"config"]){
        postUrl = [attributeDict objectForKey:@"postUrl"];
        NSString * headersStr = [attributeDict objectForKey:@"headers"];
        NSData *data =[headersStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        if(data!=nil){
            headers = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        }

        
        // use ID string, or store it in an ivar so you can access it somewhere else
    }
    
    if([elementName isEqualToString:@"postUrl"]){
        elementoCorrente = [elementName copy];
    }
    
    if([elementName isEqualToString:@"headers"]){
        elementoCorrente = [elementName copy];
        
        // use ID string, or store it in an ivar so you can access it somewhere else
    }
    
}

NSString* elementoCorrente = nil;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([elementoCorrente isEqualToString:@"postUrl"]) {
        postUrl = string;
    }
    
    if ([elementoCorrente isEqualToString:@"headers"]) {
        
        NSString * headersStr = string;
        NSData *data =[headersStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        if(data!=nil){
            headers = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        }
    }
}

- (void)saveConfig{
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:headers options:0 error:&err];
    NSString * headersString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    NSLog(@"%@", headersString);
    
    NSString *xmlBase =@"";
    
    NSString *xml = [xmlBase stringByAppendingFormat:
                     @"<?xml version='1.0' encoding='UTF-8'?>"
                     "<config>"
                     "<postUrl>%@<postUrl/>"
                     "<headers>%@<headers/>"
                     "</config>", self.postUrl, headersString];

    
    //write file
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"bg_config.xml"];

    [xml writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end

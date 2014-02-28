//
//  TouchMongoDB.m
//  httpTest
//
//  Created by HWANG WOONGJIN on 12/12/03.
//  Copyright (c) 2012年 HWANG WOONGJIN. All rights reserved.
//

#import "TouchMongoDB.h"
#import "DB_Constants.h"

@interface TouchMongoDB()
-(NSString*)getBaseURLString;
@end

@implementation TouchMongoDB
@synthesize baseCollection;

static TouchMongoDB* aTouchMongoDB = nil;

+(TouchMongoDB*)sharedTouchMongoDB {
    if (!aTouchMongoDB) {
        aTouchMongoDB = [self new];
        aTouchMongoDB.baseCollection = DEFAULT_COLLECTION;
        return aTouchMongoDB;
    }
    return aTouchMongoDB;
}

-(NSString*)getBaseURLString {
    NSMutableString *urlString = [NSMutableString string];
    [urlString appendString:BASE_URL_MONGODB];
    [urlString appendString:aTouchMongoDB.baseCollection];
    [urlString appendString:@"?"];
    [urlString appendString:MONGODB_API_KEY];
    return urlString;
}

-(NSArray *)getData {
    NSString *urlString = [self getBaseURLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[[NSURLResponse alloc] init] autorelease];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    
    if (errorReturned) {
        NSLog(@"touchMongoDB response getData error");
        return nil;
    }
    NSError *jsonError;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
    return array;
}

//(NSString*)aQuery --> ex){"name":"黄雄鎮"}
-(NSArray*)getDataWithQuery:(NSString*)aQuery {
    NSMutableString *urlString = [NSMutableString stringWithString:[self getBaseURLString]];
    [urlString appendString:@"&q="];
    [urlString appendString:aQuery];
    NSString *encondedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encondedUrlString]];
    [request setHTTPMethod:@"GET"];
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[[NSURLResponse alloc] init] autorelease];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    
    if (errorReturned) {
        NSLog(@"touchMongoDB response getDataWithQuery error");
        return nil;
    }
    
    NSError *jsonError;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    return array;
}

-(BOOL)insertDocuments:(NSDictionary*)aData {
    NSString *urlString = [self getBaseURLString];
    
    NSData *jsonData;
    NSString *jsonString;
    
    if([NSJSONSerialization isValidJSONObject:aData])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:aData options:0 error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    // Be sure to properly escape your url string.
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    data = nil;
    if (errorReturned) {
        NSLog(@"touchMongoDB response insertData error");
        return NO;
    }else{
        return YES;
    }
}

@end

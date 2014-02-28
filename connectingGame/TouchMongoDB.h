//
//  TouchMongoDB.h
//  httpTest
//
//  Created by HWANG WOONGJIN on 12/12/03.
//  Copyright (c) 2012年 HWANG WOONGJIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchMongoDB : NSObject
{
    NSString *baseCollection;
}

@property (nonatomic, strong) NSString *baseCollection;

+(TouchMongoDB*)sharedTouchMongoDB;
-(NSArray*)getData;
-(NSArray*)getDataWithQuery:(NSString*)aQuery;
-(BOOL)insertDocuments:(NSDictionary*)aData;

@end

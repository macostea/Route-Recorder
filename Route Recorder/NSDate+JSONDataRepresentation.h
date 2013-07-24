//
//  NSDate+JSONDataRepresentation.h
//  Route Recorder
//
//  Created by skobbler on 7/16/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JSONDataRepresentation)

+ (NSDate *)dateFromJSONRepresentation:(NSString *)jsonString;
- (NSString *)JSONRepresentation;

@end

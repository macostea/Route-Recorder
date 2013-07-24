//
//  NSDate+JSONDataRepresentation.m
//  Route Recorder
//
//  Created by skobbler on 7/16/13.
//  Copyright (c) 2013 skobbler. All rights reserved.
//

#import "NSDate+JSONDataRepresentation.h"

@implementation NSDate (JSONDataRepresentation)

+ (NSDate *)dateFromJSONRepresentation:(NSString *)jsonString{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[jsonString doubleValue]];
    
    return date;
}

- (NSString *)JSONRepresentation{
    return [[NSNumber numberWithDouble:[self timeIntervalSince1970]] stringValue];
}

@end

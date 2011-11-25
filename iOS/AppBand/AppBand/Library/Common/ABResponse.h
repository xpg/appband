//
//  ABResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

typedef enum {
    ABResponseCodeHTTPSuccess,
    ABResponseCodeHTTPInvalidURL,
    ABResponseCodeHTTPNoConnection,
    ABResponseCodeHTTPTimeout,
    ABResponseCodeHTTPCancel,
    ABResponseCodeHTTPError,
    ABResponseCodeHTTPAuthorError = 403,
    ABResponseCodeHTTPResourceNotFound = 404,
    ABResponseCodeHTTPServerError = 500,
} ABResponseCode;

#define AppBandSDKErrorDomain @"AppBandSDKErrorDomain"

#import <Foundation/Foundation.h>

@interface ABResponse : NSObject {
    ABResponseCode code;
    
    NSError *error;
}

@property(nonatomic,assign) ABResponseCode code;
@property(nonatomic,copy) NSError *error;

@end

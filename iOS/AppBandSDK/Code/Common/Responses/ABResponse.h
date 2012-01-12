//
//  ABResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

typedef enum {
    ABResponseCodeUnknown,
    ABResponseCodeInvalidURL,
    ABResponseCodeNoConnection,
    ABResponseCodeTimeout,
    ABResponseCodeCancel,
    ABResponseCodeError,
    ABResponseCodeSuccess,
    ABResponseCodeAuthorError = 403,
    ABResponseCodeResourceNotFoundError = 404,
    ABResponseCodePostMethodError = 405,
    ABResponseCodeContentTypeError = 406,
    ABResponseCodeServerError = 500,
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

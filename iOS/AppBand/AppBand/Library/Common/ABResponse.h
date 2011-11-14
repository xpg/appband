//
//  ABResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

typedef enum {
    ABResponseCodeSuccess,
    ABResponseCodeInvalidURL,
    ABResponseCodeNoConnection,
    ABResponseCodeTimeout,
    ABResponseCodeCancel,
    ABResponseCodeAuthorError = 403,
    ABResponseCodeResourceNotFound = 404,
    ABResponseCodeServerError = 500,
} ABResponseCode;

#import <Foundation/Foundation.h>

@interface ABResponse : NSObject {
    ABResponseCode code;
    
    NSError *error;
}

@property(nonatomic,assign) ABResponseCode code;
@property(nonatomic,copy) NSError *error;

@end

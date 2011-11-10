//
//  ABHTTPRequest.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABConstant.h"

@protocol ABHTTPRequestDelegate;

@interface ABHTTPRequest : NSOperation {
    @private
        id<ABHTTPRequestDelegate> _delegate;
        
        BOOL _isCompleted;
        
        NSString *_url;
        NSDictionary *_parameters;
        NSTimeInterval _timeout;
        
        NSURLConnection *_urlConnection;
        
        NSMutableData *_responseData;
    
        SEL _finishSelector;
        SEL _failSelector;
}

@property(nonatomic,readonly,copy) NSString *url;
@property(nonatomic,readonly,copy) NSDictionary *parameters;

#pragma mark - Class Method

+ (id)requestWithURL:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector;

@end

@protocol ABHTTPRequestDelegate <NSObject>

@optional

- (void)willBeginRequest:(NSString *)url;

- (void)finishedRequest:(NSString *)url code:(ABHTTPResponseCode)code content:(NSString *)content error:(NSError *)error;

@end

//
//  ABHttpRequest.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

typedef enum {
    ABHttpRequestStatusUnknown,
    ABHttpRequestStatusInvalidURL,
    ABHttpRequestStatusNoConnection,
    ABHttpRequestStatusTimeout,
    ABHttpRequestStatusCancel,
    ABHttpRequestStatusError,
    ABHttpRequestStatusSuccess,
    ABHttpRequestStatusAuthorError = 403,
    ABHttpRequestStatusResourceNotFound = 404,
    ABHttpRequestStatusServerError = 500,
} ABHttpRequestStatus;

#define ABHTTPRequestResponse @"ABHTTPRequestResponse"
#define ABHTTPRequestError @"ABHTTPRequestError"
#define ABHTTPRequestObject @"ABHTTPRequestObject"

#import <Foundation/Foundation.h>

@protocol ABHttpRequestDelegate;

@interface ABHttpRequest : NSOperation {
    id<ABHttpRequestDelegate> delegate;
    id target;
    SEL finishSelector;
    
    @private
        NSString *_key;
        NSString *_url;
        
        NSData *_parameter;
    
        NSTimeInterval _timeout;
    
        ABHttpRequestStatus _status;
}

@property(nonatomic,assign) id<ABHttpRequestDelegate> delegate;
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL finishSelector;

@property(nonatomic,readonly,copy) NSString *key;
@property(nonatomic,readonly,copy) NSString *url;
@property(nonatomic,readonly,copy) NSData *parameter;
@property(nonatomic,readonly,assign) NSTimeInterval timeout;
@property(nonatomic,copy) NSString *contentType;
@property(nonatomic,copy) NSString *acceptType;

@property(nonatomic,readonly,assign) ABHttpRequestStatus status;

+ (id)requestWithBaseURL:(NSString *)url 
                delegate:(id<ABHttpRequestDelegate>)delegate;

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHttpRequestDelegate>)delegate; 

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
              target:(id)target 
      finishSelector:(SEL)finishSelector;

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHttpRequestDelegate>)delegate 
              target:(id)target 
      finishSelector:(SEL)finishSelector;

@end

@protocol ABHttpRequestDelegate <NSObject>

@optional

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoading:(NSString *)content error:(NSError *)error;

@end

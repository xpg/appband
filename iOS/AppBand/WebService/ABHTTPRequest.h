//
//  ABHTTPRequest.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABGlobal.h"

@protocol ABHTTPRequestDelegate;

@interface ABHTTPRequest : NSOperation {
@private
    id<ABHTTPRequestDelegate> _delegate;
    id _agent;
    
    BOOL _isCompleted;
    
    NSString *_key;
    NSString *_url;
    NSDictionary *_parameters;
    NSTimeInterval _timeout;
    
    NSURLConnection *_urlConnection;
    
    NSMutableData *_responseData;
    
    SEL _finishSelector;
    SEL _failSelector;
    
    SEL _agentSeletor;
}

@property(nonatomic,assign) id<ABHTTPRequestDelegate> delegate;

@property(nonatomic,readonly,copy) NSString *key;
@property(nonatomic,readonly,copy) NSString *url;

@property(nonatomic,assign) SEL finishSelector;
@property(nonatomic,assign) SEL failSelector;

@property(nonatomic,assign) id agent;
@property(nonatomic,assign) SEL agentSelector;

#pragma mark - Class Method

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector;

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector 
               agent:(id)agent 
       agentSelector:(SEL)agentSeletor;

@end

@protocol ABHTTPRequestDelegate <NSObject>

@optional

- (void)willBeginRequest:(NSString *)url;

- (void)finishedRequest:(NSString *)url code:(ABHTTPResponseCode)code content:(NSString *)content error:(NSError *)error;

@end

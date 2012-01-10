//
//  ABHttpRequest.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

NSString * const ABHttpRequestErrorDomain = @"ABHttpRequestErrorDomain";

#import "ABHttpRequest+Private.h"

@implementation ABHttpRequest

@synthesize delegate;
@synthesize target;
@synthesize finishSelector;

@synthesize key = _key;
@synthesize url = _url;
@synthesize parameter = _parameter;
@synthesize timeout = _timeout;
@synthesize contentType = _contentType;
@synthesize acceptType = _acceptType;
@synthesize status = _status;

@synthesize isCompleted = _isCompleted;

@synthesize connection = _connection;
@synthesize responseData = _responseData;

#pragma mark - Private


- (void)initializeConnection:(ABHttpRequest *)request {
    NSURL *url = [NSURL URLWithString:self.url];
    if ([self isAvailableURL:url]) {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
        [urlRequest setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
        
        if (self.acceptType) {
            [urlRequest setValue:self.acceptType forHTTPHeaderField:@"Accept"];
        }
        
        //check need to implement timeout by ourself
        if (self.parameter) {
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:self.parameter];
            [self performSelector:@selector(requestHasTimeout) withObject:nil afterDelay:self.timeout];
        }
        
        //create connection
        [self beginConnection:urlRequest];
        
    } else {
        NSError *error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:ABHttpRequestStatusInvalidURL userInfo:nil];
        [self finishLoadingWithError:error];
    }
}

- (void)beginConnection:(NSMutableURLRequest *)request {
    //Set Processing status and init response data
    self.isCompleted = NO;
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    while(!self.isCompleted && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    if ([self isCancelled] && !self.isCompleted) {
        [self requestHasBeenCancelled];
    }
}

- (BOOL)hasAvailableNetwork {
    return YES;
}

- (BOOL)isAvailableURL:(NSURL *)url {
    if (!url) 
        return NO;
    
    NSString *scheme = [url scheme];
    NSString *resourceSpecifier = [url resourceSpecifier];
    
    return (scheme && ![scheme isEqualToString:@""]) && (resourceSpecifier && ![resourceSpecifier isEqualToString:@""]);
}

- (void)requestHasTimeout {
    NSError *error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:ABHttpRequestStatusTimeout userInfo:nil];
    [self finishLoadingWithError:error];
    self.isCompleted = YES;
}

- (void)requestHasBeenCancelled {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestHasTimeout) object:nil];
    
    NSError *error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:ABHttpRequestStatusCancel userInfo:nil];
    [self finishLoadingWithError:error];
}

- (void)finishLoadingWithError:(NSError *)error {
    NSDictionary *responseDic = nil;
    if (!error) {
        self.status = ABHttpRequestStatusSuccess;
        responseDic = [NSDictionary dictionaryWithObjectsAndKeys:self, ABHTTPRequestObject,nil];
    } else {
        self.status = error.code;
        responseDic = [NSDictionary dictionaryWithObjectsAndKeys:error, ABHTTPRequestError, self, ABHTTPRequestObject,nil];
    }
    
    if ([self.target respondsToSelector:self.finishSelector]) {
        [self.target performSelector:self.finishSelector withObject:responseDic];
    } 
    
    if ([self.delegate respondsToSelector:@selector(httpRequest:didFinishLoadingWithError:)]) {
        [self.delegate httpRequest:self didFinishLoadingWithError:error];
    }
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOut) object:nil];
    
    [self finishLoadingWithError:[NSError errorWithDomain:error.domain code:ABHttpRequestStatusError userInfo:error.userInfo]];
    self.isCompleted = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOut) object:nil];
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    if ((httpResponse.statusCode / 100) != 2) {
        NSError *error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:httpResponse.statusCode userInfo:nil];
        
        [self finishLoadingWithError:error];
        self.isCompleted = YES;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.isCompleted) 
        return;
    
    [self finishLoadingWithError:nil];
    self.isCompleted = YES;
}

#pragma mark - NSOperation

- (void)main {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if ([self hasAvailableNetwork]) {
        [self initializeConnection:self];
    } else {
        NSError *error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:ABHttpRequestStatusNoConnection userInfo:nil];
        [self finishLoadingWithError:error];
    }
    
    [pool drain];
}

#pragma mark - lifecycle

+ (id)requestWithBaseURL:(NSString *)url 
                delegate:(id<ABHttpRequestDelegate>)delegate {
    ABHttpRequest *request = [[[ABHttpRequest alloc] init] autorelease];
    return [ABHttpRequest requestWithKey:nil url:url parameter:nil timeout:30. delegate:delegate target:nil finishSelector:nil];
    
    return request;
}

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHttpRequestDelegate>)delegate {
    return [ABHttpRequest requestWithKey:key url:url parameter:parameter timeout:timeout delegate:delegate target:nil finishSelector:nil];
}

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
              target:(id)target 
      finishSelector:(SEL)finishSelector {
    return [ABHttpRequest requestWithKey:key url:url parameter:parameter timeout:timeout delegate:nil target:target finishSelector:finishSelector];
}

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSData *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHttpRequestDelegate>)delegate 
              target:(id)target 
      finishSelector:(SEL)finishSelector {
    ABHttpRequest *request = [[[ABHttpRequest alloc] init] autorelease];
    [request setKey:key];
    [request setUrl:url];
    [request setParameter:parameter];
    [request setTimeout:timeout];
    [request setDelegate:delegate];
    [request setTarget:target];
    [request setFinishSelector:finishSelector];
    
    return request;
}

- (id)init {
    self = [super init];
    if (self) {
        self.status = ABHttpRequestStatusUnknown;
        self.timeout = 1.;
        self.isCompleted = YES;
        
        self.responseData = [NSMutableData data];
        
        self.contentType = @"application/x-www-form-urlencoded";
    }
    
    return self;
}

- (void)dealloc {
    [self setConnection:nil];
    [self setResponseData:nil];
    [self setKey:nil];
    [self setUrl:nil];
    [self setParameter:nil];
    [self setContentType:nil];
    [self setAcceptType:nil];
    [super dealloc];
}

@end

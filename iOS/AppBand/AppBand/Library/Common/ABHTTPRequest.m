//
//  ABHTTPRequest.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

NSString * const ABHTTPRequestErrorDomain = @"ABHTTPRequestErrorDomain";

#import "ABHTTPRequest.h"

#import "ABReachability.h"

//Check whether the web connection is valid.
CG_INLINE BOOL hasConnection() {
    NetworkStatus status = [[ABReachability reachabilityForInternetConnection] currentReachabilityStatus];
	return (status == ReachableViaWiFi || status == ReachableViaWWAN) ? YES : NO;
}

@interface ABHTTPRequest()

@property(nonatomic,assign) id<ABHTTPRequestDelegate> delegate;

@property(assign) BOOL isCompleted;

@property(nonatomic,readwrite,copy) NSString *url;
@property(nonatomic,readwrite,copy) NSDictionary *parameters;
@property(nonatomic,assign) NSTimeInterval timeout;

@property(nonatomic,retain) NSURLConnection *urlConnection;
@property(nonatomic,retain) NSMutableData *responseData;

@property (assign) SEL finishSelector;
@property (assign) SEL failSelector;

@end

@implementation ABHTTPRequest

@synthesize delegate = _delegate;
@synthesize isCompleted = _isCompleted;

@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize timeout = _timeout;

@synthesize urlConnection = _urlConnection;
@synthesize responseData = _responseData;

@synthesize finishSelector = _finishSelector;
@synthesize failSelector = _failSelector;

#pragma mark - Private

- (void)requestTimeOut {
    NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseTimeout userInfo:nil];
    if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
        [self.delegate finishedRequest:self.url code:ABHTTPResponseTimeout content:nil error:error];
    }
    
    if ([self.delegate respondsToSelector:self.failSelector]) {
        [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseTimeout], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
    }
    self.urlConnection = nil;
	self.isCompleted = YES;
}

#pragma mark - lifecycle

+ (id)requestWithURL:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector {
    ABHTTPRequest *request = [[[ABHTTPRequest alloc] init] autorelease];
    [request setUrl:url];
    [request setParameters:parameter];
    [request setTimeout:timeout];
    [request setDelegate:delegate];
    [request setFinishSelector:finishSelector];
    [request setFailSelector:failSelector];
    
    return request;
}

- (void)main {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *tmpUrl = [NSURL URLWithString:self.url];
    
    if (tmpUrl) {
        if (hasConnection()) {
            
            if ([self.delegate respondsToSelector:@selector(willBeginRequest:)]) 
                [self.delegate willBeginRequest:self.url];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];   //new mutableURLRequest with url and timeout, if the request is POST, then the timeout is invalid.
            
            if(self.parameters && [[self.parameters allKeys] count] > 0){
                [request setHTTPMethod:@"POST"];    //set request method to POST.
                
                NSString * postString = @"";
                NSArray * keys = [self.parameters allKeys];
                for(NSString * key in keys){
                    NSString * _data = (NSString *)[self.parameters objectForKey:key];
                    postString = [postString stringByAppendingFormat:@"&%@=%@",key,_data]; 
                }
                
                NSMutableData *postBody = [NSMutableData data];
                [postBody appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                
                [request setHTTPBody:postBody]; //set http body.
                [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:self.timeout];
            }
            
            NSString *contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded"];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            self.isCompleted = NO;
            self.responseData = [NSMutableData data];
            
            _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            while(!self.isCompleted && ![self isCancelled]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        } else {
            NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseNoConnection userInfo:nil];
            if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
                [self.delegate finishedRequest:self.url code:ABHTTPResponseNoConnection content:nil error:error];
            }
            
            if ([self.delegate respondsToSelector:self.failSelector]) {
                [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseNoConnection], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
            }
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseInvalidURL userInfo:nil];
        if ([self.delegate respondsToSelector:@selector(finishedReuqest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseInvalidURL content:nil error:error];
        }
        
        if ([self.delegate respondsToSelector:self.failSelector]) {
            [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseInvalidURL], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
        }
    }
    
	[pool release];
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
    
    if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
        [self.delegate finishedRequest:self.url code:ABHTTPResponseError content:nil error:error];
    }
    
    if ([self.delegate respondsToSelector:self.failSelector]) {
        [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseError], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
    }
    
	self.responseData = nil;    //set the data to nil.
	self.isCompleted = YES;  //set isCompleted to YES.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOut) object:nil];
    
	NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    if ((httpResponse.statusCode / 100) != 2) { // is the statuCode is not 2**, then there is error.
        
        NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseError userInfo:nil];
        
        if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseError content:nil error:error];
        }
        
        if ([self.delegate respondsToSelector:self.failSelector]) {
            [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseError], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
        }
        
        self.responseData = nil;    //set the data to nil.
        self.isCompleted = YES;  //set isCompleted to YES.
    }
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.responseData appendData:data]; //append Data
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.isCompleted) 
        return;
    
    NSString *tempStr = [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] autorelease];
    if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
        [self.delegate finishedRequest:self.url code:ABHTTPResponseSuccess content:tempStr error:nil];
    }
    
    if ([self.delegate respondsToSelector:self.finishSelector]) {
        [self.delegate performSelector:self.finishSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseSuccess], ABHTTPResponseKeyCode, tempStr, ABHTTPResponseKeyContent, nil]];
    }
    
	self.isCompleted = YES;
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.isCompleted = YES;
    }
    
    return self;
}

- (void)dealloc {
    self.url = nil;
    self.parameters = nil;
    self.urlConnection = nil;
    self.responseData = nil;
    [super dealloc];
}

@end

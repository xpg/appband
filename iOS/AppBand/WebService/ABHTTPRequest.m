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
#import "AB_SBJSON.h"

//Check whether the web connection is valid.
CG_INLINE BOOL hasConnection() {
    NetworkStatus status = [[ABReachability reachabilityForInternetConnection] currentReachabilityStatus];
	return (status == ReachableViaWiFi || status == ReachableViaWWAN) ? YES : NO;
}

@interface ABHTTPRequest()

@property(assign) BOOL isCompleted;

@property(nonatomic,readwrite,copy) NSString *key;
@property(nonatomic,readwrite,copy) NSString *url;
@property(nonatomic,copy) NSDictionary *parameters;
@property(nonatomic,assign) NSTimeInterval timeout;

@property(nonatomic,retain) NSURLConnection *urlConnection;
@property(nonatomic,retain) NSMutableData *responseData;

- (void)requestTimeOut;

- (void)requestCancelled;

@end

@implementation ABHTTPRequest

@synthesize delegate = _delegate;
@synthesize agent = _agent;
@synthesize isCompleted = _isCompleted;

@synthesize key = _key;
@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize timeout = _timeout;

@synthesize urlConnection = _urlConnection;
@synthesize responseData = _responseData;

@synthesize finishSelector = _finishSelector;
@synthesize failSelector = _failSelector;
@synthesize agentSelector = _agentSeletor;

#pragma mark - Private

- (void)requestTimeOut {
    NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseTimeout userInfo:nil];
    if ([self.agent respondsToSelector:self.agentSelector]) {
        [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseTimeout], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
    } else {
        if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseTimeout content:nil error:error];
        }
        
        if ([self.delegate respondsToSelector:self.failSelector]) {
            [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseTimeout], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
        }
    }
    
    self.delegate = nil;
    self.urlConnection = nil;
	self.isCompleted = YES;
}

- (void)requestCancelled {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOut) object:nil];
    
    NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseCancel userInfo:nil];
    if ([self.agent respondsToSelector:self.agentSelector]) {
        [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseCancel], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
    } else {
        if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseCancel content:nil error:error];
        }
        
        if ([self.delegate respondsToSelector:self.failSelector]) {
            [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseCancel], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
        }
    }
    
    self.delegate = nil;
    self.urlConnection = nil;
	self.isCompleted = YES;
}

#pragma mark - lifecycle

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector {
    ABHTTPRequest *request = [[[ABHTTPRequest alloc] init] autorelease];
    [request setKey:key];
    [request setUrl:url];
    [request setParameters:parameter];
    [request setTimeout:timeout];
    [request setDelegate:delegate];
    [request setFinishSelector:finishSelector];
    [request setFailSelector:failSelector];
    [request setAgent:nil];
    [request setAgentSelector:nil];
    
    return request;
}

+ (id)requestWithKey:(NSString *)key 
                 url:(NSString *)url 
           parameter:(NSDictionary *)parameter 
             timeout:(NSTimeInterval)timeout 
            delegate:(id<ABHTTPRequestDelegate>)delegate 
              finish:(SEL)finishSelector
                fail:(SEL)failSelector 
               agent:(id)agent 
       agentSelector:(SEL)agentSeletor {
    ABHTTPRequest *request = [[[ABHTTPRequest alloc] init] autorelease];
    [request setKey:key];
    [request setUrl:url];
    [request setParameters:parameter];
    [request setTimeout:timeout];
    [request setDelegate:delegate];
    [request setFinishSelector:finishSelector];
    [request setFailSelector:failSelector];
    [request setAgent:agent];
    [request setAgentSelector:agentSeletor];
    
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
                
//                NSString * postString = @"";
//                NSArray * keys = [self.parameters allKeys];
//                for(NSString * key in keys){
//                    NSString * _data = (NSString *)[self.parameters objectForKey:key];
//                    postString = [postString stringByAppendingFormat:@"&%@=%@",key,_data]; 
//                }
                AB_SBJSON *sbJson = [[AB_SBJSON alloc] init];
                NSString *postString = [sbJson stringWithObject:self.parameters error:nil];
                
                NSMutableData *postBody = [NSMutableData data];
                [postBody appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                
                [request setHTTPBody:postBody]; //set http body.
                [sbJson release];
                [self performSelector:@selector(requestTimeOut) withObject:nil afterDelay:self.timeout];
            }
            
//            NSString *contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded"];
            NSString *contentType = [NSString stringWithFormat:@"application/json"];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            [request setValue:contentType forHTTPHeaderField:@"Accept"];
            
            self.isCompleted = NO;
            self.responseData = [NSMutableData data];
            
            _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            while(!self.isCompleted && ![self isCancelled]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
            if ([self isCancelled] && !self.isCompleted) {
                [self requestCancelled];
            }
            
        } else {
            NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseNoConnection userInfo:nil];
            if ([self.agent respondsToSelector:self.agentSelector]) {
                [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseNoConnection], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
            } else {
                if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
                    [self.delegate finishedRequest:self.url code:ABHTTPResponseNoConnection content:nil error:error];
                }
                
                if ([self.delegate respondsToSelector:self.failSelector]) {
                    [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseNoConnection], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
                }
            }
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:ABHTTPResponseInvalidURL userInfo:nil];
        if ([self.agent respondsToSelector:self.agentSelector]) {
            [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseInvalidURL], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
        } else {
            if ([self.delegate respondsToSelector:@selector(finishedReuqest:code:content:error:)]) {
                [self.delegate finishedRequest:self.url code:ABHTTPResponseInvalidURL content:nil error:error];
            }
            
            if ([self.delegate respondsToSelector:self.failSelector]) {
                [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseInvalidURL], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
            }
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
    
    if ([self.agent respondsToSelector:self.agentSelector]) {
        [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseServerError], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
    } else {
        if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseServerError content:nil error:error];
        }
        
        if ([self.delegate respondsToSelector:self.failSelector]) {
            [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseServerError], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
        }
    }
    
    self.delegate = nil;
	self.responseData = nil;    //set the data to nil.
	self.isCompleted = YES;  //set isCompleted to YES.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOut) object:nil];
    
	NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    if ((httpResponse.statusCode / 100) != 2) { // is the statuCode is not 2**, then there is error.
        
        NSError *error = [NSError errorWithDomain:ABHTTPRequestErrorDomain code:httpResponse.statusCode userInfo:nil];
        if ([self.agent respondsToSelector:self.agentSelector]) {
            [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:httpResponse.statusCode], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, self, ABHTTPRequesterObject, nil]];
        } else {
            if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
                [self.delegate finishedRequest:self.url code:httpResponse.statusCode content:nil error:error];
            }
            
            if ([self.delegate respondsToSelector:self.failSelector]) {
                [self.delegate performSelector:self.failSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:httpResponse.statusCode], ABHTTPResponseKeyCode, error, ABHTTPResponseKeyError, nil]];
            }
        }
        
        self.delegate = nil;
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
    
    if ([self.agent respondsToSelector:self.agentSelector]) {
        [self.agent performSelector:self.agentSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseSuccess], ABHTTPResponseKeyCode, tempStr, ABHTTPResponseKeyContent, self, ABHTTPRequesterObject, nil]];
    } else {
        if ([self.delegate respondsToSelector:@selector(finishedRequest:code:content:error:)]) {
            [self.delegate finishedRequest:self.url code:ABHTTPResponseSuccess content:tempStr error:nil];
        }
        
        if ([self.delegate respondsToSelector:self.finishSelector]) {
            [self.delegate performSelector:self.finishSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, ABHTTPResponseKeyURL, [NSNumber numberWithInt:ABHTTPResponseSuccess], ABHTTPResponseKeyCode, tempStr, ABHTTPResponseKeyContent, nil]];
        }
    }
    
    self.delegate = nil;
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
    DLog(@"ABHTTPRequest dealloc - url: %@",self.url);
    self.key = nil;
    self.url = nil;
    self.parameters = nil;
    self.urlConnection = nil;
    self.responseData = nil;
    [super dealloc];
}

@end
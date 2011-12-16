//
//  ABDownloadRequest.m
//  AppBand
//
//  Created by Jason Wang on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDownloadRequest.h"

#import "ABPurchaseResponse.h"

#import "ABGlobal.h"

@interface ABDownloadRequest()

- (void)doCancelledJob;

- (BOOL)createFileAtPath:(NSString *)path overwirte:(BOOL)overwirte;

- (void)sendABPurchaseResponse:(ABResponseCode)code 
                proccessStatus:(ABPurchaseProccessStatus)proccessStatus 
                        status:(ABPurchaseStatus)status 
                      proccess:(float)proccess 
                      filePath:(NSString *)filePath 
                         error:(NSError *)error;

@end

@implementation ABDownloadRequest

@synthesize productId = _productId;
@synthesize url = _url;
@synthesize path = _path;
@synthesize notificationKey = _notificationKey;

@synthesize filePath = _filePath;
@synthesize transationId = _transationId;

#pragma mark - Private

- (void)doCancelledJob {
    if (self.filePath) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:NO]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        }
    }
    [self sendABPurchaseResponse:ABResponseCodeHTTPSuccess proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusDeliverCancelled proccess:0. filePath:nil error:nil];
}

- (BOOL)createFileAtPath:(NSString *)path overwirte:(BOOL)overwirte {
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO]) {
		if (overwirte) {
			if (![[NSFileManager defaultManager] removeItemAtPath:path error:NULL])
				return NO;
		}
	}
	return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

- (void)sendABPurchaseResponse:(ABResponseCode)code 
                proccessStatus:(ABPurchaseProccessStatus)proccessStatus 
                        status:(ABPurchaseStatus)status 
                      proccess:(float)proccess 
                      filePath:(NSString *)filePath 
                         error:(NSError *)error {
    
    ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
    [productResponse setProductId:self.productId];
    [productResponse setCode:code];
    [productResponse setError:error];
    [productResponse setProccessStatus:proccessStatus];
    [productResponse setStatus:status];
    [productResponse setProccess:proccess];
    [productResponse setFilePath:filePath];
    
    NSDictionary *userInfo = nil;
    if (status == ABPurchaseStatusSuccess) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.transationId, AB_Transaction_ID, nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationKey object:productResponse userInfo:userInfo];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	NSDictionary *headerDic = [httpResponse allHeaderFields];
    
    self.filePath = [self.path stringByAppendingPathComponent:[response suggestedFilename]];
    if ([self createFileAtPath:self.filePath overwirte:YES]) {
        _handle = [[NSFileHandle fileHandleForWritingAtPath:self.filePath] retain];
    }
    
    
	if(headerDic) {
		if ([headerDic objectForKey: @"Content-Range"]) {
			NSString *contentRange = [headerDic objectForKey: @"Content-Range"];
			NSRange range = [contentRange rangeOfString: @"/"];
			NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
			_expectedBytes = [totalBytesCount floatValue];
		} else if ([headerDic objectForKey: @"Content-Length"]) {
			_expectedBytes = [[headerDic objectForKey: @"Content-Length"] floatValue];
		} else {
			_expectedBytes = -1;
		}
		
		if ([@"Identity" isEqualToString: [headerDic objectForKey: @"Transfer-Encoding"]]) {
			_expectedBytes = _bytesReceived;
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	float receivedLen = [data length];
	_bytesReceived = (_bytesReceived + receivedLen);
	if(_expectedBytes != NSURLResponseUnknownLength) {
		_completePercent = ((_bytesReceived / _expectedBytes) * 100) / 100;
		[_handle writeData:data];
        
        [self sendABPurchaseResponse:ABResponseCodeHTTPSuccess proccessStatus:ABPurchaseProccessStatusDoing status:ABPurchaseStatusDelivering proccess:_completePercent filePath:nil error:nil];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.filePath) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:NO]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        }
    }
    
	[_connection  release];
	_connection = nil;
    
    [self sendABPurchaseResponse:ABResponseCodeHTTPError proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusDeliverFail proccess:0. filePath:nil error:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil]];
	
	_done = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self sendABPurchaseResponse:ABResponseCodeHTTPSuccess proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusSuccess proccess:1.0 filePath:self.filePath error:nil];
	
	_done = YES;
}

#pragma mark - main

- (void)main {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if ([self isCancelled]) {
        [self doCancelledJob];
    } else {
        NSURL *fileURL = [NSURL URLWithString:self.url];
        if (fileURL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            
            _done = NO;
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        
        while(!_done && ![self isCancelled]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        if (!_done && [self isCancelled]) {
            [self doCancelledJob];
        }
    }
    
	[pool release];
}

#pragma mark - lifecycle

+ (id)downloadWithProductId:(NSString *)productId 
               transationId:(NSString *)transationId 
                        url:(NSString *)url
                       path:(NSString *)path 
            notificationKey:(NSString *)notificationKey {
    ABDownloadRequest *downloader = [[[ABDownloadRequest alloc] init] autorelease];
    [downloader setTransationId:transationId];
    [downloader setProductId:productId];
    [downloader setUrl:url];
    [downloader setPath:path];
    [downloader setNotificationKey:notificationKey];
    
    return downloader;
}

- (id)init {
    self = [super init];
    if (self) {
        _done = YES;
        _bytesReceived = 0.0;
    }
    
    return self;
}

- (void)dealloc {
    DLog(@"ABDownloadRequest dealloc - url: %@",self.url);
    [self setTransationId:nil];
    [self setFilePath:nil];
    [self setProductId:nil];
    [self setUrl:nil];
    [self setPath:nil];
    [self setNotificationKey:nil];
    [super dealloc];
}

@end

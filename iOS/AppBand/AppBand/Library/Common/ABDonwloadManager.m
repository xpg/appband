//
//  ABDonwloadManager.m
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDonwloadManager.h"

#import "AppBand.h"

#import "ABDownloadRequest.h"
#import "ABPurchaseResponse.h"
#import "ABRestCenter.h"
#import "ABHTTPRequest.h"

@interface ABDonwloadManager()

- (void)cancelAllDownload;

- (void)addRecord:(NSNotification *)notification;

@end

@implementation ABDonwloadManager

SINGLETON_IMPLEMENTATION(ABDonwloadManager)

#pragma mark - Private

- (void)cancelAllDownload {
    [_downloaderQueue cancelAllOperations];
}

- (void)addRecord:(NSNotification *)notification {
    ABPurchaseResponse *response = [notification object];
    
    if (response.proccessStatus == ABPurchaseProccessStatusEnd && response.status == ABPurchaseStatusSuccess) {
        
        NSString *tId = [[notification userInfo] objectForKey:AB_Transaction_ID];
        
        if (tId && ![tId isEqualToString:@""]) {
            NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
            NSString *server = [[AppBand shared] server];
            NSString *appKey = [[AppBand shared] appKey];
            NSString *appSecret = [[AppBand shared] appSecret];
            NSString *udid = [[AppBand shared] udid];
            NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
            NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products/transactions/%@",
                                   server, appKey,tId];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setObject:appSecret forKey:AB_APP_SECRET];
            [parameters setObject:token forKey:AB_DEVICE_TOKEN];
            [parameters setObject:udid forKey:AB_DEVICE_UDID];
            [parameters setObject:bundleId forKey:AB_APP_BUNDLE_IDENTIFIER];
            [parameters setObject:version forKey:AB_APP_BUNDLE_VERSION];
            
            ABHTTPRequest *request = [ABHTTPRequest requestWithKey:urlString
                                                               url:urlString 
                                                         parameter:parameters
                                                           timeout:kAppBandRequestTimeout
                                                          delegate:nil
                                                            finish:nil
                                                              fail:nil];
            [[ABRestCenter shared] addRequest:request];
        }
    }
}

#pragma mark - Public

- (void)deliverWithProductId:(NSString *)productId 
                transationId:(NSString *)transationId 
                         url:(NSString*)url 
                    savePath:(NSString*)path 
             notificationKey:(NSString*)notificationKey {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationKey object:nil];
    ABDownloadRequest *downloader = [ABDownloadRequest downloadWithProductId:productId 
                                                                transationId:transationId 
                                                                         url:url 
                                                                        path:path 
                                                             notificationKey:notificationKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRecord:) name:notificationKey object:nil];
    
    [_downloaderQueue addOperation:downloader];
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _downloaderQueue = [[NSOperationQueue alloc] init];
        [_downloaderQueue setMaxConcurrentOperationCount:3];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllDownload) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_downloaderQueue release];
    [super dealloc];
}

@end

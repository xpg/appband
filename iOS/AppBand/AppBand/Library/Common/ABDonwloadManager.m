//
//  ABDonwloadManager.m
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDonwloadManager.h"

#import "ABDownloadRequest.h"

#import "ABPurchaseResponse.h"

@implementation ABDonwloadManager

SINGLETON_IMPLEMENTATION(ABDonwloadManager)

#pragma mark - Private

- (void)addRecord:(NSNotification *)notification {
    ABPurchaseResponse *response = [notification object];
    
    if (response.proccessStatus == ABPurchaseProccessStatusEnd && response.status == ABPurchaseStatusSuccess) {
        
    }
}

#pragma mark - Public

- (void)deliverWithProductId:(NSString *)productId url:(NSString*)url savePath:(NSString*)path notificationKey:(NSString*)notificationKey {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationKey object:nil];
    ABDownloadRequest *downloader = [ABDownloadRequest downloadWithProductId:productId url:url path:path notificationKey:notificationKey];
    
    [_downloaderQueue addOperation:downloader];
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _downloaderQueue = [[NSOperationQueue alloc] init];
        [_downloaderQueue setMaxConcurrentOperationCount:3];
    }
    
    return self;
}

- (void)dealloc {
    [_downloaderQueue release];
    [super dealloc];
}

@end

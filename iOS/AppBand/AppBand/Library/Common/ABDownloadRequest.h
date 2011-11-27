//
//  ABDownloadRequest.h
//  AppBand
//
//  Created by Jason Wang on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABDownloadRequest : NSOperation {
    @private
        NSString *_productId;
        NSString *_url;
        NSString *_path;
        NSString *_notificationKey;
    
        NSURLConnection *_connection;
        
        NSFileHandle *_handle;
    
        float _bytesReceived;
        long long _expectedBytes;
        float _completePercent;
	
        BOOL _done;
    
        NSString *_filePath;
}

@property(nonatomic,copy) NSString *productId;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *notificationKey;

@property(nonatomic,copy) NSString *filePath;

+ (id)downloadWithProductId:(NSString *)productId
                        url:(NSString *)url
                       path:(NSString *)path 
            notificationKey:(NSString *)notificationKey;

@end

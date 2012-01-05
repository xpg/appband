//
//  ABHttpRequest.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABHttpRequestDelegate;

@interface ABHttpRequest : NSObject {
    id<ABHttpRequestDelegate> delegate;
}

@property(nonatomic,assign) id<ABHttpRequestDelegate> delegate;

+ (id)requestWithTarget:(id<ABHttpRequestDelegate>)del;

- (void)start;

- (void)finishLoadingWithContent:(NSString *)content error:(NSError *)error;

@end

@protocol ABHttpRequestDelegate <NSObject>

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoading:(NSString *)content error:(NSError *)error;

@end

//
//  ABProvisioning.h
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

@interface ABProvisioning : NSObject 

@property(nonatomic,readonly,copy) NSString *serverEndpoint;

- (void)start;

@end

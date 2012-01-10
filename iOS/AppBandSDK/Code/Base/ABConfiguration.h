//
//  ABConfiguration.h
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

@interface ABConfiguration : NSObject 

//The Server Address
@property(copy) NSString *server;

//Whether handle push notification by SDK
@property(assign) BOOL handlePushAuto;

//Whether handle rich notification by SDK
@property(assign) BOOL handleRichAuto;

/*
 * Get configuration paramters from server. 
 * 
 */
- (void)provisioning;

@end

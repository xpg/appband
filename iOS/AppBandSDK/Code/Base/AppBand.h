//
//  AppBandBase.h
//  AppBandBase
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABProvisioning.h"
#import "ABLog.h"

/**
 Set the App logging component. This header
 file is generally only imported by apps that
 are pulling in all of RestKit. By setting the 
 log component to App here, we allow the app developer
 to use RKLog() in their own app.
 */
#undef ABLogComponent
#define ABLogComponent lcl_cApp

@interface AppBand : NSObject

@end

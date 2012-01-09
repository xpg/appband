//
//  ABSpecEnvironment.h
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <SenTestingKit/SenTestingKit.h>

#import "AppBand.h"

// OCMock -- Fix this macro, otherwise OCMOCK_VALUE(YES) doesn't work
#undef OCMOCK_VALUE
#define OCMOCK_VALUE(variable) [NSValue value:&variable withObjCType:@encode(__typeof(variable))]

// Base class for specs. Allows UISpec to run the specs and use of Hamcrest matchers...
@interface ABSpec : SenTestCase
@end

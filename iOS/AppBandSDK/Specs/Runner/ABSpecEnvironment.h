//
//  ABSpecEnvironment.h
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>

#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "AppBand.h"

// Base class for specs. Allows UISpec to run the specs and use of Hamcrest matchers...
@interface ABSpec : SenTestCase
@end

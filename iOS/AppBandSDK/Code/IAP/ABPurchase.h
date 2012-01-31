//
//  ABPurchase.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/20/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABConstants.h"

@protocol ABPurchaseDelegate;

@interface ABPurchase : NSObject {
    id<ABPurchaseDelegate> delegate;
}

@property(nonatomic,assign) id<ABPurchaseDelegate> delegate;

SINGLETON_INTERFACE(ABPurchase)

/*
 * Get Products List
 * 
 * Paramters:
 *         group: products group, nil is for all products.
 *        target: callback invocator.
 *finishSelector: the SEL will call when done. Notice That: The selector must only has one paramter, which is NSArray object
 */
- (void)getAppProductByGroup:(NSString *)group 
                      target:(id)target 
              finishSelector:(SEL)finishSelector;

@end

@protocol ABPurchaseDelegate <NSObject>

@optional

- (void)finishGetProducts:(id)response group:(NSString *)group;

@end

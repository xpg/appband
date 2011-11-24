//
//  ABPurchase.h
//  AppBand
//
//  Created by Jason Wang on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABGlobal.h"
#import "ABProduct.h"

@interface ABPurchase : NSObject

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
             finfishSelector:(SEL)finishSelector;

/*
 * Purchase Product
 * 
 * Paramters:
 *       product: product.
 *       
 */
- (void)purchaseProduct:(ABProduct *)product 
           statusTarget:(id)statusTarget 
         statusSelector:(SEL)statusSelector 
         proccessTarget:(id)proccessTarget 
       proccessSelector:(SEL)proccessSeletor;

@end

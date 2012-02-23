//
//  ABAppUser.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABAppUserSettings : NSObject

- (id)getValueOfKey:(NSString *)key;

- (void)setValue:(id)value forKey:(NSString *)key;

- (void)synchronized;

@end

@interface ABAppUser : NSObject

//The Device Token
@property(nonatomic,copy) NSString *token;

//The Device UDID
@property(nonatomic,copy) NSString *udid;

//The Device Alias
@property(nonatomic,copy) NSString *alias;

//The Tags
@property(nonatomic,copy) NSString *tags;

@property(nonatomic,copy) NSDictionary *geo;

@property(nonatomic,assign) BOOL pushEnable;

@property(nonatomic,copy) NSArray *pushIntervals;

@property(nonatomic,assign) BOOL tokenDisable;

/*
 * Synchronize Device Data to Server. 
 * 
 */
- (id)initWithSettings:(ABAppUserSettings *)settings;

/*
 * Synchronize Device Data to Server. 
 * 
 */
- (void)syncDataToServerWithTarget:(id)target;

@end

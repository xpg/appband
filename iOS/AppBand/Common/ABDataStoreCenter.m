//
//  ABDataStoreCenter.m
//  AppBandLib
//
//  Created by Jason Wang on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDataStoreCenter.h"

@interface ABDataStoreCenter()

@property(nonatomic,assign) BOOL needRefresh;

- (BOOL)isSameToOriginValue:(id)value forKey:(NSString *)key;

@end

@implementation ABDataStoreCenter

@synthesize needRefresh = _needRefresh;

SINGLETON_IMPLEMENTATION(ABDataStoreCenter)

#pragma mark - Public

- (BOOL)isDuty {
    return self.needRefresh;
}

- (id)getValueOfKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (![self isSameToOriginValue:value forKey:key]) {
        self.needRefresh = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kAppBandDeviceDuty];
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setValuesAndKeys:(NSDictionary *)valuesAndKeys {
    NSArray *keys = [valuesAndKeys allKeys];
    
    for (NSString *key in keys) {
        if (![self isSameToOriginValue:[valuesAndKeys objectForKey:key] forKey:key]) {
            self.needRefresh = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kAppBandDeviceDuty];
            [[NSUserDefaults standardUserDefaults] setObject:[valuesAndKeys objectForKey:key] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)synchronizedWithServer {
    self.needRefresh = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.needRefresh] forKey:kAppBandDeviceDuty];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private

- (BOOL)isSameToOriginValue:(id)value forKey:(NSString *)key {
    id oldValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (oldValue) {
        if ([oldValue isKindOfClass:[NSValue class]]) {
            if ([value isKindOfClass:[NSValue class]] && [oldValue isEqualToValue:value]) return YES;
        } else if ([oldValue isKindOfClass:[NSString class]]) {
            if ([value isKindOfClass:[NSString class]] && [oldValue isEqualToString:value]) return YES;
        }
    }
    
    return NO;
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        NSNumber *numValue = [[NSUserDefaults standardUserDefaults] objectForKey:kAppBandDeviceDuty];
        if (!numValue) {
            self.needRefresh = YES;
        } else {
            self.needRefresh = [numValue boolValue];
        }
    }
    
    return self;
}

@end

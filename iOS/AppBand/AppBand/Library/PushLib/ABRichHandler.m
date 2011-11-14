//
//  ABRichHandler.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "ABRichHandler.h"

#import "ABRichResponse.h"

#import "AppBand.h"
#import "ABGlobal.h"

#import "ABRestCenter.h"
#import "ABHTTPRequest.h"

#import "AB_SBJSON.h"

@interface ABRichHandler()

@property(nonatomic,assign) id impressionTarget;
@property(nonatomic,assign) SEL impressionSelector;

@property(nonatomic,readwrite,copy) NSString *fetchKey;
@property(nonatomic,readwrite,copy) NSString *impressionKey;

- (void)getRichEnd:(NSDictionary *)response;

- (void)impressionEnd:(NSDictionary *)response;

@end

@implementation ABRichHandler

@synthesize rid = _rid;
@synthesize fetchTarget = _fetchTarget;
@synthesize fetchSelector = _fetchSelector;
@synthesize impressionTarget = _impressionTarget;
@synthesize impressionSelector = _impressionSelector;

@synthesize fetchKey = _fetchKey;
@synthesize impressionKey = _impressionKey;

#pragma mark - Private

- (void)getRichEnd:(NSDictionary *)response {
    ABHTTPResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    if ([self.fetchTarget respondsToSelector:self.fetchSelector]) {
        ABRichResponse *r = [[[ABRichResponse alloc] init] autorelease];
        [r setCode:[[response objectForKey:ABHTTPResponseKeyCode] intValue]];
        [r setError:[response objectForKey:ABHTTPResponseKeyError]];
        
        //parser rich json
        NSString *resp = [response objectForKey:ABHTTPResponseKeyContent];
        
        NSError *error = nil;
        AB_SBJSON *json = [[AB_SBJSON alloc] init];
        NSDictionary *richDic = [json objectWithString:resp error:&error];
        if (richDic && !error) {
            [r setRichTitle:[richDic objectForKey:AB_Rich_Title]];
            [r setRichContent:[richDic objectForKey:AB_Rich_Content]];
        }
        [json release];
        
        [self.fetchTarget performSelector:self.fetchSelector withObject:r];
    }
    
    if (code == ABHTTPResponseSuccess) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",
                               [[AppBand shared] server], @"/impressions/",self.rid];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[AppBand shared] appKey], AB_APP_KEY, [[AppBand shared] appSecret], AB_APP_SECRET, nil];
        
        ABHTTPRequest *request = [ABHTTPRequest requestWithKey:self.impressionKey 
                                                           url:urlString 
                                                     parameter:parameters
                                                       timeout:kAppBandRequestTimeout
                                                      delegate:self
                                                        finish:@selector(impressionEnd:)
                                                          fail:@selector(impressionEnd:)];
        [[ABRestCenter shared] addRequest:request];
    } else {
        DLog(@"get rich content fail, error code :%i",code);
        if ([self.impressionTarget respondsToSelector:self.impressionSelector]) {
            [self.impressionTarget performSelector:self.impressionSelector withObject:self];
        }
    }
    
}

- (void)impressionEnd:(NSDictionary *)response {
    if ([self.impressionTarget respondsToSelector:self.impressionSelector]) {
        [self.impressionTarget performSelector:self.impressionSelector withObject:self];
    }
}

#pragma mark - Public

- (void)begin {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?token=%@&k=%@&s=%@",
                           [[AppBand shared] server], @"/rich_contents/",self.rid,[[AppBand shared] deviceToken],[[AppBand shared] appKey],[[AppBand shared] appSecret]];
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:self.fetchKey 
                                                       url:urlString 
                                                 parameter:nil
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(getRichEnd:)
                                                      fail:@selector(getRichEnd:)];
    [[ABRestCenter shared] addRequest:request];
}

- (void)cancel {
    NSEnumerator *enumerator = [[[[ABRestCenter shared] queue] operations] objectEnumerator];
    ABHTTPRequest *request = nil;
    while (request = [enumerator nextObject]) {
        if ([request.key isEqualToString:self.fetchKey] || [request.key isEqualToString:self.impressionKey]) {
            [request cancel];
        }
    }
}

#pragma mark - livecycle

+ (ABRichHandler *)handlerWithRichID:(NSString *)richID 
                         fetchTarget:(id)fetchTarget 
                       fetchSelector:(SEL)fetchSelector 
                    impressionTarget:(id)impressionTarget
                  impressionSelector:(SEL)impressionSelector {
    ABRichHandler *handle = [[[ABRichHandler alloc] init] autorelease];
    [handle setFetchKey:[NSString stringWithFormat:@"%@%@",Fetch_Rich_ID_Prefix,richID]];
    [handle setImpressionKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,richID]];
    [handle setRid:richID];
    [handle setFetchTarget:fetchTarget];
    [handle setFetchSelector:fetchSelector];
    [handle setImpressionTarget:impressionTarget];
    [handle setImpressionSelector:impressionSelector];
    
    return handle;
}

- (void)dealloc {
    [self setRid:nil];
    [self setFetchKey:nil];
    [self setImpressionKey:nil];
    [super dealloc];
}

@end

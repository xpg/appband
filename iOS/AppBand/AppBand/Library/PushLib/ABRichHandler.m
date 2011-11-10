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

@interface ABRichHandler()

@property(nonatomic,assign) id impressionTarget;
@property(nonatomic,assign) SEL impressionSelector;

- (void)getRichEnd:(NSDictionary *)response;

- (void)impressionEnd:(NSDictionary *)response;

@end

@implementation ABRichHandler

@synthesize rid = _rid;
@synthesize fetchTarget = _fetchTarget;
@synthesize fetchSelector = _fetchSelector;
@synthesize impressionTarget = _impressionTarget;
@synthesize impressionSelector = _impressionSelector;

#pragma mark - Private

- (void)getRichEnd:(NSDictionary *)response {
    ABHTTPResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    if (code == ABHTTPResponseSuccess) {
        if ([self.fetchTarget respondsToSelector:self.fetchSelector]) {
            ABRichResponse *r = [[[ABRichResponse alloc] init] autorelease];
            [r setCode:[[response objectForKey:ABHTTPResponseKeyCode] intValue]];
            [r setError:[response objectForKey:ABHTTPResponseKeyError]];
            [r setRichContent:[response objectForKey:ABHTTPResponseKeyContent]];
            
            [self.fetchTarget performSelector:self.fetchSelector withObject:r];
        }
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",
                               [[AppBand shared] server], @"/impression/",self.rid];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[AppBand shared] appKey], AB_APP_KEY, [[AppBand shared] appSecret], AB_APP_SECRET, nil];
        
        ABHTTPRequest *request = [ABHTTPRequest requestWithURL:urlString 
                                                     parameter:parameters
                                                       timeout:kAppBandRequestTimeout
                                                      delegate:self
                                                        finish:@selector(impressionEnd:)
                                                          fail:@selector(impressionEnd:)];
        [[ABRestCenter shared] addRequest:request];
    }
    
}

- (void)impressionEnd:(NSDictionary *)response {
    if ([self.impressionTarget respondsToSelector:self.impressionSelector]) {
        [self.impressionTarget performSelector:self.impressionSelector withObject:self];
    }
}

#pragma mark - Public

- (void)begin {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",
                           [[AppBand shared] server], @"/rich_content/",self.rid];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[AppBand shared] appKey], AB_APP_KEY, [[AppBand shared] appSecret], AB_APP_SECRET, nil];
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithURL:urlString 
                                                 parameter:parameters
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(getRichEnd:)
                                                      fail:@selector(getRichEnd:)];
    [[ABRestCenter shared] addRequest:request];
}

#pragma mark - livecycle

+ (ABRichHandler *)handlerWithRichID:(NSString *)richID 
                         fetchTarget:(id)fetchTarget 
                       fetchSelector:(SEL)fetchSelector 
                    impressionTarget:(id)impressionTarget
                  impressionSelector:(SEL)impressionSelector {
    ABRichHandler *handle = [[[ABRichHandler alloc] init] autorelease];
    [handle setRid:richID];
    [handle setFetchTarget:fetchTarget];
    [handle setFetchSelector:fetchSelector];
    [handle setImpressionTarget:impressionTarget];
    [handle setImpressionSelector:impressionSelector];
    
    return handle;
}

- (void)dealloc {
    [self setRid:nil];
    [super dealloc];
}

@end

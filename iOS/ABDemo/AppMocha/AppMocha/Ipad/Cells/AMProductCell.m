//
//  AMProductCell.m
//  AppMocha
//
//  Created by Jason Wang on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AMProductCell.h"

#import "AppBandKit.h"
#import "AMAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface AMProductCell()

@property(nonatomic,retain) AMDemoProduct *product;

- (void)setProductIcon:(UIImage *)image;

- (void)downloadIcon;

- (void)setProgress:(NSNumber *)progress;

- (void)downloadSuccess:(NSString *)path;

@end

@implementation AMProductCell

@synthesize product = _product;

- (void)setProductIcon:(UIImage *)image {
    [iconView setImage:image];
}

- (void)downloadIcon {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.product.product.icon]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    self.product.icon = image;
    
    [self performSelectorOnMainThread:@selector(setProductIcon:) withObject:image waitUntilDone:YES];
    
    [pool drain];
}

- (void)setProgress:(NSNumber *)progress {
    [progressView setHidden:NO];
    [progressView setProgress:[progress floatValue]];
    [stateLabel setText:@"下载中"];
}

- (void)downloadSuccess:(NSString *)path {
    [self.product setFilePath:path];
    [self.product setIsDownload:YES];
    [stateLabel setText:@"查看"];
    [progressView setHidden:YES];
}

- (void)downloadProgress:(NSNotification *)notification {
    ABPurchaseResponse *response = [notification object];
    
    switch (response.proccessStatus) {
        case ABPurchaseProccessStatusEnd: {
            switch (response.status) {
                case ABPurchaseStatusSuccess: {
                    [self performSelectorOnMainThread:@selector(downloadSuccess:) withObject:response.filePath waitUntilDone:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case ABPurchaseProccessStatusDoing: {
            switch (response.status) {
               case ABPurchaseStatusDelivering: {
                    [self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:response.proccess] waitUntilDone:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}

- (void)setDemoProduct:(AMDemoProduct *)p {
    self.product = p;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [iconView setImage:nil];
    [nameLabel setText:p.product.skProduct.localizedTitle];
    [descriptionLabel setText:p.product.skProduct.localizedDescription];
    [progressView setHidden:YES];
    
    if (p.isDownload && [(AMAppDelegate *)[UIApplication sharedApplication].delegate availableString:p.filePath]) {
        [stateLabel setText:@"查看"];
    } else {
        NSString *nKey = [NSString stringWithFormat:@"%@%@",AppBand_App_Product_Prefix,self.product.product.productId];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProccess:) name:nKey object:nil];
        
        if (p.product.transaction) {
            [stateLabel setText:@"下载"];
        } else {
            [stateLabel setText:[p.product localizedPrice:p.product.skProduct]];
        }
    } 
    
    if (p.icon) {
        [self setProductIcon:p.icon];
    } else {
        if ([(AMAppDelegate *)[UIApplication sharedApplication].delegate availableString:p.product.icon]) {
            [self performSelectorInBackground:@selector(downloadIcon) withObject:nil];
        }
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [iconView.layer setCornerRadius:8.];
        [iconView.layer setMasksToBounds:YES];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setProduct:nil];
    [super dealloc];
}

@end

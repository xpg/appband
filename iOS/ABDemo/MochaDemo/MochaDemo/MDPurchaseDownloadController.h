//
//  MDPurchaseDownloadController.h
//  ABPush
//
//  Created by Jason Wang on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDPurchaseDownloadController : UIViewController {
    NSString *nKey;
    
    UIImageView *imageView;
    UIProgressView *progressView;
}

@property(nonatomic,copy) NSString *nKey;

@end

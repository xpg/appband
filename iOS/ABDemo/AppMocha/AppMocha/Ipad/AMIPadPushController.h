//
//  AMIPadPushController.h
//  AppMocha
//
//  Created by Jason Wang on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataManager.h"
#import "AMIPadRichView.h"

@class AMPushCell;

@interface AMIPadPushController : UIViewController <UITableViewDelegate,UITableViewDataSource,AMIPadRichViewDelegate> {
    CoreDataController *dataController;
    
    IBOutlet UITableView *pushTableView;
    
    IBOutlet AMPushCell *pushCell;
    
    IBOutlet AMIPadRichView *richView;
}

@property(nonatomic,retain) IBOutlet UITableView *pushTableView;

@end

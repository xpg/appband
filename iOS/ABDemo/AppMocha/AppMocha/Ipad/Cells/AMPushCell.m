//
//  AMPushCell.m
//  AppMocha
//
//  Created by Jason Wang on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AMPushCell.h"

@interface AMPushCell()

@property(nonatomic,retain) AMNotification *noti;

- (void)readRich:(NSNotification *)notification;

@end

@implementation AMPushCell

@synthesize noti = _noti;

@synthesize iconView;
@synthesize messageLabel;
@synthesize timeLabel;

- (void)readRich:(NSNotification *)notification {
    [self.iconView setImage:[UIImage imageNamed:@"iPad_AM_Rich_Read_Icon"]];
}

- (void)setNotification:(AMNotification *)notification {
    self.noti = notification;
    switch ([self.noti.type intValue]) {
        case 1: {
            [self.contentView setBackgroundColor:[UIColor colorWithRed:175. / 255 green:175. / 255 blue:175. / 255 alpha:1.]];
            if (!self.noti.content || [self.noti.content isEqualToString:@""]) {
                [self.iconView setImage:[UIImage imageNamed:@"iPad_AM_Rich_Unread_Icon"]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readRich:) name:[NSString stringWithFormat:@"%@%@",AppBand_App_Rich_Push_Read_Prefix,self.noti.abri] object:nil];
            } else {
                [self.iconView setImage:[UIImage imageNamed:@"iPad_AM_Rich_Read_Icon"]];
            }
            break;
        }
        default: {
            [self.contentView setBackgroundColor:[UIColor colorWithRed:234. / 255 green:236. / 255 blue:239. / 255 alpha:1.]];
            [self.iconView setImage:[UIImage imageNamed:@"iPad_AM_Push_Icon"]];
            break;
        }
    }
    
    [self.messageLabel setText:self.noti.message];
    [self.timeLabel setText:[self.noti.date description]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"%@%@",AppBand_App_Rich_Push_Read_Prefix,self.noti.abri] object:nil];
    [self setNoti:nil];
    [self setIconView:nil];
    [self setMessageLabel:nil];
    [self setTimeLabel:nil];
    [super dealloc];
}

@end

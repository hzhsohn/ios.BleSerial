//
//  MainCell.h
//  BleSerial
//
//  Created by Han.zh on 14-9-30.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbDevID;
@property (weak, nonatomic) IBOutlet UIImageView *imgRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbRSSI;

@end

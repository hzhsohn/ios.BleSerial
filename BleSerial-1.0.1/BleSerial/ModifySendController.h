//
//  ModifySendController.h
//  BleSerial
//
//  Created by Han.zh on 14-10-11.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModifySendController_Delegate <NSObject>

-(void) ModifySendControllerOK_cb:(NSString*)val;

@end


@interface ModifySendController : UIViewController

@property (assign,nonatomic) id<ModifySendController_Delegate> delegate;

//给文本付值
-(void) setContent:(NSString*)str;

@end

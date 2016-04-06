//
//  SelectRecvUIDController.h
//  BleSerial
//
//  Created by Han.zh on 14-10-2.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MzhBluetooth.h"

@protocol SelectRecvUIDController_Delegate <NSObject>

-(void) SelectRecvUIDController_cb:(UInt16)rServid :(UInt16)rCharid;

@end

@interface SelectRecvUIDController : UIViewController


@property (assign,nonatomic) id<SelectRecvUIDController_Delegate> delegate;

-(const char *) CBUUIDToString:(CBUUID *) UUID :(char*)dstString;
-(void)setService:(NSArray*)ary;

/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
@end

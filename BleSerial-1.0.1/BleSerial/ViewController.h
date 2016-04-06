//
//  TIBLEViewController.h
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/29/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MzhBluetooth.h"
#import "SelectRecvUIDController.h"
#import "SelectWriteUIDController.h"
#import "ModifySendController.h"

typedef struct _TagCmd{
    unsigned char cmd[128];
    short len;
}TagCmd;

@interface ViewController : UITableViewController <MzhBluetoothDelegate,
SelectRecvUIDController_Delegate,
SelectWriteUIDController_Delegate,
ModifySendController_Delegate>

// 设置连接对象
- (void)setPeripherals:(CBPeripheral*)peripheral;

//日志
- (void) log:(NSString *)text;

//将字符转字节
-(BOOL) trStrToCmd:(const char*)szTmp :(TagCmd*)pcmd;

@end

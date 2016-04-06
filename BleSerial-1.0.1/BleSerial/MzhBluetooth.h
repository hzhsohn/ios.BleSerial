//
//  TIBLECBKeyfob.h
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/31/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>


@protocol MzhBluetoothDelegate
//@optional
-(void)mzhBluetoothRSSI_cb:(CBPeripheral *)peripheral :(int)value;
-(void)mzhBluetoothDevState_cb:(CBCentralManagerState)state;
-(void)mzhBluetoothScan_cb:(CBPeripheral *)peripheral;
-(void)mzhBluetoothConnect_cb:(BOOL)result :(CBPeripheral *)peripheral;
-(void)mzhBluetoothService_cb:(CBPeripheral *)peripheral
                                   :(UInt16)serv_uuid;
-(void)mzhBluetoothCharacteristic_cb:(CBPeripheral *)peripheral
                                     :(UInt16)serv_uuid
                                     :(UInt16)characteristic_uuid;
-(void)mzhBluetoothRecv_cb:(UInt16)characteristic_uuid :(NSData*)data;
-(void)mzhBluetoothNotification_cb:(BOOL)b :(CBPeripheral *)peripheral
                                   :(UInt16)serv_uuid
                                   :(UInt16)characteristic_uuid;
@end

@interface MzhBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

@property (nonatomic,assign) id <MzhBluetoothDelegate> delegate;
@property (strong, nonatomic) CBCentralManager *CM; 
@property (strong, nonatomic) CBPeripheral *peripheral;

//参数设置
-(int) scanBluetoothDevice;//搜索
-(void)stopScanBluetooth;//搜索
-(BOOL)connect:(CBPeripheral *)p;
-(void)disconnect;

//写入数据到烂牙
-(BOOL) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data;
-(BOOL) writeValue2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;

//读取烂牙
-(BOOL) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID;
-(BOOL) readValue2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p;

//注册通知消息
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on;
-(void) notification2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on;


//辅助函数

-(void) printPeripheralInfo:(CBPeripheral*)peripheral;//打印信息
-(UInt16) swap:(UInt16) s;
-(void) getAllServices:(CBPeripheral *)p;
-(void) getAllCharacteristics:(CBPeripheral *)p;
-(const char *) centralManagerStateToString:(int)state;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(const char *) UUIDToString:(CFUUIDRef) UUID;
-(const char *) CBUUIDToString:(CBUUID *) UUID;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(int) compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;//UUID类转数值
-(CBUUID *) IntToCBUUID:(UInt16)UUID;//数值转UUID类
-(int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2;

@end

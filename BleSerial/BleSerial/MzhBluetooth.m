//
//  TIBLECBKeyfob.m
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/31/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#import "MzhBluetooth.h"

@implementation MzhBluetooth

@synthesize delegate;
@synthesize CM;
@synthesize peripheral;

-(id)init
{
    if ((self=[super init])) {
        self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        peripheral=NULL;
    }
    return self;
}

-(BOOL)connect:(CBPeripheral *)p
{
    //连接到这个搜索到的对象上面
    NSLog(@"Connecting to peripheral with UUID : %s",peripheral.identifier.UUIDString);
    peripheral = p;
    peripheral.delegate = self;
    [CM connectPeripheral:peripheral options:nil];
    return TRUE;
}

-(void)disconnect
{
    //断开连接
    if (peripheral) {
        [CM cancelPeripheralConnection:peripheral];
        peripheral = nil;
    }
}

/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(BOOL) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    return [self writeValue2:su characteristicUUID:cu p:peripheral data:data];
}
-(BOOL) writeValue2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    CBUUID *su = serviceUUID;
    CBUUID *cu = characteristicUUID;
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return FALSE;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return FALSE;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    return TRUE;
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic 
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(BOOL) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    return [self readValue2:su characteristicUUID:cu p:peripheral];
}
-(BOOL) readValue2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p
{
    CBUUID *su = serviceUUID;
    CBUUID *cu = characteristicUUID;
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return FALSE;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return FALSE;
    }
    [p readValueForCharacteristic:characteristic];
    return TRUE;
}


/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers 
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the notfication is set. 
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    
    [self notification2:su characteristicUUID:cu p:peripheral on:on];
}

-(void) notification2:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:serviceUUID],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16 
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}


/*!
 *  @method findBLEPeripherals:
 *
 *  @param timeout timeout in seconds to search for BLE peripherals
 *
 *  @return 0 (Success), -1 (Fault)
 *  
 *  @discussion findBLEPeripherals searches for BLE peripherals and sets a timeout when scanning is stopped
 **  搜索设备
 */
- (int) scanBluetoothDevice {
    
    if (self->CM.state  != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth not correctly initialized !\r\n");
        printf("State = %ld (%s)\r\n",self->CM.state,[self centralManagerStateToString:self.CM.state]);
        return -1;
    }
    
    [CM scanForPeripheralsWithServices:nil options:0]; // Start scanning
    return 0; // Started scanning OK !
}

-(void)stopScanBluetooth
{
    //停止搜索
    [CM stopScan];//服务搜索之后停止
}

/*!
 *  @method centralManagerStateToString:
 *
 *  @param state State to print info of
 *
 *  @discussion centralManagerStateToString prints information text about a given CBCentralManager state
 *
 */
- (const char *) centralManagerStateToString: (int)state{
    switch(state) {
        case CBCentralManagerStateUnknown: 
            return "CBCentralManagerStateUnknown";
        case CBCentralManagerStateResetting:
            return "CBCentralManagerStateUnknown";
        case CBCentralManagerStateUnsupported:
            return "CBCentralManagerStateResetting";
        case CBCentralManagerStateUnauthorized:
            return "CBCentralManagerStateUnauthorized";
        case CBCentralManagerStatePoweredOff:
            return "CBCentralManagerStatePoweredOff";
        case CBCentralManagerStatePoweredOn:
            return "CBCentralManagerStatePoweredOn";
        default:
            return "State unknown";
    }
    return "Unknown state";
}



/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of 
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral 
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {

}

/*
 *  @method UUIDSAreEqual:
 *
 *  @param u1 CFUUIDRef 1 to compare
 *  @param u2 CFUUIDRef 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compares two CFUUIDRef's
 *
 */

- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}



/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);		
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1 
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
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
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a 
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service 
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


/*
 *  @method getAllServices
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllServices starts a service discovery on a peripheral pointed to by p.
 *  When services are found the didDiscoverServices method is called
 *
 */
-(void) getAllServices:(CBPeripheral *)p{
   // NSLog(@"Discovering services..");
    [p discoverServices:nil]; // Discover all services without filter
}

/*
 *  @method getAllCharacteristics
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristics starts a characteristics discovery on a peripheral
 *  pointed to by p
 *  获取所有支持的功能
 */
-(void) getAllCharacteristics:(CBPeripheral *)p{
    //NSLog(@"Discovering characteristics..");
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        //NSLog(@"Fetching characteristics for service with UUID : %s",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}


//-------------------------------------------------------------
//当前IOS设备的蓝牙硬件状态
//--------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //NSLog(@"本机蓝牙设备状态:%s",[self centralManagerStateToString:central.state]);
    [delegate mzhBluetoothDevState_cb:central.state];
}

//搜索到一个服务完成后的回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"搜索到peripheral with UUID : %s",[self UUIDToString:peripheral.UUID]);
    [delegate mzhBluetoothScan_cb:peripheral];
}

//连接到设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    [delegate mzhBluetoothConnect_cb:TRUE :(CBPeripheral *)peripheral];
}
//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [delegate mzhBluetoothConnect_cb:FALSE :(CBPeripheral *)peripheral];
}

//------------------------------------------------------
//
//
//
//
//
//CBPeripheralDelegate protocol methods beneeth here
//
//
//
//
//
//-------------------------------------------------------

/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered 
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *  获取特定支持功能完成后
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        [delegate mzhBluetoothService_cb:peripheral
                                         :[self CBUUIDToInt:service.UUID]];
        //NSLog(@"发现服务名称 UUID:%s",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID]) {
               //NSLog(@"找到支持的功能  %s",[ self CBUUIDToString:c.UUID]);
                [delegate mzhBluetoothCharacteristic_cb:peripheral
                                                        :[self CBUUIDToInt:service.UUID]
                                                        :[self CBUUIDToInt:c.UUID]];
            }
        }
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didDiscoverDescriptorsForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    NSLog(@"didDiscoverIncludedServicesForService");
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a 
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        [self getAllCharacteristics:peripheral];
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !");
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a 
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        [delegate mzhBluetoothNotification_cb:YES :peripheral :[self CBUUIDToInt:characteristic.service.UUID] :[self CBUUIDToInt:characteristic.UUID]];
    }
    else {
       [delegate mzhBluetoothNotification_cb:FALSE :peripheral :[self CBUUIDToInt:characteristic.service.UUID] :[self CBUUIDToInt:characteristic.UUID]];
    }
    
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a 
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 *   收到设备给过来的UUID协议,数据的回调更新
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        //NSLog(@"接收到UUID=0x%x 长度=%d",characteristicUUID,[characteristic.value length]);
        [delegate mzhBluetoothRecv_cb:[self CBUUIDToInt:characteristic.UUID]
                                   :characteristic.value];
    }
    else {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"didUpdateValueForDescriptor");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"didWriteValueForDescriptor");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"peripheralDidUpdateRSSI = %d",[peripheral.RSSI intValue]);
    [delegate mzhBluetoothRSSI_cb:peripheral :[peripheral.RSSI intValue]];
}


@end

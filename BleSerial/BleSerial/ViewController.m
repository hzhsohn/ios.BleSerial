//
//  TIBLEViewController.m
//  TI-BLE-Demo
//
//  Created by Ole Andreas Torvmark on 10/29/11.
//  Copyright (c) 2011 ST alliance AS. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    __weak IBOutlet UITextView *txtMsg;
    __weak IBOutlet UITextView *_txtSend;
    
    __weak IBOutlet UIButton *_lbCharaccterRead;
    __weak IBOutlet UILabel *_lbServiceWrite;
    __weak IBOutlet UIButton *_lbCharcaterWrite;
    
    MzhBluetooth *t; //ble蓝牙
    NSUUID *_uuid;
    
    //ID标识
    UInt16 Service_Write;
    UInt16 Characteristic_Write;
    UInt16 Characteristic_Read;
}

-(IBAction)btnN:(id)sender;
-(IBAction)btnW:(id)sender;

@end


@implementation ViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    t = [[MzhBluetooth alloc] init];
    t.delegate = self;
}

-(void)dealloc
{
    t.delegate=nil;
    t=nil;
    
    _uuid=nil;
    
    txtMsg=nil;
    _txtSend=nil;
    
    _lbCharaccterRead=nil;
    _lbServiceWrite=nil;
    _lbCharcaterWrite=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

////////////////////////////////////////////////////
//辅助函数
- (NSString*) documentPath:(NSString*)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (nil!=str) {
        return [NSString stringWithFormat:@"%@/%@",documentsDirectory,str];
    }
    return [NSString stringWithFormat:@"%@",documentsDirectory];
}


//---------------------------------------------
-(BOOL) trStrToCmd:(const char*)szTmp :(TagCmd*)pcmd
{
    char *split;
    char *szbuf;
    int nbufLen;
    char *psz;
    int nHex;
    
    nbufLen=(int)strlen(szTmp)+1;
    szbuf=(char *)malloc(nbufLen);
    memset(szbuf,0,nbufLen);
    
    memset(pcmd,0,sizeof(TagCmd));
    
    strcpy(szbuf,szTmp);
    psz=strtok_r(szbuf," ",&split);
    pcmd->len=0;
    do
    {
        nHex=0;
        sscanf(psz,"%x",&nHex);
        
        if(nHex>255)
        {
            memset(pcmd,0,sizeof(TagCmd));
            free(szbuf);
            szbuf=NULL;
            return false;
        }
        pcmd->cmd[pcmd->len++]=(unsigned char)nHex;
    }while((psz=strtok_r(NULL," ",&split)));
    
    free(szbuf);
    szbuf=NULL;
    return true;
}


/////////////////////////////////////////////////////
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    /////
    //配置文件
    NSString *configFile = [self documentPath:@"cfg.plist"];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    
    if (!configList) {
        //第一次，文件没有创建，因此要创建文件，并写入相应的初始值。
        configList = [[NSMutableDictionary alloc] init];
        
        Characteristic_Read=0xfff4;
        Service_Write=0x1910;
        Characteristic_Write=0xfff2;
        
        [_lbCharaccterRead setTitle:[NSString stringWithFormat:@"0x%X",Characteristic_Read] forState:UIControlStateNormal];
        [_lbServiceWrite setText:[NSString stringWithFormat:@"0x%X",Service_Write]];
        [_lbCharcaterWrite setTitle:[NSString stringWithFormat:@"0x%X",Characteristic_Write] forState:UIControlStateNormal];
        [_txtSend setText:@"AA BB CC DD"];

        [configList writeToFile:configFile atomically:YES];
    }
    else{
        //第三:读取键值
        NSString *cR  = [configList objectForKey:@"Characteristic_Read"];
        NSString *sW = [configList objectForKey:@"Service_Write"];
        NSString *cW = [configList objectForKey:@"Characteristic_Write"];
        NSString *tS = [configList objectForKey:@"SendContent"];
        ///////////////////////
        if (nil==cR) {
            Characteristic_Read=0xfff4;
            NSString*str=[NSString stringWithFormat:@"0x%X",Characteristic_Read];
            [_lbCharaccterRead setTitle:str forState:UIControlStateNormal];
            [configList setValue:str forKey:@"Characteristic_Read"];
        }
        else {
            int tt;
            sscanf([cR UTF8String],"0x%x",&tt);
            Characteristic_Read=tt;
            [_lbCharaccterRead setTitle:[NSString stringWithFormat:@"0x%X",Characteristic_Read] forState:UIControlStateNormal];
        }
        ///////////////////////
        if (nil==sW) {
            Service_Write=0x1910;
            NSString*str=[NSString stringWithFormat:@"0x%X",Service_Write];
            [_lbServiceWrite setText:str];
            [configList setValue:str forKey:@"Service_Write"];
        }
        else {
            int tt;
            sscanf([sW UTF8String],"0x%x",&tt);
            Service_Write=tt;
            [_lbServiceWrite setText:[NSString stringWithFormat:@"0x%X",Service_Write]];
        }
        ///////////////////////
        if (nil==cW) {
            Characteristic_Write=0xfff2;
            NSString*str=[NSString stringWithFormat:@"0x%X",Characteristic_Write];
            [_lbCharcaterWrite setTitle:str forState:UIControlStateNormal];
            [configList setValue:str forKey:@"Characteristic_Write"];
        }
        else {
            int tt;
            sscanf([cW UTF8String],"0x%x",&tt);
            Characteristic_Write=tt;
            [_lbCharcaterWrite setTitle:[NSString stringWithFormat:@"0x%X",Characteristic_Write] forState:UIControlStateNormal];
        }
        ////////////////////////
        if (nil==tS) {
            [_txtSend setText:@"AA BB CC DD"];
            [configList setValue:_txtSend.text forKey:@"SendContent"];
        }
        else {
            [_txtSend setText:tS];
        }
        
        if (nil==cR || nil==sW || nil==cW || nil==tS) {
            [configList writeToFile:configFile atomically:YES];
        }
    }
    
    configList=nil;
    configFile=nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) log:(NSString *)text
{
    NSLog(@"%@", text);
    txtMsg.text= [txtMsg.text stringByAppendingString:text];
    txtMsg.text= [txtMsg.text stringByAppendingString:@"\n"];
    NSRange range;
    range.location= [txtMsg.text length];
    range.length= 10;
    
    [UIView setAnimationsEnabled:NO];
    [txtMsg scrollRangeToVisible:range];
    [UIView setAnimationsEnabled:YES];
}


- (void) showPeripheralInfo:(CBPeripheral*)peripheral
{
    NSMutableString * str=[[NSMutableString alloc] init];
    [str appendFormat:@"---------------------------\r\n"];
    [str appendFormat:@"连接到Peripheral Info :\r\n"];
    [str appendFormat:@"UUID : %@\r\n",peripheral.identifier.UUIDString];
    [str appendFormat:@"RSSI : %d\r\n",[peripheral.RSSI intValue]];
    [str appendFormat:@"Name : %@\r\n",peripheral.name];
   // [str appendFormat:@"isConnected : %d\r\n",peripheral.isConnected];
    [str appendFormat:@"---------------------------" ];
    
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    
    str=nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"segue.identifier=%@",segue.identifier);
    
    if ([segue.identifier isEqualToString:@"segSendID"]) {
        SelectWriteUIDController* frm=(SelectWriteUIDController*)segue.destinationViewController;
        frm.delegate=self;
        [frm setService: t.peripheral.services];
        
    }
    else if ([segue.identifier isEqualToString:@"segRecvID"]) {
        SelectRecvUIDController* frm =(SelectRecvUIDController*)segue.destinationViewController;
        [frm setService: t.peripheral.services];
        frm.delegate=self;
    }
    else if ([segue.identifier isEqualToString:@"segModifyContent"]) {
        ModifySendController* frm =(ModifySendController*)segue.destinationViewController;
        [frm setContent:_txtSend.text];
        frm.delegate=self;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation==UIInterfaceOrientationLandscapeRight);
}

- (void)setPeripherals:(CBPeripheral*)peripheral;
{
    _uuid=peripheral.identifier;
}

-(IBAction)btnN:(id)sender
{
    [t.peripheral readRSSI];
}
-(IBAction)btnW:(id)sender
{
    //发送
    TagCmd tcmd;
    
    if([self trStrToCmd:[_txtSend.text UTF8String] :&tcmd])
    {
        NSData *da=[NSData dataWithBytes:tcmd.cmd length:tcmd.len];
        if([t writeValue:Service_Write characteristicUUID:Characteristic_Write data:da])
        {
            NSMutableString * str=[[NSMutableString alloc] init];
            [str appendFormat:@"UUID=0x%x & 0x%x ,发送%d字节:hex[",Service_Write,Characteristic_Write,tcmd.len];
            for (int i=0; i<tcmd.len; i++) {
                [str appendFormat:@"%02X ",tcmd.cmd[i]];
            }
            [str appendFormat:@"]"];
            [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
            str=nil;
        }
        else
        {
            [self performSelectorOnMainThread:@selector(log:) withObject:@"发送失败" waitUntilDone:YES];
        }
    }
    else
    {
        [self performSelectorOnMainThread:@selector(log:) withObject:@"发送内容转换失败" waitUntilDone:YES];
    }
}




//----------------------- 回调 ----------------------------------
-(void)mzhBluetoothDevState_cb:(CBCentralManagerState)state
{
    NSString * str=[NSString stringWithFormat:@"蓝牙状态:%s\r\n正在等待设备响应...\r\n",[t centralManagerStateToString:state]];
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    
    //先搜索设备,才能获取相关参数
    [t scanBluetoothDevice];
}
-(void)mzhBluetoothScan_cb:(CBPeripheral *)peripheral
{
    NSLog(@"peripheral.identifier=%@",peripheral.identifier);
    if ([peripheral.identifier isEqual:_uuid]) {
        //延时
        [NSThread sleepForTimeInterval:0.3f];
        [t connect:peripheral];
        [self performSelectorOnMainThread:@selector(log:) withObject:@"正在连接设备..." waitUntilDone:YES];
    }
    NSLog(@"peripheral.state=%ld",peripheral.state);
}
-(void)mzhBluetoothRSSI_cb:(CBPeripheral *)peripheral :(int)value
{
    NSString * str=[NSString stringWithFormat:@"信号rssi = %d",value];
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    
}
-(void)mzhBluetoothConnect_cb:(BOOL)result :(CBPeripheral *)peripheral
{
    if (result) {
        NSString * str=[NSString stringWithFormat:@"mzhBluetoothConnect = %d\r\n",result];
        [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
        //延时
        [NSThread sleepForTimeInterval:0.3f];
        //获取服务
        [t getAllServices:peripheral];
        [self performSelectorOnMainThread:@selector(log:) withObject:@"正在获取服务..." waitUntilDone:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
-(void)mzhBluetoothService_cb:(CBPeripheral *)peripheral
                              :(UInt16)serv_uuid
{
    NSString * str=[NSString stringWithFormat:@"获取服务=0x%02x",serv_uuid];
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
}
-(void)mzhBluetoothCharacteristic_cb:(CBPeripheral *)peripheral
                                     :(UInt16)serv_uuid
                                     :(UInt16)characteristic_uuid
{
    NSString * str=[NSString stringWithFormat:@"服务=0x%02x ,拥有特征值=0x%02x",serv_uuid,characteristic_uuid];
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    
    //注册通知服务
    [t notification:serv_uuid characteristicUUID:characteristic_uuid on:YES];
}

-(void)mzhBluetoothNotification_cb:(BOOL)b :(CBPeripheral *)peripheral
                                  :(UInt16)serv_uuid
                                  :(UInt16)characteristic_uuid
{
    
    NSString * str=[NSString stringWithFormat:@"注册特征 服务=0x%02x ,拥有特征值=0x%02x ,注册结果=%d",serv_uuid,characteristic_uuid,b];
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    
    if(b)
    {
        //注册成功
    }
    else
    {
        //注册失败
    }
}

-(void)mzhBluetoothRecv_cb:(UInt16)characteristic_uuid :(NSData*)data
{
    if (Characteristic_Read==characteristic_uuid)
    {
     
        NSMutableString * str=[[NSMutableString alloc] init];
        unsigned char buf[128];
        int len=(int)[data length];
        [str appendFormat:@"UUID=%x ,收到%d字节:hex[",Characteristic_Read,len];
        [data getBytes:buf length:len];
        for (int i=0; i<len; i++) {
            [str appendFormat:@"%02X ",buf[i]];
        }
        [str appendFormat:@"]"];
        [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
        str=nil;
    }
}


//-----------------------------------------------
//选择窗体回调
-(void) SelectRecvUIDController_cb:(UInt16)rServid :(UInt16)rCharid
{
    Characteristic_Read=rCharid;
    
    //设置值
    NSString*str=[NSString stringWithFormat:@"0x%X",Characteristic_Read];
    [_lbCharaccterRead setTitle:str forState:UIControlStateNormal];
    
    //配置文件
    NSString *configFile = [self documentPath:@"cfg.plist"];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    if (configList) {
            [configList setValue:str forKey:@"Characteristic_Read"];
            [configList writeToFile:configFile atomically:YES];
    }
    configList=nil;
    configFile=nil;
}

-(void) SelectWriteUIDController_cb:(UInt16)rServid :(UInt16)rCharid
{
    Service_Write=rServid;
    Characteristic_Write=rCharid;
    
    NSString*str1=[NSString stringWithFormat:@"0x%X",Service_Write];
    NSString*str2=[NSString stringWithFormat:@"0x%X",Characteristic_Write];
    
    //设置值
    [_lbServiceWrite setText:str1];
    [_lbCharcaterWrite setTitle:str2 forState:UIControlStateNormal];
    
    //配置文件
    NSString *configFile = [self documentPath:@"cfg.plist"];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    if (configList) {
        [configList setValue:str1 forKey:@"Service_Write"];
        [configList setValue:str2 forKey:@"Characteristic_Write"];
        [configList writeToFile:configFile atomically:YES];
    }
    configList=nil;
    configFile=nil;
}

//--------------------------------------------------
-(void) ModifySendControllerOK_cb:(NSString*)val
{
    [_txtSend setText:val];
    
    //配置文件
    NSString *configFile = [self documentPath:@"cfg.plist"];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    if (configList) {
        [configList setValue:_txtSend.text forKey:@"SendContent"];
        [configList writeToFile:configFile atomically:YES];
    }
    configList=nil;
    configFile=nil;
}



@end

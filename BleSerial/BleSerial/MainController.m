//
//  MainController.m
//  BleSerial
//
//  Created by Han.zh on 14-9-30.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "MainController.h"
#import "MainCell.h"
#import "ViewController.h"

@interface MainController ()
{
    MzhBluetooth *_t; //ble蓝牙
    NSMutableArray *_aryPeripheral;
    
    BOOL isBleOK;//蓝牙是否成功启动
}

@property (weak, nonatomic) IBOutlet UIView *viwAD;

- (IBAction)itemClick:(id)sender;


-(UIImage*)setRSSIIcon:(NSInteger)val;


@end

@implementation MainController

-(void)awakeFromNib
{
    _t = [[MzhBluetooth alloc] init];
    _t.delegate = self;
    
    _aryPeripheral =[[NSMutableArray alloc] initWithObjects: nil];
    isBleOK=FALSE;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //获取设备
    [self performSelector:@selector(itemClick:) withObject:self afterDelay:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_aryPeripheral count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"MainCell_id";
    
    MainCell *cell = (MainCell *)[tableView
                                      dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainCell"
                                                     owner:self options:nil];
       // NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[MainCell class]])
                cell = (MainCell *)oneObject;
    }

    CBPeripheral* peripheral=[_aryPeripheral objectAtIndex:indexPath.row];
    [cell.lbDevID setText:[NSString stringWithFormat:@"%@",peripheral.identifier.UUIDString]];
    [cell.lbTitle setText:peripheral.name];
    
    NSInteger tmpRSSI=[peripheral.RSSI integerValue];
    
    [cell.imgRSSI setImage:[self setRSSIIcon:tmpRSSI]];
    if (tmpRSSI==0) {
        [cell.lbRSSI setText:[NSString stringWithFormat:@""]];
    }
    else{
        [cell.lbRSSI setText:[NSString stringWithFormat:@"%ld",tmpRSSI]];
    }
    //[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"UsedFrm_ID"];
    
    [detail setPeripherals:[_aryPeripheral objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:detail animated:YES];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//----------------------------------------------------
//蓝牙回调
-(void)mzhBluetoothDevState_cb:(CBCentralManagerState)state
{
    isBleOK=FALSE;
    NSString * str=[NSString stringWithFormat:@"本机蓝牙状态:%s\r\n",[_t centralManagerStateToString:state]];
    NSLog(@"%@",str);
    
    switch (state) {
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateResetting:
            break;
        case CBCentralManagerStateUnsupported:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStatePoweredOff:
      
            break;
        case CBCentralManagerStatePoweredOn:
            isBleOK=TRUE;
            //搜索信号
           // [_t scanBluetoothDevice];
            break;
    }
    
}
-(void)mzhBluetoothScan_cb:(CBPeripheral *)peripheral
{
    BOOL isAdd=FALSE;
    
    //打印搜索信息
    [_t printPeripheralInfo:peripheral];
    
    //查找是否有相同项
    for (CBPeripheral*p in _aryPeripheral) {
        NSString*s1 =p.identifier.UUIDString;
        NSString*s2 =peripheral.identifier.UUIDString;
        
        if ([s1 isEqualToString:s2]) {
            isAdd=TRUE;
        }
    }
    
    //不是重复peripheral即添加
    if (FALSE==isAdd) {
        [_t connect:peripheral];
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [indexPaths addObject: indexPath];
        [_aryPeripheral addObject:peripheral];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}
-(void)mzhBluetoothConnect_cb:(BOOL)result :(CBPeripheral *)peripheral
{
    [_t.peripheral readRSSI];
}
-(void)mzhBluetoothRSSI_cb:(CBPeripheral *)peripheral :(int)value
{
    NSString * str=[NSString stringWithFormat:@"信号rssi = %d",value];
    NSLog(@"%@",str);

    [self.tableView reloadData];
    [_t disconnect];
}

-(void)mzhBluetoothService_cb:(CBPeripheral *)peripheral
                             :(UInt16)serv_uuid
{
    NSString * str=[NSString stringWithFormat:@"拥有服务=0x%02x",serv_uuid];
    NSLog(@"%@",str);
}
-(void)mzhBluetoothCharacteristic_cb:(CBPeripheral *)peripheral
                                    :(UInt16)serv_uuid
                                    :(UInt16)characteristic_uuid
{
    NSString * str=[NSString stringWithFormat:@"服务=0x%02x ,拥有特征值=0x%02x",serv_uuid,characteristic_uuid];
    NSLog(@"%@",str);
}

-(void)mzhBluetoothRecv_cb:(UInt16)characteristic_uuid :(NSData*)data
{

}
-(void)mzhBluetoothNotification_cb:(BOOL)b :(CBPeripheral *)peripheral
                                   :(UInt16)serv_uuid
                                   :(UInt16)characteristic_uuid
{
    
}

- (IBAction)itemClick:(id)sender
{
    
    if (isBleOK) {
        [_aryPeripheral removeAllObjects];
        [self.tableView reloadData];
        [_t scanBluetoothDevice];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                        message:NSLocalizedString(@"你的手机上的蓝牙还没开启", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"确实", nil)
                                              otherButtonTitles: nil];
        [alert show];
        alert=nil;
    }
}


-(UIImage*)setRSSIIcon:(NSInteger)val
{
    if(val<=-90)
    {
        return [UIImage imageNamed:@"rssi_0.png"];
    }
    else if(val<=-80)
    {
        return [UIImage imageNamed:@"rssi_1.png"];
    }
    else if(val<=-70)
    {
        return [UIImage imageNamed:@"rssi_2.png"];
    }
    else if(val<=-60)
    {
        return [UIImage imageNamed:@"rssi_3.png"];
    }
    else if(val<=-50)
    {
        return [UIImage imageNamed:@"rssi_4.png"];
    }
    else if (val<=-1 || val>0) {
        return [UIImage imageNamed:@"rssi_5.png"];
    }
    return [UIImage imageNamed:@"rssi_none.png"];
}

@end

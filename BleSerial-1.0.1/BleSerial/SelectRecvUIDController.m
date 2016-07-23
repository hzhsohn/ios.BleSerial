//
//  SelectRecvUIDController.m
//  BleSerial
//
//  Created by Han.zh on 14-10-2.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "SelectRecvUIDController.h"


@interface SelectRecvUIDController ()
{
    NSMutableArray* _aryService;
}

@end

@implementation SelectRecvUIDController

-(void)awakeFromNib
{
    _aryService=[[NSMutableArray alloc] initWithObjects: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)setService:(NSArray*)ary
{
    [_aryService setArray:ary];
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
-(const char *) CBUUIDToString:(CBUUID *) UUID :(char*)dstString
{
    char buf[26];
    short i;
    char*p=(char*)[UUID.data bytes];
    
    strcpy(dstString, "0x");
    for(i=0;i<[UUID.data length];i++)
    {
        sprintf(buf,"%02X",(unsigned char)p[i]);
        strcat(dstString, buf);
    }
    return dstString;
}

/////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _aryService.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBService*s=(CBService*)[_aryService objectAtIndex:section];
    return s.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    char buf[256];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    CBService*s=(CBService*)[_aryService objectAtIndex:indexPath.section];
    CBCharacteristic *c = [s.characteristics objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%s",[self CBUUIDToString:c.UUID :buf]];
    
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击行,这里是storyboard的应用,注:要在storyboard的BleDetial_iPhone里面的identifier设置一个名字例如SegueName
    UInt16 rServ,rbuf;
    CBService*s=(CBService*)[_aryService objectAtIndex:indexPath.section];
    CBCharacteristic *c = [s.characteristics objectAtIndex:indexPath.row];
    rServ=[self CBUUIDToInt:s.UUID];
    rbuf=[self CBUUIDToInt:c.UUID];
    [self.delegate SelectRecvUIDController_cb:rServ :rbuf];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectio
{
    char buf[256];
    CBService *s = [_aryService objectAtIndex:sectio];
    return [NSString stringWithFormat:@"service--%s",[self CBUUIDToString:s.UUID :buf]];
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
@end

//
//  ModifySendController.m
//  BleSerial
//
//  Created by Han.zh on 14-10-11.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "ModifySendController.h"


@interface ModifySendController ()
{
    __weak IBOutlet UITextView *_txtContent;
    
    NSString* _tmpContent;
}

- (IBAction)btnConfirm:(id)sender;

@end


@implementation ModifySendController

-(void)dealloc
{
    _txtContent=nil;
    _tmpContent=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_txtContent setText:_tmpContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_txtContent becomeFirstResponder];
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

-(void) setContent:(NSString*)str
{
    _tmpContent =str;
}

- (IBAction)btnConfirm:(id)sender
{
    [self.delegate ModifySendControllerOK_cb:_txtContent.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

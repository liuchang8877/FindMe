//
//  UserRegisterViewController.m
//  LBSFind
//
//  Created by liu on 4/15/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "UserRegisterViewController.h"
#import "allConfig.h"
#import "ASIHTTPRequest.h"
#import "DataModel.h"
#import "tool.h"

@interface UserRegisterViewController ()

@end

@implementation UserRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark http for setTheLocation
- (void)setTheRegister:(userInfo *)myUser
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=register&tel=%@&user=%@&pwd=%@",URL_IP,URL_PORT,myUser.tel,myUser.name,myUser.pwd];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheRegister---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheRegister---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheRegister---net is NOT ok");
        [tool checkNetAlter];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    NSLog(@"setTheRegister---responseString:%@",responseString);
    
    //    SBJsonParser * parser = [[SBJsonParser alloc] init];
    //    NSError * error = nil;
    //    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    //
    //    NSMutableDictionary * dicRetInfo = [jsonDic objectForKey:@"ret"];
    NSLog(@"%d",[request responseStatusCode]);
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"setTheRegister---error:%@",error);
    [tool checkNetAlter];
}

- (IBAction)onClickRegister:(id)sender {
    
    NSString *name =  self.nameTextField.text;
    NSString *tel  =  self.telTextField.text;
    NSString *pwd  =  self.pwdTextField.text;
    NSString *anPwd=  self.anPwdTextField.text;
    
    if ([name length] != 0 && [tel length] != 0 && [pwd length] != 0 && [anPwd length] != 0) {
        
        if ([pwd isEqualToString:anPwd]) {
            
            // register the info
            userInfo *myUserInfo = [[userInfo alloc] init];
            myUserInfo.tel  = tel;
            myUserInfo.name = name;
            myUserInfo.pwd  = pwd;
            [self setTheRegister:myUserInfo];
        } else  {

            //the register pwd is not the same
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                          message:@"两次密码不匹配"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"确定",nil];
            [alert show];
        }
    
    } else {
        // there are some one is null
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"注册信息不能为空"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"确定",nil];
		[alert show];
    
    }
}

#pragma mark  hide keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.nameTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    [self.telTextField resignFirstResponder];
    [self.anPwdTextField resignFirstResponder];
    
}
@end

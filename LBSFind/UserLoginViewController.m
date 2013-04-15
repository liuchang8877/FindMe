//
//  UserLoginViewController.m
//  LBSFind
//
//  Created by liu on 4/15/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserRegisterViewController.h"
#import "DataModel.h"
#import "allConfig.h"
#import "tool.h"
#import "ASIHTTPRequest.h"

@interface UserLoginViewController ()

@end

@implementation UserLoginViewController

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
- (void)setTheLogin:(userInfo *)myUser
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=login&user=%@&pwd=%@",URL_IP,URL_PORT,myUser.name,myUser.pwd];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLogin---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLogin---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLogin---net is NOT ok");
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
    
    NSLog(@"setTheLogin---responseString:%@",responseString);
    
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
    NSLog(@"setTheLogin---error:%@",error);
    [tool checkNetAlter];
}

- (IBAction)onClickLogin:(id)sender {
    
    if ([self.nameTextField.text length] != 0 && [self.pwdTextField.text length] != 0) {
        // send login info to the server
        userInfo *myUser = [[userInfo alloc] init];
        myUser.name = self.nameTextField.text;
        myUser.pwd  = self.pwdTextField.text;
        [self setTheLogin:myUser];
    
    } else {
    
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"用户名密码不能为空"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"确定",nil];
		[alert show];
    
    }
}

- (IBAction)onClickRegister:(id)sender {
    
    UserRegisterViewController *userRegister = [[UserRegisterViewController alloc]init];
    userRegister.title = @"用户注册";
    
    [self.navigationController pushViewController:userRegister animated:YES];
}


#pragma mark  hide keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.nameTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    
}

@end

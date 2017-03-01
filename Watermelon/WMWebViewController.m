//
//  WMWebViewController.m
//  Watermelon
//
//  Created by zhujinhui on 17/3/1.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMWebViewController.h"
#import <WebKit/WebKit.h>
@interface WMWebViewController ()<WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate>

@end

@implementation WMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        [self.view addSubview:webView];
    }else
    {
        UIWebView * webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        webView.delegate=self;
        [self.view addSubview:webView];
    }
    
    
    
    
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

@end

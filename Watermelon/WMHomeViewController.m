//
//  WMHomeViewController.m
//  Watermelon
//
//  Created by zhujinhui on 17/2/28.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMHomeViewController.h"

#import "MDSRouter.h"

@interface WMHomeViewController ()

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation WMHomeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSURL *url = [NSURL URLWithString:@"hybrid://kyson?param={\"a\":\"b\"}"];
    
    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
 //   [self.webView loadRequest:request];
    
 //   [self.view addSubview:self.webView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonClicked1:(id)sender {
//    [MDSRouter openingPath:@"hybrid://forward?param=\{\"topage\":\"http:\/\/yexiaochai.github.io\/Hybrid\/webapp\/demo\/ajax.html\",\"animate\":\"push\"\}"];
    [MDSRouter openingPath:@"hybrid://forward?param=\{\"topage\":\"kyson\",\"animate\":\"push\"\}"];

}

- (IBAction)buttonClicked2:(id)sender {
    
//    [MDSRouter openingPath:@"hybrid://forward?param=\{\"topage\":\"kyson?url=https:\/\/www.baidu.com\",\"animate\":\"push\"\}"];
    [MDSRouter openingPath:@"hybrid://webview?url=https://www.baidu.com"];

}

- (IBAction)buttonClicked3:(id)sender {
//    NSURL *baseURL = [NSURL URLWithString:@""];

    [MDSRouter openingPath:@"hybrid://webview?url=file:///index1.html"];
}

- (IBAction)buttonClicked4:(id)sender {
    
    [MDSRouter openingPath:@"hybrid://webview?url=file:///index2.html"];

}


- (IBAction)buttonClicked5:(id)sender {
    [MDSRouter openingPath:@"hybrid://webview?url=file:///index3.html"];
}







-(UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    }
    return _webView;
}

@end

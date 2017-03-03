//
//  WMViewController.m
//  Watermelon
//
//  Created by zhujinhui on 17/3/1.
//  Copyright © 2017年 kyson. All rights reserved.
//

#import "WMViewController.h"

#import "MDSUIHeader.h"

@interface WMViewController ()

@end

@implementation WMViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initWithNotificationCenter:) name:@"1" object:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)initWithNotificationCenter:(NSNotification *) notification {
    NSString *obj = [notification object];
    //设置标题
    if([obj hasPrefix:@"hybrid://updateNavigationBar?param="]) {
        
        obj = [obj stringByReplacingOccurrencesOfString:@"hybrid://updateNavigationBar?param=" withString:@""];
        
        NSDictionary *dict = [self.class __jsonObjectWithString:obj];
        
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = dict[@"data"];
            
            if ([dataDict isKindOfClass:[NSDictionary class]]) {
                MDSUIHeader *header = [[MDSUIHeader alloc] init];
                [header loadPropertiesWithData:dataDict];
                self.title = header.title.title;
                
                SEL callBack = NSSelectorFromString(header.left.firstObject.callBack);
                
                UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"d" style:UIBarButtonItemStylePlain target:self action:callBack];
                [leftBarBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
                self.navigationItem.leftBarButtonItem = leftBarBtn;
                
                
            }
            
        }
    }else if ([obj hasPrefix:@"hybrid://back?param="]){
        obj = [obj stringByReplacingOccurrencesOfString:@"hybrid://back?param=" withString:@""];
        NSDictionary *dict = [self.class __jsonObjectWithString:obj];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            
                
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }

    }
    
    
    
}


-(void)head_back{
    [self.navigationController popViewControllerAnimated:YES];
}



+ (instancetype)__jsonObjectWithString:(NSString *)jsonStr {
    if (jsonStr == nil || (![jsonStr isKindOfClass:[NSString class]])) {
        return nil;
    }
    NSError *error = nil;
    id v = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers
                                             error:&error];
    if (error) {
        NSLog(@"你妹，什么破 json: %@", jsonStr);
        return nil;
    }
    
    return v;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

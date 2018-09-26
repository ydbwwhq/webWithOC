//
//  ViewController.m
//  Test
//
//  Created by wanghaoqiang on 2018/9/20.
//  Copyright © 2018年 wanghaoqiang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewVC.h"
@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property(strong,nonatomic) WKWebView *web;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    WKWebView *web = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0,400, 250) configuration:config];
    [self.view addSubview:web];
    web.backgroundColor = [UIColor lightGrayColor];
    NSString*path =  [[NSBundle mainBundle] pathForResource:@"a" ofType:@"html"];
    NSString *htmlStr = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [web loadHTMLString:htmlStr baseURL:nil];
    web.navigationDelegate = self;
    web.UIDelegate = self;
    _web = web;
    
    UIButton *btn = [UIButton new];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(50, 300, 100, 50);
    [btn setTitle:@"调用JS方法" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *jumpWebBtn = [UIButton new];
    [self.view addSubview:jumpWebBtn];
    jumpWebBtn.frame = CGRectMake(200, 300, 150,50);
    [jumpWebBtn setTitle:@"WebView交互页" forState:UIControlStateNormal];
    [jumpWebBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [jumpWebBtn addTarget:self action:@selector(touchJumpBtn) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)touchBtn
{
    [_web evaluateJavaScript:@"callJS('ok')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
}
- (void)touchJumpBtn
{
    WebViewVC *vc = [WebViewVC new];
    [self presentViewController:vc animated:true completion:^{
        
    }];
}
#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}

// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
}

// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *name = message.name;
    if([name isEqualToString:@"AppModel"])
    {
        NSString *bodyStr = message.body;
        NSLog(@"JS调用OC成功 参数为= %@",bodyStr);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

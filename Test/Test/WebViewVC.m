//
//  WebViewVC.m
//  Test
//
//  Created by wanghaoqiang on 2018/9/26.
//  Copyright © 2018年 wanghaoqiang. All rights reserved.
//

#import "WebViewVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface WebViewVC ()<UIWebViewDelegate>
@property(strong,nonatomic) UIWebView *web;
@end

@implementation WebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *web = [UIWebView new];
    web.delegate = self;
    web.scalesPageToFit = true;
    web.frame = CGRectMake(0, 0,400, 400);
    [self.view addSubview:web];
    NSString*path =  [[NSBundle mainBundle] pathForResource:@"b" ofType:@"html"];
    NSString *htmlStr = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [web loadHTMLString:htmlStr baseURL:nil];
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
    [jumpWebBtn setTitle:@"返回" forState:UIControlStateNormal];
    [jumpWebBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [jumpWebBtn addTarget:self action:@selector(touchBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.web stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function myFunction() { "   //定义myFunction方法
     "alert('注入js');"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];  //添加到head标签中
}
- (void)touchBtn
{
    [_web stringByEvaluatingJavaScriptFromString:@"callJS('ok');" ];
}
- (void)touchBackBtn
{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}
- (void)back
{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}
#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"testapp"])
    {
        [self back];
        return false;
    }
    return true;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取js写的界面的title
        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //＊解决webview上内嵌的页面中弹出来的alert有域名问题！＊/ PS：这个才是这篇博客的关键
    //1、获取js的执行环境
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //2、js那边写的提示框的函数入口，这里差不多有点重写那个函数的意思。JSValue *message参数可以获取到js中的提示信息，OC中需要转换为string显示出来，好了完成了。
    ctx[@"window"][@"alert"] = ^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    
    };
    ctx[@"window"][@"confirm"]=^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    };
    ctx[@"window"][@"prompt"] = ^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    };
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
@end

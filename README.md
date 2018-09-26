## 1.简介
iOS开发中不可避免会遇到跟H5界面的问题，本文将详细讲解OC和web的交互，供大家学习参考。
## 2.概述
### 2.1交互综合起来只有两种方式
 - OC调用JS
 - JS调用OC

 ### 2.2加载JS的方式
 OC开发中加载网页有两种选择，iOS7之前使用UIWebView，iOS8之后时候WKWebView，后续将分别讲解UIWebView和WKWebView如何和网页交互实现JS和OC的相互调用。
 ### 2.3网页中加载框显示异常
主要有如下两个问题
 - 提示框无法显示
 - 提示框标题显示异常

 ## 3.UIWebView和网页的交互
 ### 3.1原生OC调用网页的JS
```
[_web stringByEvaluatingJavaScriptFromString:@"callJS('ok');" ];
以上代码即可实现webView调用网页，其中的callJS为js的方法，ok是传入的参数
```
 ### 3.2网页JS调用原生OC的方法
 #### 3.2.1 拦截请求
 
OC端代码
```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    //拦截UIWebView请求的URL，根据不同的规则，可以调用不同的OC方法
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"testapp"])
    {
        [self back];
        return false;
    }
    return true;
}
- (void)back
{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}
```
JS端代码
```
在这里插入代码片
function clickLink(){
            var url="testapp:"+"alert"+":"+"你好吗？";
            document.location = url;
        }
```
 #### 3.3.2 注入JS代码
 OC端代码
 

```
 [self.web stringByEvaluatingJavaScriptFromString:@"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function myFunction() { "   //定义myFunction方法
     "alert('注入js');"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];  
     OC代码中自定义JS方法myFunction注入到网页中，JS端可以直接调用myFunction方法。由于该方法是OC中注入的，故而可以传入一定的参数用于网页端和OC端的通信。
```
JS端代码

```
function callInjeJs(){
            myFunction();
        }
```
## 4.WKWebView和网页的交互
### 4.1.原生OC调用网页的JS
OC端代码
```
 [_web evaluateJavaScript:@"callJS('ok')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
 以上代码即可实现webView调用网页，其中的callJS为js的方法，ok是传入的参数
```
JS端代码

```
 function callJS(str1)
        {
            alert(str1);
        }
```

### 4.2.网页JS调用原生OC的方法
OC端代码
```
 WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
 [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
 WKWebView *web = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0,400, 250) configuration:config];
  [self.view addSubview:web];
    
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *name = message.name;
    if([name isEqualToString:@"AppModel"])
    {
        NSString *bodyStr = message.body;
        NSLog(@"JS调用OC成功 参数为= %@",bodyStr);
    }
}
该方法为WKScriptMessageHandler的协议方法，务必遵守该协议
```
JS端代码
```
 function callOC()
        {
            window.webkit.messageHandlers.AppModel.postMessage({body: 'param1'});
        }
        其中AppModel为名称，{body,'param1'}为自定义的参数
```
## 5.JS提示框显示异常问题
### 5.1.JS提示框在UIWebView中显示异常
JS提示框在UIWebView显示时，经常会出现一个URL的地址，在其他客户端（如安卓）没有此问题。该问题可通过如下代码解决:

```
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取js写的界面的title
        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //＊解决webview上内嵌的页面中弹出来的alert有域名问题！＊/ PS：这个才是这篇博客的关键
    //1、获取js的执行环境
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //2、js那边写的提示框的函数入口，这里差不多有点重写那个函数的意思。JSValue *message参数可以获取到js中的提示信息，OC中需要转换为string显示出来，好了完成了。
    //解决Alert类型的提示框异常问题
    ctx[@"window"][@"alert"] = ^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
        //自定义原生提示框替换原来的提示框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    };
    //解决confirm提示框显示异常问题
    ctx[@"window"][@"confirm"]=^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
          //自定义原生提示框替换原来的提示框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    };
    //解决prompt提示框显示异常问题
    ctx[@"window"][@"prompt"] = ^(JSValue *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
          //自定义原生提示框替换原来的提示框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[message toString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    };
}
```

### 5.2. JS提示框在WKWebView中显示异常
JS提示框在WKWebView中会无法显示，可以通过以下的方案解决。
```
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
```
## 6 总结
本文针对ios开发中webview和网页的交互问题做了简单总结，后续有任何问题还会更新。如果各位有任何问题，欢迎回复。

[**源码地址**](https://github.com/ydbwwhq/webWithOC)




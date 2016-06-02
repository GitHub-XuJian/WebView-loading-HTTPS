//
//  MainViewController.m
//  webView
//
//  Created by 徐健 on 16/5/11.
//  Copyright © 2016年 徐健. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()<UIWebViewDelegate,NSURLConnectionDelegate>
{
    BOOL _authenticated;  // 是否需要通过身份验证
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSURLRequest *urlRequest;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _authenticated = NO;

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.backgroundColor = [UIColor redColor];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    [self createUrlRequest];
    
}
- (void)createUrlRequest
{
    NSString * fileUrl = @"https://www.baidu.com";
    NSString *urlString = [fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:request];

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
     NSString* scheme = [[request URL] scheme];
    if ([scheme isEqualToString:@"https"]) {
        if (!_authenticated) {
            _urlRequest = request;
            _authenticated = NO;
            _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [_urlConnection start];
            return NO;

        }
    }
    return YES;
}
#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    if ([challenge previousFailureCount] == 0)
    {
        _authenticated = YES;
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    _authenticated =YES;
    [self.webView loadRequest:_urlRequest];
    
    [_urlConnection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
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

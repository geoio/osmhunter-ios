//
//  OSMLoginViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 24/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "OSMLoginViewController.h"
#import "APIClient.h"
#import "SettingsManager.h"
#import "NSURL+QueryParser.h"


@interface OSMLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation OSMLoginViewController

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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[APIClient sharedClient] getAuthDataWithCompletion:^(NSDictionary *data, NSError *error) {
        if (data) {
            NSURL *redirectURL = [NSURL URLWithString:data[@"result"][@"redirect_url"]];
            NSString *sessionId = data[@"result"][@"session_id"];
            [[SettingsManager sharedInstance] setSessionId:sessionId];
            [self.webView loadRequest:[NSURLRequest requestWithURL:redirectURL]];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        NSDictionary *queryDict = [request.URL queryDictionary];
//        NSLog(@"URL: %@", request.URL);
        if (queryDict[@"oauth_token"]) {
            NSString *oauthToken = queryDict[@"oauth_token"];
            NSString *sessionId = [[SettingsManager sharedInstance] sessionId];
            [[APIClient sharedClient] getApiKeyForSessionId:sessionId oauthToken:oauthToken completion:^(NSDictionary *data, NSError *error) {
                if (data) {
                    [[SettingsManager sharedInstance] setApiKey:data[@"result"][@"apikey"]];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardMainIPhone bundle:nil];
                    UIViewController *viewController = [storyboard instantiateInitialViewController];
                    [self presentViewController:viewController animated:YES completion:nil];
                } else {
                    NSLog(@"Error: %@", error);
                }
            }];
        }
    }
    
    return YES;
}

@end

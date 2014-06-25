//
//  HomeViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 24/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "HomeViewController.h"
#import "ApiClient.h"
#import "SettingsManager.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userPoints;

@end

@implementation HomeViewController

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
    
    if (![[SettingsManager sharedInstance] userName]) {
        [[SettingsManager sharedInstance] updateUserInfoWithCompletion:^(BOOL success, NSError *error) {
            [self setupUserInfo];
        }];
    } else {
        [self setupUserInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[APIClient sharedClient] getUserInfoWithCompletion:^(NSDictionary *data, NSError *error) {
        if (data) {
            self.userPoints.text = [NSString stringWithFormat:@"%@ points", [data[@"result"][@"points"] stringValue]];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)setupUserInfo {
    self.userImage.image = [[SettingsManager sharedInstance] userImage];
    self.userName.text = [[SettingsManager sharedInstance] userName];
    self.userPoints.text = [[SettingsManager sharedInstance] userPoints];
}

@end

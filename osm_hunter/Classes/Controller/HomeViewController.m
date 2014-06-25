//
//  HomeViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 24/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "HomeViewController.h"
#import "ApiClient.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.userImage.image = [UIImage imageNamed:@"user_placeholder"];
    [[APIClient sharedClient] getUserInfoWithCompletion:^(NSDictionary *data, NSError *error) {
        if (data) {
            self.username.text = data[@"result"][@"display_name"];
            self.userPoints.text = [NSString stringWithFormat:@"%@ points", [data[@"result"][@"points"] stringValue]];
            NSURL *imageUrl = [NSURL URLWithString:data[@"result"][@"image"]];
            NSData *data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage *img = [UIImage imageWithData:data];
            self.userImage.image = [img thumbnailImage:120 transparentBorder:0 cornerRadius:15 interpolationQuality:kCGInterpolationDefault];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

@end

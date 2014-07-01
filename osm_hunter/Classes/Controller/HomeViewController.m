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
@property (weak, nonatomic) IBOutlet UIButton *discoverButton;

@property(nonatomic, strong) NSArray *iPhoneVerticalConstraints;
@property(nonatomic, strong) NSArray *iPhoneHorizontalConstraints;

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

- (void)viewWillLayoutSubviews {
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        NSLog(@"Layout horizontal");
        [self.view removeConstraints:self.iPhoneVerticalConstraints];
        [self.view addConstraints:self.iPhoneHorizontalConstraints];
    } else {
//        NSLog(@"Layout vertical");
        [self.view removeConstraints:self.iPhoneHorizontalConstraints];
        [self.view addConstraints:self.iPhoneVerticalConstraints];
    }
}

- (void)viewDidLayoutSubviews
{
    
}

- (NSArray *)iPhoneVerticalConstraints {
    if (!_iPhoneVerticalConstraints) {
        _iPhoneVerticalConstraints = @[
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.userImage
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.f
                                                                       constant:1.f],
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton.superview
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.f
                                                                       constant:1.f],
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.userPoints
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.f
                                                                       constant:20.f],
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.discoverButton.superview
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.f
                                                                       constant:38.f]

                                         ];
        
    }
    return _iPhoneVerticalConstraints;
}

- (NSArray *)iPhoneHorizontalConstraints {
    if (!_iPhoneHorizontalConstraints) {
        _iPhoneHorizontalConstraints = @[
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.userImage
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1.f
                                                                       constant:30.f],
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.discoverButton.superview
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.f
                                                                       constant:66.f],
                                         [NSLayoutConstraint constraintWithItem:self.userImage
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.f
                                                                       constant:1.f],
                                         [NSLayoutConstraint constraintWithItem:self.discoverButton.superview
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.discoverButton
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.f
                                                                       constant:50.f]
                                         ];
    }
    return _iPhoneHorizontalConstraints;
}

- (void)setupUserInfo {
    self.userImage.image = [[SettingsManager sharedInstance] userImage];
    self.userName.text = [[SettingsManager sharedInstance] userName];
    self.userPoints.text = [[SettingsManager sharedInstance] userPoints];
}

@end

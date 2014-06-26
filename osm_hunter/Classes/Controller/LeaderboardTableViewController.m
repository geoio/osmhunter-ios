//
//  LeaderboardTableViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 25/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "LeaderboardTableViewController.h"
#import "ApiClient.h"
#import "SVProgressHUD.h"
#import "SettingsManager.h"
#import "UIImage+Resize.h"


@interface LeaderboardTableViewController ()

@property(nonatomic, strong) NSMutableArray *results;

@end

@implementation LeaderboardTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)results {
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    [[APIClient sharedClient] getLeaderBoardWithCompletion:^(NSDictionary *data, NSError *error) {
        [SVProgressHUD dismiss];
        if (data) {
            for (NSDictionary *item in data[@"result"]) {
                [self.results addObject:item];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellLeader forIndexPath:indexPath];
    
    NSDictionary *leaderItem = self.results[indexPath.row];
    
    cell.textLabel.text = leaderItem[@"username"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ points", leaderItem[@"points"]];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:leaderItem[@"image"]]];
    UIImage *userImage = [UIImage imageWithData: imageData];
    
    cell.imageView.image = [userImage thumbnailImage:100 transparentBorder:0 cornerRadius:50 interpolationQuality:kCGInterpolationDefault];
    
    if ([leaderItem[@"myself"] intValue] == 1) {
        cell.backgroundColor = [UIColor colorWithRed:98/255.0 green:147/255.9 blue:157/255.0 alpha:0.1];
    }
    
    return cell;
}

@end

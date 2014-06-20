//
//  BuildingInfoViewController.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Building.h"

@interface BuildingInfoViewController : UITableViewController

@property(nonatomic, strong) Building *building;

@end

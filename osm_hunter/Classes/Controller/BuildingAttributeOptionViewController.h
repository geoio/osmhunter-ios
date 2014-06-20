//
//  BuildingAttributeOptionViewController.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Building.h"
#import "BuildingAttributeSelect.h"

@interface BuildingAttributeOptionViewController : UITableViewController

@property(nonatomic, strong) Building *building;
@property(nonatomic) int selectedBuildingAttributeIndex;

@end

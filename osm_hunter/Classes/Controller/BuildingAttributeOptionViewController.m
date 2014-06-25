//
//  BuildingAttributeOptionViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "BuildingAttributeOptionViewController.h"
#import "BuildingAttributeOption.h"

@interface BuildingAttributeOptionViewController ()

@property (nonatomic, assign) BuildingAttributeSelect *selectedBuildingAttribute;

@end

@implementation BuildingAttributeOptionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.selectedBuildingAttribute = self.building.attributes[self.selectedBuildingAttributeIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selectedBuildingAttribute.options count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellAttribureOptionValue forIndexPath:indexPath];
    BuildingAttributeOption *option = self.selectedBuildingAttribute.options[indexPath.row];
    
    cell.textLabel.text = option.label;
    
    if ([self.selectedBuildingAttribute.value isEqualToString:option.value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BuildingAttributeOption *selectedOption = self.selectedBuildingAttribute.options[indexPath.row];
    self.selectedBuildingAttribute.value = selectedOption.value;
    [self.navigationController popViewControllerAnimated:YES];
}

@end

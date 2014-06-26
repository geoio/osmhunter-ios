//
//  BuildingInfoViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BuildingInfoViewController.h"
#import "BuildingAttributeOptionViewController.h"
#import "BuildingAttribute.h"
#import "BuildingAttributeText.h"
#import "BuildingAttributeSelect.h"
#import "BuildingAttributeTextCell.h"
#import "APIClient.h"
#import "SVProgressHUD.h"

#define SECTION_INFO 0
#define SECTION_BUILDING_ATTRIBUTES 1
#define SECTION_ACTIONS 2


@interface BuildingInfoViewController () <UITextFieldDelegate>

@property(nonatomic) int selectedBuildingAttributeIndex;

@end

@implementation BuildingInfoViewController

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view.window endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_INFO:
            return 2;
        case SECTION_BUILDING_ATTRIBUTES:
            return [self.building.attributes count];
        case SECTION_ACTIONS:
            return 1;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_INFO:
            return [self tableView:self.tableView infoCellForRowAtIndexPath:indexPath];
        case SECTION_BUILDING_ATTRIBUTES:
            return [self tableView:self.tableView attributeCellForRowAtIndexPath:indexPath];
        case SECTION_ACTIONS:
            return [self tableView:self.tableView actionCellForRowAtIndexPath:indexPath];
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellInfo forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Building id";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.building.buildingId];
            break;
        case 1:
            cell.textLabel.text = @"Distance";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km", self.building.distance];
            break;

        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView attributeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuildingAttribute *buildingAttribute = self.building.attributes[indexPath.row];
    if ([buildingAttribute isKindOfClass:[BuildingAttributeText class]]) {
        BuildingAttributeTextCell *cell = (BuildingAttributeTextCell *)[tableView dequeueReusableCellWithIdentifier:kCellText forIndexPath:indexPath];
        
        BuildingAttributeText *attr = (BuildingAttributeText *)buildingAttribute;
        cell.attributeTitleLabel.text = attr.label;
        cell.attributeTextField.text = attr.value;
        cell.attributeTextField.delegate = self;
        cell.attributeTextField.tag = indexPath.row;
        if (attr.prefilled == YES) {
            cell.attributeTextField.textColor = [UIColor purpleColor];
        } else {
            cell.attributeTextField.textColor = [UIColor blackColor];
        }
        return cell;

    } else if ([buildingAttribute isKindOfClass:[BuildingAttributeSelect class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellSelect forIndexPath:indexPath];
        
        BuildingAttributeSelect *attr = (BuildingAttributeSelect *)buildingAttribute;
        cell.textLabel.text = attr.label;
        cell.detailTextLabel.text = attr.value;
//        NSLog(@"Attr: %@", attr);
        return cell;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView actionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellAction forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Navigate";
            break;
        default:
            break;
    }


    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_INFO:
            return @"Info";
        case SECTION_BUILDING_ATTRIBUTES:
            return @"Attributes";
        case SECTION_ACTIONS:
            return @"Actions";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case SECTION_BUILDING_ATTRIBUTES:
            return @"Attention: Please verify purple prefilled fields";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        BuildingAttributeSelect *buildingAttribute = self.building.attributes[indexPath.row];
        if ([buildingAttribute isKindOfClass:[BuildingAttributeSelect class]]) {
            self.selectedBuildingAttributeIndex = (int)indexPath.row;
            [self performSegueWithIdentifier:kSegueSelectAttributeOption sender:self];
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [self navigateToBuilding];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
            default:
                break;
        }
    }
}

# pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BuildingAttribute *attribute = self.building.attributes[textField.tag];
    attribute.value = textField.text;
    attribute.prefilled = NO;
    [self.tableView reloadData];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueSelectAttributeOption]) {
        [segue.destinationViewController setBuilding:self.building];
        [segue.destinationViewController setSelectedBuildingAttributeIndex:self.selectedBuildingAttributeIndex];
    }
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.view.window endEditing:YES];
    [SVProgressHUD showWithStatus:@"Submitting data" maskType:SVProgressHUDMaskTypeBlack];
    [[APIClient sharedClient] updateBuildingAttributes:self.building.buildingId attributes:[self prepareBuildingAttributes] completion:^(NSDictionary *responseData, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Thank you for your support"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (NSDictionary *)prepareBuildingAttributes {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (BuildingAttribute *attribute in self.building.attributes) {
        if (attribute.value && attribute.value.length > 0) {
            attributes[attribute.name] = attribute.value;
        }
    }
    NSLog(@"%@", attributes);
    return attributes;
}

- (void)navigateToBuilding {
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:self.building.shapeCenter addressDictionary:nil];
    MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    destination.name = [NSString stringWithFormat:@"%.5f, %.5f", self.building.shapeCenter.latitude, self.building.shapeCenter.longitude];
    if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
    }
}

@end

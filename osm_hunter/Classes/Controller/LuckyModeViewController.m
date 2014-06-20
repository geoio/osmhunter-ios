//
//  LuckyModeViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 17/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import "SVProgressHUD.h"
#import "LuckyModeViewController.h"
#import "BuildingInfoViewController.h"
#import "LocationController.h"
#import "APIClient.h"
#import "Building.h"
#import "LocationController.h"

@interface LuckyModeViewController () <RMMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBuildingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousBuildingButton;


@property (nonatomic, strong) IBOutlet RMMapView *mapBoxView;
@property (nonatomic, strong) Building *selectedBuilding;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *oldLocation;
@property (nonatomic, strong) NSMutableArray *buildings;
@property (nonatomic, strong) Building *currentBuilding;
@property (nonatomic) int currentOffset;
@property (nonatomic) int currentBuildingIndex;

@end

@implementation LuckyModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)setCurrentBuilding:(Building *)newBuilding {
    if (_currentBuilding != newBuilding) {
        _currentBuilding = newBuilding;
        [self drawCurrentBuilding];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RMMapboxSource *mapBoxTileSource = [[RMMapboxSource alloc] initWithMapID:kMapBoxMapId];
    self.mapBoxView = [[RMMapView alloc] initWithFrame:self.view.frame andTilesource:mapBoxTileSource];
    self.mapBoxView.showsUserLocation = YES;
    self.mapBoxView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
//    self.mapBoxView.hideAttribution = YES;
    self.mapBoxView.delegate = self;
    [self.contentView addSubview:self.mapBoxView];
    self.currentOffset = 0;
    self.currentBuildingIndex = 0;
    self.previousBuildingButton.enabled= NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocationController sharedInstance] checkLocationServicesTurnedOn];
    [[LocationController sharedInstance] checkApplicationHasLocationServicesPermission];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.mapBoxView.showsUserLocation = NO;
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNextBuildingButtonPressed:(id)sender {
    [self showNextBuilding];
}

- (IBAction)showPreviousBuildingButtonPressed:(id)sender {
    [self showPreviousBuilding];
}

- (void)showNextBuilding {
    if (self.currentBuildingIndex + 1 < self.buildings.count) {
        self.currentBuildingIndex++;
        self.currentBuilding = self.buildings[self.currentBuildingIndex];
        self.previousBuildingButton.enabled = YES;
    } else {
        self.nextBuildingButton.enabled = NO;
        if (!self.buildings) {
            self.buildings = [NSMutableArray array];
        }
        [SVProgressHUD showWithStatus:@"Loading data"];
        [[APIClient sharedClient] getBuildingsNearby:self.currentLocation.coordinate limit:kFetchLimit offset:self.currentOffset completion:^(NSDictionary *responseData, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                NSArray *results = responseData[@"results"];
                if (results.count > 0) {
                    self.nextBuildingButton.enabled = YES;
                    for (NSDictionary *item in responseData[@"results"]) {
                        Building *building = [[Building alloc] initWithDictionary:item];
                        [self.buildings addObject:building];
                    }
                    
                    self.currentBuildingIndex = self.currentOffset;
                    self.currentBuilding = self.buildings[self.currentBuildingIndex];

                    self.currentOffset += kFetchLimit;
                    if (self.currentBuildingIndex > 0) {
                        self.previousBuildingButton.enabled = YES;
                    }
                } else {
                    self.nextBuildingButton.enabled = NO;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"No more buildings nearby"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)showPreviousBuilding {
    if (self.currentBuildingIndex > 0) {
        self.currentBuildingIndex--;
        self.currentBuilding = self.buildings[self.currentBuildingIndex];
        if (self.currentBuildingIndex == 0) {
            self.previousBuildingButton.enabled = NO;
        }
        if (self.currentBuildingIndex < self.buildings.count) {
            self.nextBuildingButton.enabled = YES;
        }
    }
}

- (void)drawCurrentBuilding {
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapBoxView
                                                          coordinate:self.mapBoxView.centerCoordinate
                                                            andTitle:nil];
    
    annotation.userInfo = self.currentBuilding;
    [self.mapBoxView removeAllAnnotations];
    [self.mapBoxView addAnnotation:annotation];
    [self.mapBoxView setCenterCoordinate:self.currentBuilding.shapeCenter];
}

#pragma mark RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;

    
    Building *building = (Building *)annotation.userInfo;
    RMShape *shape = [[RMShape alloc] initWithView:self.mapBoxView];
    
    shape.lineColor = [UIColor yellowColor];
    shape.lineWidth = 2.0;
    shape.fillColor = [UIColor purpleColor];
    
    for (CLLocation *point in building.shapeNodes)
        [shape addLineToCoordinate:point.coordinate];
    
    return shape;
}

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation {
    self.selectedBuilding = (Building *)annotation.userInfo;
    [SVProgressHUD showWithStatus:@"Loading data"];
    [[APIClient sharedClient] getBuildingAttributes:self.selectedBuilding.buildingId completion:^(NSDictionary *responseData, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [self.selectedBuilding loadAttributesFromDictionary:responseData];
            [self performSegueWithIdentifier:kSegueShowBuildingInfo sender:self];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation {
    if (!self.currentLocation) {
        self.currentLocation = userLocation.location;
        [self.mapBoxView setZoom:20 animated:YES];
    }
    self.currentLocation = userLocation.location;
    
    if (!self.buildings) {
        [self showNextBuilding];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueShowBuildingInfo]) {
        [segue.destinationViewController setBuilding:self.selectedBuilding];
    }
}

@end

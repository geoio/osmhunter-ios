//
//  DiscoverModeViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 18/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import "SVProgressHUD.h"
#import "DiscoverModeViewController.h"
#import "BuildingInfoViewController.h"
#import "LocationController.h"
#import "APIClient.h"
#import "Building.h"

@interface DiscoverModeViewController () <RMMapViewDelegate>

@property (nonatomic, strong) IBOutlet RMMapView *mapBoxView;
@property (nonatomic, strong) Building *selectedBuilding;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *oldLocation;

@end

@implementation DiscoverModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
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
    [self.view addSubview:self.mapBoxView];
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

- (void)fetchResults {
    if (self.currentLocation) {
        [SVProgressHUD showWithStatus:@"Loading data"];
        NSMutableArray *annotations = [NSMutableArray array];
        [[APIClient sharedClient] getBuildingsNearby:self.currentLocation.coordinate limit:kFetchLimit offset:0 completion:^(NSDictionary *responseData, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [self.mapBoxView removeAllAnnotations];
                for (NSDictionary *item in responseData[@"results"]) {
                    Building *building = [[Building alloc] initWithDictionary:item];
                    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapBoxView
                                                                          coordinate:self.mapBoxView.centerCoordinate
                                                                            andTitle:@"My Path"];
                    annotation.userInfo = building;
                    [annotations addObject:annotation];
                }
                
                [self.mapBoxView addAnnotations:annotations];
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

#pragma mark RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    
    Building *building = (Building *)annotation.userInfo;
    //    BuildingShape *shape = [BuildingShape shapeForBuilding:building];
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
        [self.mapBoxView setZoom:17 animated:YES];
        [self fetchResults];
    }
    if (!self.oldLocation) {
        self.oldLocation = userLocation.location;
    }
    
    [self.mapBoxView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
    
    CLLocationDistance distance = [self.oldLocation distanceFromLocation:self.currentLocation];
    if (distance > 100) {
        [self fetchResults];
        self.oldLocation = self.currentLocation;
    }
    self.currentLocation = userLocation.location;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueShowBuildingInfo]) {
        [segue.destinationViewController setBuilding:self.selectedBuilding];
    }
}

@end

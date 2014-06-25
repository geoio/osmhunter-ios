//
//  DiscoverModeViewController.m
//  osm_hunter
//
//  Created by Andrew Teil on 18/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import "UIImage+Rotate.h"
#import "DiscoverModeViewController.h"
#import "BuildingInfoViewController.h"
#import "LocationController.h"
#import "APIClient.h"
#import "Building.h"

@interface DiscoverModeViewController () <RMMapViewDelegate, LocationControllerDelegate>

@property (nonatomic, strong) IBOutlet RMMapView *mapBoxView;
@property (nonatomic, strong) Building *selectedBuilding;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) CLLocationCoordinate2D southWest;
@property (nonatomic) CLLocationCoordinate2D northEast;

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
    self.mapBoxView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
    self.mapBoxView.showsUserLocation = NO;
    self.mapBoxView.delegate = self;
    [self.view addSubview:self.mapBoxView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocationController sharedInstance] setDelegate:self];
    [[LocationController sharedInstance] start];
    
    [[LocationController sharedInstance] checkLocationServicesTurnedOn];
    [[LocationController sharedInstance] checkApplicationHasLocationServicesPermission];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[LocationController sharedInstance] stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    self.mapBoxView.frame = self.view.frame;
}

- (void)fetchResults {
    if (self.currentLocation) {
        [self showNavbarLoadingMessage];
        NSMutableArray *annotations = [NSMutableArray array];
        [[APIClient sharedClient] getBuildingsNearby:self.northEast southWest:self.southWest  userCoordinates:self.currentLocation.coordinate completion:^(NSDictionary *responseData, NSError *error) {
            [self hideNavbarLoadingMessage];
            if (!error) {
                for (RMAnnotation *annotation in self.mapBoxView.annotations) {
                    if ([annotation.userInfo isKindOfClass:[Building class]]) {
                        [self.mapBoxView removeAnnotation:annotation];
                    }
                }
//                [self.mapBoxView removeAllAnnotations];
                for (NSDictionary *item in responseData[@"results"]) {
                    Building *building = [[Building alloc] initWithDictionary:item];
                    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapBoxView
                                                                          coordinate:self.mapBoxView.centerCoordinate
                                                                            andTitle:nil];
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

- (void)showNavbarLoadingMessage {
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [ai startAnimating];
    self.navigationItem.title = @"Loading data...";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ai];
}

- (void)hideNavbarLoadingMessage {
    self.navigationItem.title = nil;
//    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)userLocationButtonPressed:(id)sender {
    [self.mapBoxView setZoom:17 animated:YES];
    [self.mapBoxView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
//    [self fetchResults];
}

#pragma mark RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    if ([annotation.userInfo isKindOfClass:[Building class]]) {
        Building *building = (Building *)annotation.userInfo;
        //    BuildingShape *shape = [BuildingShape shapeForBuilding:building];
        RMShape *shape = [[RMShape alloc] initWithView:self.mapBoxView];
        
        shape.lineColor = [UIColor yellowColor];
        shape.lineWidth = 2.0;
        shape.fillColor = [UIColor purpleColor];
        
        for (CLLocation *point in building.shapeNodes)
            [shape addLineToCoordinate:point.coordinate];
        
        return shape;
    } else {
        CLHeading *heading = (CLHeading *)annotation.userInfo;
        UIImage *headingArrow = [[UIImage imageNamed:@"heading_arrow"] imageRotatedByDegrees:heading.magneticHeading];
        RMMarker *userLocationMarker = [[RMMarker alloc] initWithUIImage:headingArrow];
        userLocationMarker.annotation = annotation;
        return userLocationMarker;
    }
}

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation {
    if ([annotation.userInfo isKindOfClass:[Building class]]) {
        self.selectedBuilding = (Building *)annotation.userInfo;
        [self showNavbarLoadingMessage];
        [[APIClient sharedClient] getBuildingAttributes:self.selectedBuilding.buildingId completion:^(NSDictionary *responseData, NSError *error) {
            [self hideNavbarLoadingMessage];
            if (!error) {
                [self.selectedBuilding loadAttributesFromDictionary:responseData];
                [self performSegueWithIdentifier:kSegueShowBuildingInfo sender:self];
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
    if (wasUserAction == YES) {
        self.northEast = self.mapBoxView.latitudeLongitudeBoundingBox.northEast;
        self.southWest = self.mapBoxView.latitudeLongitudeBoundingBox.southWest;
        [self fetchResults];
    }
}

#pragma mark LocationController delegate

- (void)didUpdateLocation:(CLLocation *)location {
    if (!self.currentLocation) {
        self.currentLocation = location;
        [self.mapBoxView setZoom:17 animated:YES];
        [self.mapBoxView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
        self.northEast = self.mapBoxView.latitudeLongitudeBoundingBox.northEast;
        self.southWest = self.mapBoxView.latitudeLongitudeBoundingBox.southWest;
        [self fetchResults];
    }

    self.currentLocation = location;
}

- (void)didUpdateHeading:(CLHeading *)newHeading {
    for (RMAnnotation *annotaion in self.mapBoxView.annotations) {
        if (![annotaion.userInfo isKindOfClass:[Building class]]) {
            [self.mapBoxView removeAnnotation:annotaion];
        }
    }
    RMAnnotation *userLocation = [RMAnnotation annotationWithMapView:self.mapBoxView coordinate:self.currentLocation.coordinate andTitle:nil];
    userLocation.userInfo = newHeading;
    [self.mapBoxView addAnnotation:userLocation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueShowBuildingInfo]) {
        [segue.destinationViewController setBuilding:self.selectedBuilding];
    }
}

@end

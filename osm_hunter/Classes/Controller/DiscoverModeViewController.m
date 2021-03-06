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
#import "UIColor+HTMLColors.h"


#define MIN_FETCH_ZOOM_LEVEL 15


@interface DiscoverModeViewController () <RMMapViewDelegate, LocationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property(nonatomic, strong) RMMapView *mapBoxView;
@property(nonatomic, strong) Building *selectedBuilding;
@property(nonatomic, strong) CLLocation *currentLocation;
@property(nonatomic, strong) CLLocation *mapCenter;

@property(nonatomic) CLLocationCoordinate2D northEast;
@property(nonatomic) CLLocationCoordinate2D southWest;

@end

@implementation DiscoverModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    RMMapboxSource *mapBoxTileSource = [[RMMapboxSource alloc] initWithMapID:kMapBoxMapId];
    self.mapBoxView = [[RMMapView alloc] initWithFrame:self.contentView.frame andTilesource:mapBoxTileSource];
    self.mapBoxView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
    self.mapBoxView.showsUserLocation = NO;
    self.mapBoxView.displayHeadingCalibration = YES;
    self.mapBoxView.delegate = self;
    [self.contentView addSubview:self.mapBoxView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    self.mapBoxView.frame = self.contentView.frame;
}

- (void)fetchResults {
    [self showNavbarLoadingMessage];
    NSMutableArray *annotations = [NSMutableArray array];
    [[APIClient sharedClient] getBuildingsNearby:self.northEast southWest:self.southWest completion:^(NSDictionary *responseData, NSError *error) {
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.northEast = self.mapBoxView.latitudeLongitudeBoundingBox.northEast;
        self.southWest = self.mapBoxView.latitudeLongitudeBoundingBox.southWest;
        [self fetchResults];
    });
}

#pragma mark RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation {
    if (annotation.isUserLocationAnnotation)
        return nil;

    if ([annotation.userInfo isKindOfClass:[Building class]]) {
        Building *building = (Building *) annotation.userInfo;
        RMShape *shape = [[RMShape alloc] initWithView:self.mapBoxView];

        shape.lineColor = [UIColor colorWithCSS:kAppColorMain];
        shape.lineWidth = 2.0f;
        shape.fillColor = [UIColor colorWithCSS:kAppColorBuildingBackground];

        for (CLLocation *point in building.shapeNodes)
            [shape addLineToCoordinate:point.coordinate];

        return shape;
    } else {
        CLHeading *heading = (CLHeading *) annotation.userInfo;
//        UIImage *headingArrow = [[UIImage imageNamed:@"icon_positioner_compass"] imageRotatedByDegrees:heading.magneticHeading];
        UIImage *headingArrow = [[UIImage imageNamed:@"heading"] imageRotatedByDegrees:heading.magneticHeading];
        RMMarker *userLocationMarker = [[RMMarker alloc] initWithUIImage:headingArrow];
        userLocationMarker.annotation = annotation;
        return userLocationMarker;
    }
}

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation {
    if ([annotation.userInfo isKindOfClass:[Building class]]) {
        self.selectedBuilding = (Building *) annotation.userInfo;
        [self showNavbarLoadingMessage];
        [[APIClient sharedClient] getBuildingAttributes:self.selectedBuilding.buildingId completion:^(NSDictionary *responseData, NSError *error) {
            [self hideNavbarLoadingMessage];
            if (!error) {
                NSLog(@"Attributes: %@", responseData);
                [self.selectedBuilding loadAttributesFromDictionary:responseData];
                [self performSegueWithIdentifier:kSegueShowBuildingInfo sender:self];
            } else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
    self.mapCenter = [[CLLocation alloc] initWithLatitude:map.centerCoordinate.latitude longitude:map.centerCoordinate.longitude];
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
    self.southWest = map.latitudeLongitudeBoundingBox.southWest;
    self.northEast = map.latitudeLongitudeBoundingBox.northEast;
    [self onBoundingBoxChange:map byUser:wasUserAction];
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction {
    self.southWest = map.latitudeLongitudeBoundingBox.southWest;
    self.northEast = map.latitudeLongitudeBoundingBox.northEast;
    [self onBoundingBoxChange:map byUser:wasUserAction];
}

- (void)onBoundingBoxChange:(RMMapView *)map byUser:(BOOL)wasUserAction {
//    NSLog(@"Zoom: %.2f", self.mapBoxView.zoom);
    if (wasUserAction) {
        if (map.zoom > MIN_FETCH_ZOOM_LEVEL) {
            self.navigationItem.title = @"";
            [self fetchResults];
        } else {
            self.navigationItem.title = @"Zoom in to load data";
        }
    }
}
#pragma mark LocationController delegate

- (void)didUpdateLocation:(CLLocation *)location {
    if (!self.currentLocation) {
        self.currentLocation = location;
        [self.mapBoxView setZoom:17 animated:YES];
        [self.mapBoxView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.northEast = self.mapBoxView.latitudeLongitudeBoundingBox.northEast;
            self.southWest = self.mapBoxView.latitudeLongitudeBoundingBox.southWest;
            [self fetchResults];
        });
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

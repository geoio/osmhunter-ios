//
//  LocationController.h
//  NochOffen
//
//  Created by Andrew Teil on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"


@interface LocationController() {
    CLLocationManager *locationManager;
}

@end

@implementation LocationController


static LocationController *sharedInstance;

+ (LocationController *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[LocationController alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _locationKnown = NO;
        self.currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = 100;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.delegate = self;
        [self start];
    }
    return self;

}

- (void)start {
    [locationManager startUpdatingLocation];
    [self.delegate didStartUpdatingLocation];
    NSLog(@"Start updating location");
}

- (void)stop {
    [locationManager stopUpdatingLocation];
    //[self.delegate didStopUpdatingLocation];
    NSLog(@"Stop updating location");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self locationUpdated:[locations lastObject]];
}


// This method is deprecated in iOS 6 and it doesn't get called
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     
        [self locationUpdated:newLocation];
    }
}

- (void)locationUpdated:(CLLocation *)newLocation {
    self.currentLocation = newLocation;
    [self.delegate didSuccessUpdatingLocation:self.currentLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationUpdated object:self];
    NSLog(@"Location updated: latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    if (!_locationKnown) {
        NSLog(@"Location is now known");
        _locationKnown = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationKnown object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.description);
    [self.delegate didFailureUpdatingLocation];
}

- (void)checkLocationServicesTurnedOn {
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"'Location Services' need to be on", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];      
    }     
}

- (void)checkApplicationHasLocationServicesPermission {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tip", @"Tip")
                                                        message:NSLocalizedString(@"This application needs 'Location Services' to be turned on.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];      
    }    
}

- (void)didStopUpdatingLocation {
    NSLog(@"Stop updating location");
}


@end
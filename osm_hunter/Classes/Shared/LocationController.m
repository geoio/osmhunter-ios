//
//  LocationController.h
//  osm_hunter
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
//        locationManager.distanceFilter = 100;
        locationManager.activityType = CLActivityTypeOtherNavigation;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.delegate = self;
        [self start];
    }
    return self;

}

- (void)start {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    if ([self.delegate respondsToSelector:@selector(didStartUpdatingLocation)]) {
        [self.delegate didStartUpdatingLocation];
    }
    NSLog(@"Start updating location");
}

- (void)stop {
    [locationManager stopUpdatingLocation];
    if ([self.delegate respondsToSelector:@selector(didStopUpdatingLocation)]) {
        [self.delegate didStopUpdatingLocation];
    }
    NSLog(@"Stop updating location");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([self.delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        self.currentLocation = [locations lastObject];
        [self.delegate didUpdateLocation:self.currentLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationUpdated object:self];
        NSLog(@"Location updated: latitude %+.6f, longitude %+.6f\n", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        
        if (!_locationKnown) {
            NSLog(@"Location is now known");
            _locationKnown = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationKnown object:self];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.description);
    if ([self.delegate respondsToSelector:@selector(didFailUpdateLocationWithError:)]) {
        [self.delegate didFailUpdateLocationWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(didUpdateHeading:)]) {
        [self.delegate didUpdateHeading:newHeading];
    }
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

@end
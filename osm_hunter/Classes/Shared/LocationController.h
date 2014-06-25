//
//  LocationController.h
//  osm_hunter
//
//  Created by Andrew Teil on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol LocationControllerDelegate <NSObject>
@optional
- (void)didStartUpdatingLocation;
- (void)didStopUpdatingLocation;
- (void)didUpdateLocation:(CLLocation *)location;
- (void)didFailUpdateLocationWithError:(NSError *)error;
- (void)didUpdateHeading:(CLHeading *)newHeading;

@end


@interface  LocationController : NSObject <CLLocationManagerDelegate>

+ (LocationController *)sharedInstance;

-(void) start;
-(void) stop;
-(void) checkLocationServicesTurnedOn;
-(void) checkApplicationHasLocationServicesPermission;

@property (nonatomic, readonly) BOOL locationKnown;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, weak) id <LocationControllerDelegate> delegate;

@end

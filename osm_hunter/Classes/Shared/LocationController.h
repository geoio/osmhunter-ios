//
//  LocationController.h
//  NochOffen
//
//  Created by Andrew Teil on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol LocationControllerDelegate
@optional
- (void)didStartUpdatingLocation;
- (void)didStopUpdatingLocation;
- (void)didSuccessUpdatingLocation:(CLLocation *)location;
- (void)didFailureUpdatingLocation;

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

//
//  Building.h
//  osm_hunter
//
//  Created by Andrew Teil on 17/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Building : NSObject


@property(nonatomic) NSUInteger buildingId;
@property(nonatomic, copy) NSArray *shapeNodes;
@property(nonatomic) float distance;
@property(nonatomic) CLLocationCoordinate2D shapeCenter;
@property(nonatomic, strong) NSArray *attributes;


- (Building *)initWithDictionary:(NSDictionary *)dictionary;
- (void)loadAttributesFromDictionary:(NSDictionary *)dictionary;

@end

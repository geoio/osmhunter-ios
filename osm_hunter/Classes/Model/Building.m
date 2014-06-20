//
//  Building.m
//  osm_hunter
//
//  Created by Andrew Teil on 17/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import "Building.h"
#import "BuildingAttributeText.h"
#import "BuildingAttributeSelect.h"

@implementation Building

- (Building *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.buildingId = [dictionary[@"id"] unsignedIntegerValue];
        NSArray *nodes = dictionary[@"nodes"];
        NSMutableArray *shapeNodes = [NSMutableArray arrayWithCapacity:nodes.count];
        for (NSDictionary *item in nodes) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[item[@"lat"] doubleValue] longitude:[item[@"lon"] doubleValue]];
            [shapeNodes addObject:location];
        }
        self.shapeNodes = shapeNodes;
        self.distance = [dictionary[@"distance"] floatValue];
        self.shapeCenter = CLLocationCoordinate2DMake([dictionary[@"centroid"][@"lat"] doubleValue], [dictionary[@"centroid"][@"lon"] doubleValue]);    
    }
    
    return self;
}

- (void)loadAttributesFromDictionary:(NSDictionary *)dictionary {
    NSArray *attributes = dictionary[@"result"];
    NSMutableArray *buildingAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (NSDictionary *attribute in attributes) {
        NSString *type = attribute[@"type"];
        if ([type isEqualToString:@"text"]) {
            BuildingAttributeText *textAttribute = [[BuildingAttributeText alloc] initWithDictionary:attribute];
            [buildingAttributes addObject:textAttribute];
        } else if ([type isEqualToString:@"select"]) {
            BuildingAttributeSelect *selectAttribute = [[BuildingAttributeSelect alloc] initWithDictionary:attribute];
            [buildingAttributes addObject:selectAttribute];
        }
    }
    self.attributes = buildingAttributes;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ID: %lu. Shape nodes count: %lu", (unsigned long)self.buildingId, (unsigned long)self.shapeNodes.count];
}

@end

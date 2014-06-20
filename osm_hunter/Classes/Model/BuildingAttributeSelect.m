//
//  BuildingAttributeSelect.m
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "BuildingAttributeSelect.h"
#import "BuildingAttributeOption.h"

@implementation BuildingAttributeSelect

- (BuildingAttributeSelect *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    
    if (self) {
        NSArray *options = dictionary[@"options"];
        NSMutableArray *attributeOptions = [NSMutableArray arrayWithCapacity:options.count];
        for (NSDictionary *option in options) {
            BuildingAttributeOption *attributeOption = [[BuildingAttributeOption alloc] initWithDictionary:option];
            [attributeOptions addObject:attributeOption];
        }
        self.options = attributeOptions;
    }
    
    return self;
    
}

@end

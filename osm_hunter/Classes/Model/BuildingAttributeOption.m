//
//  BuildingAttributeOption.m
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "BuildingAttributeOption.h"

@implementation BuildingAttributeOption

- (BuildingAttributeOption *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.value = dictionary[@"value"];
        self.label = dictionary[@"label"];
    }
    
    return self;
    
}


@end

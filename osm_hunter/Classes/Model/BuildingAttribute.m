//
//  BuildingAttribute.m
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "BuildingAttribute.h"

@implementation BuildingAttribute

- (BuildingAttribute *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.name = dictionary[@"name"];
        self.value = [dictionary[@"value"] isEqual:[NSNull null]] ? @"" : dictionary[@"value"];
        self.label = dictionary[@"label"];
        self.prefilled = [dictionary[@"prefilled"] boolValue];
    }
    
    return self;
    
}

@end

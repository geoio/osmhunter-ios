//
//  BuildingAttributeSelect.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildingAttribute.h"

@interface BuildingAttributeSelect : BuildingAttribute

@property(nonatomic, copy) NSArray *options;

- (BuildingAttributeSelect *)initWithDictionary:(NSDictionary *)dictionary;

@end

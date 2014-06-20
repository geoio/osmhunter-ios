//
//  BuildingAttributeOption.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildingAttributeOption : NSObject

@property(nonatomic, copy) NSString *label;
@property(nonatomic, copy) NSString *value;

- (BuildingAttributeOption *)initWithDictionary:(NSDictionary *)dictionary;

@end

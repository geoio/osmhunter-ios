//
//  BuildingAttribute.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuildingAttribute : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *label;
@property(nonatomic, copy) NSString *value;
@property(nonatomic) BOOL prefilled;

- (BuildingAttribute *)initWithDictionary:(NSDictionary *)dictionary;

@end

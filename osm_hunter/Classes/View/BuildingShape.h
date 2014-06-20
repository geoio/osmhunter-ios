//
//  BuildingShape.h
//  osm_hunter
//
//  Created by Andrew Teil on 17/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "RMShape.h"
#import "Building.h"

@interface BuildingShape : RMShape

+ (BuildingShape *)shapeForBuilding:(Building *)building;

@end

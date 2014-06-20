//
//  BuildingShape.m
//  osm_hunter
//
//  Created by Andrew Teil on 17/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import "BuildingShape.h"

@implementation BuildingShape

+ (BuildingShape *)shapeForBuilding:(Building *)building {
    RMShape *shape = [[RMShape alloc] init];
    
    shape.lineColor = [UIColor purpleColor];
    shape.lineWidth = 5.0;
    
    for (CLLocation *point in building.shapeNodes)
        [shape addLineToCoordinate:point.coordinate];
    
    return (BuildingShape *)shape;
}

@end

//
//  BuildingAttributeTextCell.h
//  osm_hunter
//
//  Created by Andrew Teil on 19/06/14.
//  Copyright (c) 2014 happy-bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingAttributeTextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *attributeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *attributeTextField;

@end

//
//  UIImage+Rotate.h
//
//  Created by Genki Kondo on 10/6/12.
//  Copyright (c) 2012 Genki Kondo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Rotate)

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end

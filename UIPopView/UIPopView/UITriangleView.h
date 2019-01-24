//
//  UITriangleView.h
//  yzh
//
//  Created by captain on 16/5/4.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UITRIANGLE_VIEW_VERTEX_ANGLE_DIRECTION_IS_UP(DIR)  ((DIR) == UITriangleViewVertexAngleDirectionNull || (DIR) == UITriangleViewVertexAngleDirectionUp)

typedef NS_ENUM(NSInteger, UITriangleViewVertexAngleDirection)
{
    UITriangleViewVertexAngleDirectionNull      = 0,
    UITriangleViewVertexAngleDirectionUp       = 1,
    UITriangleViewVertexAngleDirectionLeft      = 2,
    UITriangleViewVertexAngleDirectionDown    = 3,
    UITriangleViewVertexAngleDirectionRight     = 4,
};

@interface UITriangleView : UIView

@property (nonatomic, copy) UIColor *color;

@property (nonatomic, assign) UITriangleViewVertexAngleDirection vertexAngleDirection;

+(UIBezierPath*)triangleBezierPathFromRect:(CGRect)rect withVertexAngleDirection:(UITriangleViewVertexAngleDirection)vertexAngleDirection;
@end

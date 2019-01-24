//
//  UITriangleView.m
//  yzh
//
//  Created by captain on 16/5/4.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UITriangleView.h"


@interface UITriangleView ()
@end


@implementation UITriangleView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

//    _path = CGPathCreateMutable();
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    
//    CGContextMoveToPoint(ctx, rect.origin.x + rect.size.width / 2, 0);
//    
//    CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
//
//    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    
    if (UITRIANGLE_VIEW_VERTEX_ANGLE_DIRECTION_IS_UP(self.vertexAngleDirection)) {
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), 0);
    
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    else if (self.vertexAngleDirection == UITriangleViewVertexAngleDirectionLeft)
    {
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    else if (self.vertexAngleDirection == UITriangleViewVertexAngleDirectionDown)
    {
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    }
    else if (self.vertexAngleDirection == UITriangleViewVertexAngleDirectionRight)
    {
        CGContextMoveToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
        
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }
    
    CGContextClosePath(ctx);
    
    CGContextFillPath(ctx);
    
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _color = CLEAR_COLOR;
        self.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _color = CLEAR_COLOR;
        self.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

+(UIBezierPath*)triangleBezierPathFromRect:(CGRect)rect withVertexAngleDirection:(UITriangleViewVertexAngleDirection)vertexAngleDirection
{
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    if (UITRIANGLE_VIEW_VERTEX_ANGLE_DIRECTION_IS_UP(vertexAngleDirection)) {
//        CGPoint vertexPoint = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y);
//        CGPoint leftBottomPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
//        CGPoint rightBottomPoint = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        
        CGPoint vertexPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint leftBottomPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGPoint rightBottomPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        
        [bezierPath moveToPoint:vertexPoint];
        [bezierPath addLineToPoint:leftBottomPoint];
        [bezierPath addLineToPoint:rightBottomPoint];
        [bezierPath closePath];
    }
    else if (vertexAngleDirection == UITriangleViewVertexAngleDirectionLeft)
    {
        CGPoint vertexPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGPoint upPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGPoint bottomPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        
        [bezierPath moveToPoint:vertexPoint];
        [bezierPath addLineToPoint:upPoint];
        [bezierPath addLineToPoint:bottomPoint];
        [bezierPath closePath];
    }
    else if (vertexAngleDirection == UITriangleViewVertexAngleDirectionDown)
    {
        CGPoint vertexPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        CGPoint leftPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint rightPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
        
        [bezierPath moveToPoint:vertexPoint];
        [bezierPath addLineToPoint:leftPoint];
        [bezierPath addLineToPoint:rightPoint];
        [bezierPath closePath];
    }
    else if (vertexAngleDirection == UITriangleViewVertexAngleDirectionRight)
    {
        CGPoint vertexPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
        CGPoint upPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint bottomPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        
        [bezierPath moveToPoint:vertexPoint];
        [bezierPath addLineToPoint:upPoint];
        [bezierPath addLineToPoint:bottomPoint];
        [bezierPath closePath];
    }

    
    return bezierPath;
}



@end

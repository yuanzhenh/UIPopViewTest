//
//  UIPopView.h
//  yzh
//
//  Created by captain on 16/5/4.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopViewCell.h"


typedef NS_ENUM(NSInteger, UIPopViewArrowDirection)
{
    UIPopViewArrowDirectionAny       = 0,
    UIPopViewArrowDirectionUp        = 1,
    UIPopViewArrowDirectionLeft      = 2,
    UIPopViewArrowDirectionDown      = 3,
    UIPopViewArrowDirectionRight     = 4,
};

@class UIPopView;

@protocol UIPopViewDelegate <NSObject>
-(CGFloat)popView:(UIPopView*)popView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)popView:(UIPopView*)popView didSelectedForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol UIPopViewDataSource <NSObject>
@required
-(NSInteger)numberOfRowsInPopView:(UIPopView*)popView;
-(void)popView:(UIPopView*)popView popViewCell:(UIPopViewCell*)popViewCell forRowAtIndexPath:(NSIndexPath*)indexPath;
@end


@interface UIPopView : UIView

@property (nonatomic, copy) UIColor *color;

@property (nonatomic, assign) UIPopViewArrowDirection arrowDirection;

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, weak) id<UIPopViewDelegate> delegate;
@property (nonatomic, weak) id<UIPopViewDataSource> dataSource;

//注意，设置等腰三角行（△）的宽高，如果呈现出来为UIPopViewArrowDirectionLeft和UIPopViewArrowDirectionRight的方式的话，width就是正放时的高，height就是正放时的宽，可以不用设置，系统自己有一套计算方法
@property (nonatomic, assign) CGSize triangleViewSize;
//这就是popView显示时距离屏幕最小的边距。可以不用设置，系统自己有一套计算方法
@property (nonatomic, assign) UIEdgeInsets popViewEdgeInsets;
//这里主要是这是popView的大小的宽度，高度会根据代理提供的行距重新计算，如果没有代理，则popOverVew有滚动效果。
@property (nonatomic, assign) CGSize popOverContentSize;
//这里主要是设置从那里开始
@property (nonatomic, assign) CGRect popOverRect;
//默认为YES
@property (nonatomic, assign) BOOL autoAdjustPopOverContentSize;
//分割线颜色
@property (nonatomic, strong) UIColor *separatorLineColor;

//就是上面up，left，down，right的nsnumber的顺序，默认顺序为up，left，down，right
@property (nonatomic, copy) NSArray *arrowDirectionPriorityOrder;

/** default is 5.0 */
@property (nonatomic, assign) CGFloat contentCornerRadius;

//使用此方法时，后面进行show的时候只能是[popview popViewFromOverView:(UIView*)overView showInView:(UIView*)showInView animated:(BOOL)animated];
-(id)initWithPopOverContentSize:(CGSize)popOverContentSize;
//后面进行show的时候三者均可以，但是popOverRect必须是相当于showInView的rect
-(id)initWithPopOverContentSize:(CGSize)popOverContentSize fromRect:(CGRect)popOverRect;
//后面进行show的时候三者均可以
-(id)initWithPopOverContentSize:(CGSize)popOverContentSize fromOverView:(UIView*)overView showInView:(UIView*)showInView;

-(void)popViewShow:(BOOL)animated;

-(void)popViewShowInView:(UIView*)showInView animated:(BOOL)animated;

-(void)popViewFromOverView:(UIView*)overView showInView:(UIView*)showInView animated:(BOOL)animated;


@end

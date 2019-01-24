//
//  UIPopView.m
//  yzh
//
//  Created by captain on 16/5/4.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UIPopView.h"
#import "UITriangleView.h"
#import "UIPopViewCell.h"

static const float popOverViewLeftRightMinOffsetWithScreenWidthRatio = 0.02;
static const float popOverViewTopBottomMinOffsetWithScreenHeightRatio = 0.03;

static const float triangleViewWidthWithBaseWidthRatio = 0.16;//0.16;
static const float triangleViewHeightWithBaseHeightRatio = 0.058;//0.056;//0.06;

static const float triangleViewWidthWithHeightMinRatio = 1.6;
static const float triangleViewWidthWithHeightMaxRatio = 4.0;

static const float tableViewEdgeLineWidth = 0.5;

static const float popViewWithPopoverViewSpace = 1.0;
static const float popViewDirectionFullScore = 100.0;
static const float popViewArrowDirectionScore = 80.0;
static const float popViewAdjustContentSizeMinusScore = 10.0;
static const float popViewContentOverLeftRightSpaceMinusSore = 10.0;

static const NSInteger popViewAutdoAdjustContentSizeMinTableViewRowCount = 3;

static const NSTimeInterval animationTimeInterval = 0.2;

//-------------------------UIPopViewArrowDirectionScoreContext-------------------------
@interface UIPopViewArrowDirectionScoreContext : NSObject

//分数，按分数先排布
@property (nonatomic, assign) CGFloat score;
@property (nonatomic, assign) UIPopViewArrowDirection arrowDirection;
//分数一样时，按大小
@property (nonatomic, assign) CGSize popOverContentSize;
//分数一样时，大小也一样时，按三角形要移动的多少来排（也就是美观）
@property (nonatomic, assign) CGFloat triangleViewOffsetRatio;

@end

@implementation UIPopViewArrowDirectionScoreContext

-(NSString*)description
{
    return [NSString stringWithFormat:@"score=%f,arrowDirection=%ld,popOverContentSize=(%f,%f),ratio=%f",_score,(long)_arrowDirection,_popOverContentSize.width,_popOverContentSize.height,_triangleViewOffsetRatio];
}

@end

//------------------------UIPopView------------------------
@interface UIPopView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton *cover;

@property (nonatomic, strong) UIView *popContentView;
@property (nonatomic, strong) UITriangleView *triangleView;
//@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIVisualEffect *effect;
@property (nonatomic, strong) UIVisualEffectView *triangleEffectView;
@property (nonatomic, strong) UIVisualEffectView *tableEffectView;

@property (nonatomic, strong) NSMutableDictionary *rowsDicts;

@property (nonatomic, assign) CGFloat triangleViewHeightWithContentViewHeightRatio;

@property (nonatomic, assign) UIPopViewArrowDirection showArrowDirection;

@property (nonatomic, weak) UIView *showInView;

@property (nonatomic, assign) BOOL haveCustomPopViewEdgeInsets;
@property (nonatomic, assign) CGFloat tableViewSeparatorLineHeight;

@end


@implementation UIPopView

@synthesize triangleViewSize = _triangleViewSize;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
    }
    return self;
}

-(void)_setupDefaultValue
{
    _color = WHITE_COLOR;
    self.separatorLineColor = LIGHT_GRAY_COLOR;
    self.autoAdjustPopOverContentSize = YES;
    self.tableViewSeparatorLineHeight = 1.0;//1 / SCREEN_SCALE;
    self.arrowDirection = UIPopViewArrowDirectionAny;
    self.contentCornerRadius = 5.0;
    [self _initTriangleViewSize];
    [self _initPopViewScreenEdgeInsets];
    [self _initArrowDirectionPriorityOrder];
}

-(void)_setuplayoutValue
{
    [self _initPopViewScreenEdgeInsets];
    [self _setupCover];
    [self _setupPopView];
}

-(id)initWithPopOverContentSize:(CGSize)popOverContentSize
{
    self = [self init];
    if (self) {
        self.popOverContentSize = popOverContentSize;
    }
    return self;
}

-(id)initWithPopOverContentSize:(CGSize)popOverContentSize fromRect:(CGRect)popOverRect
{
    self = [self init];
    if (self) {
        self.popOverRect = popOverRect;
        self.popOverContentSize = popOverContentSize;
    }
    
    return self;
}

-(id)initWithPopOverContentSize:(CGSize)popOverContentSize fromOverView:(UIView*)overView showInView:(UIView*)showInView
{
    CGRect overRect = [overView.superview convertRect:overView.frame toView:showInView];
    self = [self initWithPopOverContentSize:popOverContentSize fromRect:overRect];
    if (self) {
        self.showInView = showInView;
    }
    return self;
}

-(UIVisualEffect*)effect
{
    if (_effect==nil) {
        _effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    return _effect;
}

-(void)_initTriangleViewSize
{
    CGFloat triangleViewWidth = self.popOverContentSize.width * triangleViewWidthWithBaseWidthRatio;
    CGFloat triangleViewHeight = self.popOverContentSize.height * triangleViewHeightWithBaseHeightRatio;
    _triangleViewHeightWithContentViewHeightRatio = triangleViewHeightWithBaseHeightRatio;
    _triangleViewSize = CGSizeMake(triangleViewWidth, triangleViewHeight);
}

-(void)_initPopViewScreenEdgeInsets
{
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = SCREEN_HEIGHT;
    if (self.showInView) {
        width = self.showInView.bounds.size.width;
        height = self.showInView.bounds.size.height;
    }
    if (self.haveCustomPopViewEdgeInsets) {
        return;
    }
    
    CGFloat leftRightOffset = width * popOverViewLeftRightMinOffsetWithScreenWidthRatio;
    CGFloat topBottomOffset = height * popOverViewTopBottomMinOffsetWithScreenHeightRatio;
    CGFloat offset = MIN(leftRightOffset, topBottomOffset);
//    _popViewEdgeInsets = UIEdgeInsetsMake(topBottomOffset, leftRightOffset, topBottomOffset, leftRightOffset);
    _popViewEdgeInsets = UIEdgeInsetsMake(offset, offset, offset, offset);
}

-(void)_initArrowDirectionPriorityOrder
{
    NSNumber *up = [NSNumber numberWithInteger:UIPopViewArrowDirectionUp];
    NSNumber *left = [NSNumber numberWithInteger:UIPopViewArrowDirectionLeft];
    NSNumber *down = [NSNumber numberWithInteger:UIPopViewArrowDirectionDown];
    NSNumber *right = [NSNumber numberWithInteger:UIPopViewArrowDirectionRight];
    self.arrowDirectionPriorityOrder = @[up,left,down,right];
}

-(void)setPopViewEdgeInsets:(UIEdgeInsets)popViewEdgeInsets
{
    _popViewEdgeInsets = popViewEdgeInsets;
    if (popViewEdgeInsets.top < 0 || popViewEdgeInsets.left < 0 || popViewEdgeInsets.bottom < 0 || popViewEdgeInsets.right < 0) {
        _haveCustomPopViewEdgeInsets = NO;
    }
    else {
        _haveCustomPopViewEdgeInsets = YES;
    }
}

-(void)setTriangleViewSize:(CGSize)triangleViewSize
{
    _triangleViewSize = triangleViewSize;
    self.triangleViewHeightWithContentViewHeightRatio = 1.0;
}

-(CGSize)triangleViewSize
{
    if (self.triangleViewHeightWithContentViewHeightRatio >= 1.0) {
        return _triangleViewSize;
    }
    else
    {
        self.triangleViewHeightWithContentViewHeightRatio = MAX(0, [self _getLastNewTriangleViewHeightRatioWithPopOverContentSize:self.popOverContentSize]);
        if (self.triangleViewHeightWithContentViewHeightRatio >= 1.0) {
            return _triangleViewSize;
        }
        else
        {
            CGFloat triangleViewWidth = triangleViewWidthWithBaseWidthRatio * self.popOverContentSize.width;
            CGFloat triangleViewHeight = self.triangleViewHeightWithContentViewHeightRatio * self.popOverContentSize.height;
            CGFloat triangleViewWidthWithHeightRatio = triangleViewWidth/triangleViewHeight;
            //        NSLog(@"ratio=%f",triangleViewWidthWithHeightRatio);
            if (triangleViewWidthWithHeightRatio > triangleViewWidthWithHeightMaxRatio)
            {
                triangleViewWidth = triangleViewWidthWithHeightMaxRatio * triangleViewHeight;
            }
            return CGSizeMake(triangleViewWidth, triangleViewHeight);
        }
    }
}

-(CGFloat)_getLastNewTriangleViewHeightRatioWithPopOverContentSize:(CGSize)contentSize
{
    CGFloat triangleViewHeightWithBaseHeightRatioTmp = MAX(0, self.triangleViewHeightWithContentViewHeightRatio);
    
    CGFloat triangleViewWidth = triangleViewWidthWithBaseWidthRatio * contentSize.width;
    CGFloat triangleViewHeight = triangleViewHeightWithBaseHeightRatioTmp * contentSize.height;
    CGFloat triangleViewWidthWithHeightRatio = triangleViewWidth/triangleViewHeight;
    
    if (triangleViewWidthWithHeightRatio < triangleViewWidthWithHeightMinRatio) {
        triangleViewHeight = triangleViewWidth / triangleViewWidthWithHeightMinRatio;
        [self setTriangleViewSize:CGSizeMake(triangleViewWidth, triangleViewHeight)];
        triangleViewHeightWithBaseHeightRatioTmp = self.triangleViewHeightWithContentViewHeightRatio;
    }
    return triangleViewHeightWithBaseHeightRatioTmp;
}

-(UIButton*)cover
{
    if (_cover == nil) {
        _cover = [UIButton buttonWithType:UIButtonTypeCustom];
        _cover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cover.backgroundColor = BLACK_COLOR;
        _cover.alpha = 0.1;
        [_cover addTarget:self action:@selector(_coverClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}

-(void)_setupCover
{
    CGRect frame = SCREEN_BOUNDS;
    if (self.showInView) {
        frame = self.showInView.bounds;
    }
    self.cover.frame = frame;
    [self.showInView insertSubview:self.cover belowSubview:self];}

-(void)_setupPopView
{
    UIView *popContentView = [[UIView alloc] init];//[[UIView alloc] initWithFrame:self.initFrame];
    popContentView.backgroundColor = CLEAR_COLOR;
    popContentView.clipsToBounds = YES;
    [self addSubview:popContentView];
    self.popContentView = popContentView;
    
    CGFloat alpha = 0.9;
    //3.创建毛玻璃效果图
    self.triangleEffectView = [[UIVisualEffectView alloc] initWithEffect:self.effect];
    self.triangleEffectView.alpha = alpha;
    self.triangleEffectView.clipsToBounds = YES;
    [self.popContentView addSubview:self.triangleEffectView];
    
    //4.创建三角形View
    self.triangleView = [[UITriangleView alloc] init];
    [self.triangleView setColor:self.color];
    [self.triangleEffectView.contentView addSubview:self.triangleView];
    
    //1.创建毛玻璃效果图
    self.tableEffectView = [[UIVisualEffectView alloc] initWithEffect:self.effect];
    self.tableEffectView.alpha = alpha;
    self.tableEffectView.clipsToBounds = YES;
    self.tableEffectView.layer.cornerRadius = self.contentCornerRadius;
    [self.popContentView addSubview:self.tableEffectView];
    
    //2.再毛玻璃效果图上添加tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.bounces = NO;
    tableView.backgroundColor = self.color;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _tableView = tableView;
    [self.tableEffectView.contentView addSubview:tableView];
    
    [self.tableView registerClass:[UIPopViewCell class] forCellReuseIdentifier:NSStringFromClass([UIPopViewCell class])];
}

-(CGFloat)_getContentSizeHeightFromTableViewHeight:(CGFloat)tableViewHeight
{
    CGFloat contentSizeHeight = tableViewHeight;
    if (self.triangleViewHeightWithContentViewHeightRatio >= 1.0) {
        contentSizeHeight += self.triangleViewSize.height;
    }
    else
    {
        CGFloat triangleViewHeithRatio = MAX(0, self.triangleViewHeightWithContentViewHeightRatio);
        contentSizeHeight = tableViewHeight / ( 1 - triangleViewHeithRatio);
    }
    return contentSizeHeight;
}

//返回<=0表示不能够显示
-(CGFloat)_getShowContentSizeHeightForMaxTableViewHeight:(CGFloat)tableViewHeight
{
    CGFloat totalHeight = 0;
    NSInteger index = 0;
    for (index = 0; index < self.rowsDicts.count; ++index) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CGFloat RowHeight = [self.delegate popView:self heightForRowAtIndexPath:indexPath];
        if (totalHeight + RowHeight >= tableViewHeight) {
            break;
        }
        totalHeight += RowHeight;
    }
    if (index < popViewAutdoAdjustContentSizeMinTableViewRowCount) {
        totalHeight = tableViewHeight;
    }
    else {
//        totalHeight -= SINGLE_LINE_WIDTH;
    }

    return [self _getContentSizeHeightFromTableViewHeight:totalHeight];
}

-(UIPopViewArrowDirectionScoreContext*)_getPopViewArrowDirectionUpScore:(CGSize)popOverContentSize withPopOverRect:(CGRect)popOverRect
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    
    UIPopViewArrowDirectionScoreContext *ctx = [[UIPopViewArrowDirectionScoreContext alloc] init];
    
    CGFloat score = 0;
    
    CGFloat offsetY = CGRectGetMaxY(popOverRect) + popViewWithPopoverViewSpace;
    CGFloat offsetMaxY = offsetY + popOverContentSize.height;
    
    CGFloat triangleViewMinX = self.popViewEdgeInsets.left + self.contentCornerRadius + self.triangleViewSize.width/2;
    CGFloat triangleViewMaxX = showInWidth - (self.popViewEdgeInsets.right + self.contentCornerRadius + self.triangleViewSize.width/2);
    
    CGFloat triangleViewLeftRightScore = (popViewDirectionFullScore - popViewArrowDirectionScore)/2;

    
    if ((offsetMaxY <= showInHeight - self.popViewEdgeInsets.bottom) || (offsetMaxY > showInHeight - self.popViewEdgeInsets.bottom && offsetMaxY < showInHeight)) {
        score = popViewArrowDirectionScore;
        if ((offsetMaxY > showInHeight - self.popViewEdgeInsets.bottom && offsetMaxY < showInHeight))
        {
            score -= popViewContentOverLeftRightSpaceMinusSore;
        }
        if (triangleViewMinX <= CGRectGetMaxX(popOverRect)) {
            score += triangleViewLeftRightScore;
        }
        if (triangleViewMaxX >= CGRectGetMinX(popOverRect)) {
            score += triangleViewLeftRightScore;
        }
    }
    else
    {
        if (self.autoAdjustPopOverContentSize) {
            CGFloat maxHeight = showInHeight - self.popViewEdgeInsets.bottom - offsetY - self.triangleViewSize.height;
            CGFloat contentSizeHeight = [self _getShowContentSizeHeightForMaxTableViewHeight:maxHeight];
            if (contentSizeHeight > 0) {
                score = popViewArrowDirectionScore - popViewAdjustContentSizeMinusScore;
                if (triangleViewMinX <= CGRectGetMaxX(popOverRect)) {
                    score += triangleViewLeftRightScore;
                }
                if (triangleViewMaxX >= CGRectGetMinX(popOverRect)) {
                    score += triangleViewLeftRightScore;
                }
                popOverContentSize.height = contentSizeHeight;
            }
            else
            {
                score = 0;
                popOverContentSize.height = 0;
            }

        }
        else
        {
            score = 0;
            popOverContentSize.height = 0;
        }
    }
    ctx.score = score;
    ctx.arrowDirection = UIPopViewArrowDirectionUp;
    ctx.popOverContentSize = popOverContentSize;
    ctx.triangleViewOffsetRatio = [self _getTriangleViewadjustShiftOffsetRatioForArrowDirection:ctx.arrowDirection withPopOverContentSize:ctx.popOverContentSize];
    return ctx;
}

-(UIPopViewArrowDirectionScoreContext*)_getPopViewArrowDirectionLeftScore:(CGSize)popOverContentSize withPopOverRect:(CGRect)popOverRect
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    
    UIPopViewArrowDirectionScoreContext *ctx = [[UIPopViewArrowDirectionScoreContext alloc] init];
    CGFloat score = 0;
    
    CGFloat offsetX = CGRectGetMaxX(popOverRect) + popViewWithPopoverViewSpace;
    CGFloat offsetMax = offsetX + popOverContentSize.width;
    
    CGFloat triangleViewMinY = self.popViewEdgeInsets.top + self.contentCornerRadius + self.triangleViewSize.width/2;
    CGFloat triangleViewMaxY = showInHeight - (self.popViewEdgeInsets.bottom + self.contentCornerRadius + self.triangleViewSize.width/2);
    
    CGFloat triangleViewUpDownScore = (popViewDirectionFullScore - popViewArrowDirectionScore)/2;
    
    if ((offsetMax <= showInWidth - self.popViewEdgeInsets.right) || (offsetMax > showInWidth - self.popViewEdgeInsets.left && offsetMax < showInWidth)) {
        score = popViewArrowDirectionScore;
        if (offsetMax > showInWidth - self.popViewEdgeInsets.left && offsetMax < showInWidth) {
            score -= popViewContentOverLeftRightSpaceMinusSore;
        }
        if (triangleViewMinY <= CGRectGetMaxY(popOverRect)) {
            score += triangleViewUpDownScore;
        }
        if (triangleViewMaxY >= CGRectGetMinY(popOverRect)) {
            score += triangleViewUpDownScore;
        }
        
        CGFloat maxHeight = showInHeight - self.popViewEdgeInsets.top - self.popViewEdgeInsets.bottom;
        if (self.autoAdjustPopOverContentSize) {
            if (maxHeight < popOverContentSize.height)
            {
                popOverContentSize.height = maxHeight;
                score -= popViewAdjustContentSizeMinusScore;
            }
        }
        else
        {
            CGFloat avageSpace = (self.popViewEdgeInsets.top + self.popViewEdgeInsets.bottom)/2;
            if (popOverContentSize.height > showInHeight) {
                popOverContentSize.height = 0;
                score = 0;
            }
            else if (popOverContentSize.height > (showInHeight - (self.popViewEdgeInsets.top + self.popViewEdgeInsets.bottom)) && popOverContentSize.height <= showInHeight - avageSpace)
            {
                score -= popViewContentOverLeftRightSpaceMinusSore;
            }
            else if (popOverContentSize.height > showInHeight - avageSpace  && popOverContentSize.height <=showInHeight)
            {
                score -= 2 * popViewContentOverLeftRightSpaceMinusSore;
            }
        }
        
    }
    else
    {
        score = 0;
    }
    ctx.score = score;
    ctx.arrowDirection = UIPopViewArrowDirectionLeft;
    ctx.popOverContentSize = popOverContentSize;
    ctx.triangleViewOffsetRatio = [self _getTriangleViewadjustShiftOffsetRatioForArrowDirection:ctx.arrowDirection withPopOverContentSize:ctx.popOverContentSize];
    return ctx;
}

-(UIPopViewArrowDirectionScoreContext*)_getPopViewArrowDirectionDownScore:(CGSize)popOverContentSize withPopOverRect:(CGRect)popOverRect
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    
    UIPopViewArrowDirectionScoreContext *ctx = [[UIPopViewArrowDirectionScoreContext alloc] init];

    CGFloat score = 0;
    
    CGFloat offsetY = CGRectGetMinY(popOverRect) - popViewWithPopoverViewSpace;
    CGFloat offsetMinY = offsetY - popOverContentSize.height;
    
    CGFloat triangleViewMinX = self.popViewEdgeInsets.left + self.contentCornerRadius + self.triangleViewSize.width/2;
    CGFloat triangleViewMaxX = showInWidth -(self.popViewEdgeInsets.right + self.contentCornerRadius + self.triangleViewSize.width/2);
    
    CGFloat triangleViewLeftRightScore = (popViewDirectionFullScore - popViewArrowDirectionScore)/2;
    
    if (offsetMinY >= self.popViewEdgeInsets.top || (offsetMinY > 0 && offsetMinY < self.popViewEdgeInsets.top)) {
        score = popViewArrowDirectionScore;
        if ((offsetMinY > 0 && offsetMinY < self.popViewEdgeInsets.top)) {
            score -= popViewContentOverLeftRightSpaceMinusSore;
        }
        if (triangleViewMinX <= CGRectGetMaxX(popOverRect)) {
            score += triangleViewLeftRightScore;
        }
        if (triangleViewMaxX >= CGRectGetMinX(popOverRect)) {
            score += triangleViewLeftRightScore;
        }
    }
    else
    {
        if (self.autoAdjustPopOverContentSize) {
            CGFloat maxHeight = offsetY - self.popViewEdgeInsets.top - self.triangleViewSize.height;
            CGFloat contentSizeHeight = [self _getShowContentSizeHeightForMaxTableViewHeight:maxHeight];
            if (contentSizeHeight > 0) {
                score = popViewArrowDirectionScore - popViewAdjustContentSizeMinusScore;
                if (triangleViewMinX <= CGRectGetMaxX(popOverRect)) {
                    score += triangleViewLeftRightScore;
                }
                if (triangleViewMaxX >= CGRectGetMinX(popOverRect)) {
                    score += triangleViewLeftRightScore;
                }
                popOverContentSize.height = contentSizeHeight;

            }
            else
            {
                score = 0;
                popOverContentSize.height = 0;
            }
        }
        else
        {
            score = 0;
            popOverContentSize.height = 0;
        }
    }
    ctx.score = score;
    ctx.arrowDirection = UIPopViewArrowDirectionDown;
    ctx.popOverContentSize = popOverContentSize;
    ctx.triangleViewOffsetRatio = [self _getTriangleViewadjustShiftOffsetRatioForArrowDirection:ctx.arrowDirection withPopOverContentSize:ctx.popOverContentSize];
    return ctx;
}

-(UIPopViewArrowDirectionScoreContext*)_getPopViewArrowDirectionRightScore:(CGSize)popOverContentSize withPopOverRect:(CGRect)popOverRect
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    
    UIPopViewArrowDirectionScoreContext *ctx = [[UIPopViewArrowDirectionScoreContext alloc] init];

    CGFloat score = 0;
    
    CGFloat offsetX = CGRectGetMinX(popOverRect) - popViewWithPopoverViewSpace;
    CGFloat offsetMinx = offsetX - popOverContentSize.width;
    
    CGFloat triangleViewMinY = self.popViewEdgeInsets.top + self.contentCornerRadius + self.triangleViewSize.width/2;
    CGFloat triangleViewMaxY = showInHeight - (self.popViewEdgeInsets.bottom + self.contentCornerRadius + self.triangleViewSize.width/2);
    
    CGFloat triangleViewUpDownScore = (popViewDirectionFullScore - popViewArrowDirectionScore)/2;
    
    if ((offsetMinx >= self.popViewEdgeInsets.left) || (offsetMinx > 0 && offsetMinx < self.popViewEdgeInsets.left)) {
        score = popViewArrowDirectionScore;
        if (offsetMinx > 0 && offsetMinx < self.popViewEdgeInsets.left) {
            score = popViewArrowDirectionScore - popViewContentOverLeftRightSpaceMinusSore;
        }
        
        if (triangleViewMinY <= CGRectGetMaxY(popOverRect)) {
            score += triangleViewUpDownScore;
        }
        if (triangleViewMaxY >= CGRectGetMinY(popOverRect)) {
            score += triangleViewUpDownScore;
        }
        
        CGFloat maxHeight = showInHeight - self.popViewEdgeInsets.top - self.popViewEdgeInsets.bottom;
        if (self.autoAdjustPopOverContentSize) {
            //可以容下的时候不改变分数
            if (maxHeight < popOverContentSize.height)
            {
                popOverContentSize.height = maxHeight;
                score -= popViewAdjustContentSizeMinusScore;
            }
        }
        else
        {
            CGFloat avageSpace = (self.popViewEdgeInsets.top + self.popViewEdgeInsets.bottom)/2;
            if (popOverContentSize.height > showInHeight) {
                score = 0;
                popOverContentSize.height = 0;
            }
            else if (popOverContentSize.height > (showInHeight - (self.popViewEdgeInsets.top + self.popViewEdgeInsets.bottom)) && popOverContentSize.height <= showInHeight - avageSpace)
            {
                score -= popViewContentOverLeftRightSpaceMinusSore;
            }
            else if (popOverContentSize.height > showInHeight - avageSpace  && popOverContentSize.height <=showInHeight)
            {
                score -= 2 * popViewContentOverLeftRightSpaceMinusSore;
            }
        }
    }
    else
    {
        score = 0;
    }
    
    ctx.score = score;
    ctx.arrowDirection = UIPopViewArrowDirectionRight;
    ctx.popOverContentSize = popOverContentSize;
    ctx.triangleViewOffsetRatio = [self _getTriangleViewadjustShiftOffsetRatioForArrowDirection:ctx.arrowDirection withPopOverContentSize:ctx.popOverContentSize];
    return ctx;
}

-(UIPopViewArrowDirectionScoreContext*)_getPopViewDirectionFromPopViewArrowDirection:(UIPopViewArrowDirection)arrowDirection
{
    if (arrowDirection == UIPopViewArrowDirectionAny) {
        
        CGSize popOverContentSizeTmp = self.popOverContentSize;
        popOverContentSizeTmp.height = self.popOverContentSize.height - self.triangleViewSize.height;
        UIPopViewArrowDirectionScoreContext *ctxMax = nil;
        NSLog(@"\nstart--popOverRect=%@",NSStringFromCGRect(self.popOverRect));
        for (NSInteger i = 0; i < self.arrowDirectionPriorityOrder.count; ++i) {
            UIPopViewArrowDirectionScoreContext *ctx = nil;
            if ([self.arrowDirectionPriorityOrder[i] integerValue] == UIPopViewArrowDirectionUp) {
                ctx = [self _getPopViewArrowDirectionUpScore:self.popOverContentSize withPopOverRect:self.popOverRect];
                NSLog(@"ctx=%@",ctx);
                if (ctx.score >= popViewDirectionFullScore) {
                    if (ctx.triangleViewOffsetRatio == 0) {
                        return ctx;
                    }
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    //这里分数为满分，说明已经是最大高度了。
                    else if (ctx.score == ctxMax.score && (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio))
                    {
                        ctxMax = ctx;
                    }
                }
                else
                {
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && ctx.popOverContentSize.height >= ctxMax.popOverContentSize.height)
                    {
                        if (ctx.popOverContentSize.height == ctxMax.popOverContentSize.height) {
                            if (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio) {
                                ctxMax = ctx;
                            }
                        }
                        else
                        {
                            ctxMax = ctx;
                        }
                    }
                }
            }
            else if ([self.arrowDirectionPriorityOrder[i] integerValue] == UIPopViewArrowDirectionLeft)
            {
                ctx = [self _getPopViewArrowDirectionLeftScore:popOverContentSizeTmp withPopOverRect:self.popOverRect];
                NSLog(@"ctx=%@",ctx);
                if (ctx.score >= popViewDirectionFullScore) {
                    if (ctx.triangleViewOffsetRatio == 0) {
                        return ctx;
                    }
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio))
                    {
                        ctxMax = ctx;
                    }
                }
                else
                {
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && ctx.popOverContentSize.height >= ctxMax.popOverContentSize.height)
                    {
                        if (ctx.popOverContentSize.height == ctxMax.popOverContentSize.height) {
                            if (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio) {
                                ctxMax = ctx;
                            }
                        }
                        else
                        {
                            ctxMax = ctx;
                        }
                    }
                }
            }
            else if ([self.arrowDirectionPriorityOrder[i] integerValue] == UIPopViewArrowDirectionDown)
            {
                ctx = [self _getPopViewArrowDirectionDownScore:self.popOverContentSize withPopOverRect:self.popOverRect];
                NSLog(@"ctx=%@",ctx);
                if (ctx.score >= popViewDirectionFullScore) {
                    if (ctx.triangleViewOffsetRatio == 0) {
                        return ctx;
                    }
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio))
                    {
                        ctxMax = ctx;
                    }
                }
                else
                {
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && ctx.popOverContentSize.height >= ctxMax.popOverContentSize.height)
                    {
                        if (ctx.popOverContentSize.height == ctxMax.popOverContentSize.height) {
                            if (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio) {
                                ctxMax = ctx;
                            }
                        }
                        else
                        {
                            ctxMax = ctx;
                        }
                    }
                }
            }
            else if ([self.arrowDirectionPriorityOrder[i] integerValue] == UIPopViewArrowDirectionRight)
            {
                ctx = [self _getPopViewArrowDirectionRightScore:popOverContentSizeTmp withPopOverRect:self.popOverRect];
                NSLog(@"ctx=%@",ctx);
                if (ctx.score >= popViewDirectionFullScore) {
                    if (ctx.triangleViewOffsetRatio == 0) {
                        return ctx;
                    }
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio))
                    {
                        ctxMax = ctx;
                    }
                }
                else
                {
                    if (ctxMax == nil) {
                        ctxMax = ctx;
                    }
                    else if (ctx.score > ctxMax.score)
                    {
                        ctxMax = ctx;
                    }
                    else if (ctx.score == ctxMax.score && ctx.popOverContentSize.height >= ctxMax.popOverContentSize.height)
                    {
                        if (ctx.popOverContentSize.height == ctxMax.popOverContentSize.height) {
                            if (ctx.triangleViewOffsetRatio > 0 && ctx.triangleViewOffsetRatio < ctxMax.triangleViewOffsetRatio) {
                                ctxMax = ctx;
                            }
                        }
                        else
                        {
                            ctxMax = ctx;
                        }
                    }
                }
            }
        }
        NSLog(@"ctxMax=%@",ctxMax);
        return ctxMax;
    }
    UIPopViewArrowDirectionScoreContext *ctx = [[UIPopViewArrowDirectionScoreContext alloc] init];
    ctx.score = popViewDirectionFullScore;
    ctx.arrowDirection = arrowDirection;
    ctx.popOverContentSize = self.popOverContentSize;
    ctx.triangleViewOffsetRatio = 0;
    return ctx;
}

-(CGFloat)_getTriangleViewadjustShiftOffsetRatioForArrowDirection:(UIPopViewArrowDirection)arrowDirection withPopOverContentSize:(CGSize)popOverContentSize
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    
    if (arrowDirection == UIPopViewArrowDirectionAny) {
        return -1.0;
    }
    if (arrowDirection == UIPopViewArrowDirectionUp || arrowDirection == UIPopViewArrowDirectionDown) {
        CGFloat popOverMidX = CGRectGetMidX(self.popOverRect);
        CGFloat popViewW = popOverContentSize.width;
        if (popOverMidX + popViewW / 2 <= showInWidth - self.popViewEdgeInsets.right  && popOverMidX - popViewW / 2 >= self.popViewEdgeInsets.left) {
            return 0;
        }
        else if (popOverMidX + popViewW /2 > showInWidth - self.popViewEdgeInsets.right)
        {
            CGFloat diffX = popOverMidX + popViewW/2 - (showInWidth - self.popViewEdgeInsets.right);
            return diffX/popOverContentSize.width;
        }
        else if (popOverMidX - popViewW / 2 < self.popViewEdgeInsets.left)
        {
            CGFloat diffX = self.popViewEdgeInsets.left - (popOverMidX - popViewW/2);
            return diffX/popOverContentSize.width;
        }
    }
    else if (arrowDirection == UIPopViewArrowDirectionLeft || arrowDirection == UIPopViewArrowDirectionRight)
    {
        CGFloat popOverMidY = CGRectGetMidY(self.popOverRect);
        
        CGFloat popViewH = popOverContentSize.height;
        CGFloat maxShowContentSizeHeight = showInHeight - self.popViewEdgeInsets.top - self.popViewEdgeInsets.bottom;
        if (popViewH <= maxShowContentSizeHeight)
        {
            if (popOverMidY + popViewH / 2 <= showInHeight - self.popViewEdgeInsets.bottom  && popOverMidY - popViewH / 2 >= self.popViewEdgeInsets.top) {
                return 0;
            }
            else if (popOverMidY + popViewH /2 > showInHeight - self.popViewEdgeInsets.bottom)
            {
                CGFloat diffY = popOverMidY + popViewH/2 - (showInHeight - self.popViewEdgeInsets.bottom);
                return diffY/popOverContentSize.height;
            }
            else if (popOverMidY - popViewH / 2 < self.popViewEdgeInsets.top)
            {
                CGFloat diffY = self.popViewEdgeInsets.top - (popOverMidY - popViewH / 2);
                return diffY/popOverContentSize.height;
            }
        }
        else
        {
            //按最大显示时，美观为次要的，所以返回0
            return 0;
        }
    }
    return -1;
}

-(void)_adjustPopOverViewFrameForArrowDirection:(UIPopViewArrowDirection)arrowDirection
{
    CGFloat showInWidth = SCREEN_WIDTH;
    CGFloat showInHeight = SCREEN_HEIGHT;
    if (self.showInView) {
        showInWidth = self.showInView.bounds.size.width;
        showInHeight = self.showInView.bounds.size.height;
    }
    if (arrowDirection == UIPopViewArrowDirectionAny) {
        return;
    }
    CGRect frame = CGRectZero;
    if (arrowDirection == UIPopViewArrowDirectionUp || arrowDirection == UIPopViewArrowDirectionDown) {
        CGFloat popOverMidX = CGRectGetMidX(self.popOverRect);
        CGFloat popOverMaxY = CGRectGetMaxY(self.popOverRect) + popViewWithPopoverViewSpace;
        if (arrowDirection == UIPopViewArrowDirectionDown) {
            popOverMaxY = CGRectGetMinY(self.popOverRect) - self.popOverContentSize.height - popViewWithPopoverViewSpace;
        }
        CGFloat popViewW = self.popOverContentSize.width;
        if (popOverMidX + popViewW / 2 <= showInWidth - self.popViewEdgeInsets.right  && popOverMidX - popViewW / 2 >= self.popViewEdgeInsets.left) {
            frame = CGRectMake(popOverMidX - popViewW/2, popOverMaxY, self.popOverContentSize.width, self.popOverContentSize.height);
        }
        else if (popOverMidX + popViewW /2 > showInWidth - self.popViewEdgeInsets.right)
        {
            frame = CGRectMake(showInWidth - self.popViewEdgeInsets.right - self.popOverContentSize.width, popOverMaxY, self.popOverContentSize.width, self.popOverContentSize.height);
            CGFloat diffX = popOverMidX + popViewW/2 - CGRectGetMaxX(frame);
            CGRect oldTriangleFrame = self.triangleEffectView.frame;
            oldTriangleFrame.origin.x += diffX;
            if (oldTriangleFrame.origin.x > self.popOverContentSize.width - self.contentCornerRadius - oldTriangleFrame.size.width) {
                oldTriangleFrame.origin.x = self.popOverContentSize.width - self.contentCornerRadius - oldTriangleFrame.size.width;
            }
            self.triangleEffectView.frame = oldTriangleFrame;
        }
        else if (popOverMidX - popViewW / 2 < self.popViewEdgeInsets.left)
        {
            frame = CGRectMake(self.popViewEdgeInsets.left, popOverMaxY, self.popOverContentSize.width, self.popOverContentSize.height);
            
            CGFloat diffX = CGRectGetMinX(frame) - (popOverMidX - popViewW/2);
            CGRect oldTriangleFrame = self.triangleEffectView.frame;
            oldTriangleFrame.origin.x -= diffX;
            if (oldTriangleFrame.origin.x < self.contentCornerRadius) {
                oldTriangleFrame.origin.x = self.contentCornerRadius;
            }
            self.triangleEffectView.frame = oldTriangleFrame;
        }
    }
    else if (arrowDirection == UIPopViewArrowDirectionLeft || arrowDirection == UIPopViewArrowDirectionRight)
    {
        CGFloat popOverMidY = CGRectGetMidY(self.popOverRect);
        CGFloat popOverMaxX = CGRectGetMaxX(self.popOverRect) + popViewWithPopoverViewSpace;
        if (arrowDirection == UIPopViewArrowDirectionRight) {
            popOverMaxX = CGRectGetMinX(self.popOverRect) - self.popOverContentSize.width - popViewWithPopoverViewSpace;
        }
        
        CGFloat popViewH = self.popOverContentSize.height;
        CGFloat maxShowContentSizeHeight = showInHeight - self.popViewEdgeInsets.top - self.popViewEdgeInsets.bottom;
        if (popViewH <= maxShowContentSizeHeight)
        {
            if (popOverMidY + popViewH / 2 <= showInHeight - self.popViewEdgeInsets.bottom  && popOverMidY - popViewH / 2 >= self.popViewEdgeInsets.top) {
                frame = CGRectMake(popOverMaxX, popOverMidY - popViewH/2, self.popOverContentSize.width, self.popOverContentSize.height);
            }
            else if (popOverMidY + popViewH /2 > showInHeight - self.popViewEdgeInsets.bottom)
            {
                frame = CGRectMake(popOverMaxX, showInHeight - self.popViewEdgeInsets.bottom - self.popOverContentSize.height, self.popOverContentSize.width, self.popOverContentSize.height);
                
                CGFloat diffY = popOverMidY + popViewH/2 - CGRectGetMaxY(frame);
                CGRect oldTriangleFrame = self.triangleEffectView.frame;
                oldTriangleFrame.origin.y += diffY;
                
                if (oldTriangleFrame.origin.y > self.popOverContentSize.height - self.contentCornerRadius - oldTriangleFrame.size.height) {
                    oldTriangleFrame.origin.y = self.popOverContentSize.height - self.contentCornerRadius - oldTriangleFrame.size.height;
                }
                self.triangleEffectView.frame = oldTriangleFrame;
            }
            else if (popOverMidY - popViewH / 2 < self.popViewEdgeInsets.top)
            {
                frame = CGRectMake(popOverMaxX, self.popViewEdgeInsets.top, self.popOverContentSize.width, self.popOverContentSize.height);
                
                CGFloat diffY = CGRectGetMinY(frame) - (popOverMidY - popViewH / 2);
                CGRect oldTriangleFrame = self.triangleEffectView.frame;
                oldTriangleFrame.origin.y -= diffY;
                if (oldTriangleFrame.origin.y < self.contentCornerRadius) {
                    oldTriangleFrame.origin.y = self.contentCornerRadius;
                }
                self.triangleEffectView.frame = oldTriangleFrame;
            }
        }
        else
        {
            frame = CGRectMake(popOverMaxX, (showInHeight - popViewH)/2, self.popOverContentSize.width, self.popOverContentSize.height);
        }
    }
    self.frame = frame;
    self.popContentView.frame = self.bounds;
}

-(void)_resetPopViewContentSize
{
    NSInteger rows =  [self.dataSource numberOfRowsInPopView:self];
    CGFloat totalHeight = 0;
    if (rows > 0 && [self.delegate respondsToSelector:@selector(popView:heightForRowAtIndexPath:)]) {
        for (NSInteger index = 0; index < rows; ++index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            CGFloat RowHeight = [self.delegate popView:self heightForRowAtIndexPath:indexPath];
            totalHeight += RowHeight;
            [self.rowsDicts setObject:[NSNumber numberWithDouble:RowHeight] forKey:[NSNumber numberWithInteger:indexPath.row]];
        }
        if (self.autoAdjustPopOverContentSize) {
            if (self.arrowDirection == UIPopViewArrowDirectionAny || self.arrowDirection == UIPopViewArrowDirectionUp || self.arrowDirection == UIPopViewArrowDirectionDown) {
                
                if (self.triangleViewHeightWithContentViewHeightRatio >= 1.0) {
                    totalHeight += self.triangleViewSize.height;
                }
                else
                {
                    CGFloat triangleViewHeightWithContentViewHeightRatio = [self _getLastNewTriangleViewHeightRatioWithPopOverContentSize:CGSizeMake(self.popOverContentSize.width, totalHeight)];
                    if (triangleViewHeightWithContentViewHeightRatio >= 1.0) {
                        totalHeight += self.triangleViewSize.height;
                    }
                    else
                    {
                        self.triangleViewHeightWithContentViewHeightRatio = MAX(0, triangleViewHeightWithContentViewHeightRatio);
                        totalHeight = totalHeight / ( 1 - self.triangleViewHeightWithContentViewHeightRatio);

                    }
                }
            }
            self.popOverContentSize = CGSizeMake(self.popOverContentSize.width, totalHeight);
        }
    }
}

-(void)_layoutPopContentSubViews
{
    if (self.arrowDirection != UIPopViewArrowDirectionAny) {
        self.arrowDirectionPriorityOrder = @[@(self.arrowDirection)];
        self.arrowDirection = UIPopViewArrowDirectionAny;
    }
    
    [self _setuplayoutValue];
    [self _resetPopViewContentSize];

    UIPopViewArrowDirectionScoreContext *ctx = [self _getPopViewDirectionFromPopViewArrowDirection:self.arrowDirection];
     //如果score等于0的话，让它异常的显示出来
    //从这里取出来的popOverContentSize不能在进行变化
    self.popOverContentSize = ctx.popOverContentSize;
    
    UITriangleViewVertexAngleDirection vertexAngleDirection = (UITriangleViewVertexAngleDirection)ctx.arrowDirection;
    
    CGSize triangleViewSize = self.triangleViewSize;
    
    CGFloat triangleViewX = 0;
    CGFloat triangleViewY = 0;
    
    CGRect triangleViewFrame = CGRectZero;
    CGRect triangleLayerFrame = CGRectZero;
    CGRect tableViewFrame = CGRectZero;
    
    if (ctx.arrowDirection == UIPopViewArrowDirectionUp) {
        triangleViewX = (self.popOverContentSize.width - triangleViewSize.width)/2;
        triangleViewY = 0;
    
        triangleViewFrame = CGRectMake(triangleViewX, triangleViewY, triangleViewSize.width, triangleViewSize.height);
        
        triangleLayerFrame = CGRectMake(0, 0, triangleViewSize.width, triangleViewSize.height);
        
        tableViewFrame = CGRectMake(0, triangleViewSize.height - self.tableViewSeparatorLineHeight, self.popOverContentSize.width, self.popOverContentSize.height - triangleViewSize.height /*- self.tableViewSeparatorLineHeight*/);
    }
    else if (ctx.arrowDirection == UIPopViewArrowDirectionLeft)
    {
        triangleViewX = 0;
        triangleViewY = (self.popOverContentSize.height - triangleViewSize.width)/2;
        
        triangleViewFrame = CGRectMake(triangleViewX, triangleViewY, triangleViewSize.height, triangleViewSize.width);
        triangleLayerFrame = CGRectMake(0, 0, triangleViewSize.height, triangleViewSize.width);
        
        tableViewFrame = CGRectMake(triangleViewSize.height-tableViewEdgeLineWidth, 0, self.popOverContentSize.width - triangleViewSize.height, self.popOverContentSize.height-self.tableViewSeparatorLineHeight);

    }
    else if (ctx.arrowDirection == UIPopViewArrowDirectionDown)
    {
        triangleViewX = (self.popOverContentSize.width - triangleViewSize.width)/2;
        triangleViewY = self.popOverContentSize.height - triangleViewSize.height - self.tableViewSeparatorLineHeight;
        
        triangleViewFrame = CGRectMake(triangleViewX, triangleViewY, triangleViewSize.width, triangleViewSize.height);
        
        triangleLayerFrame = CGRectMake(0, 0, triangleViewSize.width, triangleViewSize.height);
        tableViewFrame = CGRectMake(0, self.tableViewSeparatorLineHeight, self.popOverContentSize.width, self.popOverContentSize.height - triangleViewSize.height /*- self.tableViewSeparatorLineHeight*/);
    }
    else if (ctx.arrowDirection == UIPopViewArrowDirectionRight)
    {
        triangleViewX = self.popOverContentSize.width - triangleViewSize.height;
        triangleViewY = (self.popOverContentSize.height - triangleViewSize.width)/2;
        
        triangleViewFrame = CGRectMake(triangleViewX, triangleViewY, triangleViewSize.height, triangleViewSize.width);
        triangleLayerFrame = CGRectMake(0, 0, triangleViewSize.height, triangleViewSize.width);
        
        tableViewFrame = CGRectMake(tableViewEdgeLineWidth, 0, self.popOverContentSize.width - triangleViewSize.height, self.popOverContentSize.height - self.tableViewSeparatorLineHeight);
    }
    
    //1.创建路径
    UIBezierPath *trianglePath = [UITriangleView triangleBezierPathFromRect:triangleLayerFrame withVertexAngleDirection:vertexAngleDirection];
    //2.创建CAshapeLayer作为mask
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = trianglePath.CGPath;
    
    //3.创建毛玻璃效果图
    self.triangleEffectView.frame = triangleViewFrame;
    self.triangleEffectView.layer.mask = mask;
    
    //4.创建三角形View
    self.triangleView.vertexAngleDirection = vertexAngleDirection;
    self.triangleView.frame = self.triangleEffectView.bounds;
    [self.triangleView setColor:self.color];
    
    //1.创建毛玻璃效果图
    self.tableEffectView.frame = tableViewFrame;
        
    self.tableView.frame = self.tableEffectView.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self _adjustPopOverViewFrameForArrowDirection:ctx.arrowDirection];
    self.showArrowDirection = ctx.arrowDirection;
    
//    [self _updatePopContentView];
}

#if 0
-(void)_updatePopContentView
{
    UIBezierPath *contentPath = [self getContentViewPath];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    self.popContentView.layer.mask = mask;
    self.popContentView.layer.masksToBounds = YES;
}

-(UIBezierPath*)getContentViewPath
{
    CGFloat corneradius = tableViewCornerRadius;//self.contentCornerRadius;
    CGRect triangleFrame = self.triangleEffectView.frame;
    if (CGSizeEqualToSize(triangleFrame.size, CGSizeZero)) {
        return [UIBezierPath bezierPathWithRoundedRect:self.popContentView.bounds cornerRadius:corneradius];
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    CGFloat borderWidth = self.popContentView.layer.borderWidth;
    CGSize contentSize = self.popContentView.size;
    CGPoint centerPoint = CGPointZero;
    
    if (self.showArrowDirection == UIPopViewArrowDirectionUp) {
        //上面带有三角形的区域
        [bezierPath moveToPoint:CGPointMake(corneradius, CGRectGetHeight(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(triangleFrame.origin.x, CGRectGetHeight(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(CGRECT_CENTER_POINT(triangleFrame).x, 0)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(triangleFrame), CGRectGetHeight(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - corneradius,CGRectGetHeight(triangleFrame))];
        
        //画四分之一圆角，右上
        centerPoint = CGPointMake(contentSize.width - corneradius, CGRectGetHeight(triangleFrame) + corneradius);
        [bezierPath addArcWithCenter:centerPoint radius:corneradius startAngle:3 * M_PI_2 endAngle:0 clockwise:YES];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(contentSize.width, contentSize.height - corneradius)];
        
        //画四分之一圆角，右下
        centerPoint = CGPointMake(contentSize.width - corneradius, contentSize.height - corneradius);
        [bezierPath addArcWithCenter:centerPoint radius:corneradius startAngle:0 endAngle:M_PI_2 clockwise:YES];

        //画横线
        [bezierPath addLineToPoint:CGPointMake(corneradius, contentSize.height)];
        
        //画四分之一圆角，左下
        centerPoint = CGPointMake(corneradius, contentSize.height - corneradius);
        [bezierPath addArcWithCenter:centerPoint radius:corneradius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];

        //画竖线
        [bezierPath addLineToPoint:CGPointMake(0, CGRectGetHeight(triangleFrame) + corneradius)];
        //画四分之一圆角，左上
        centerPoint = CGPointMake(corneradius, CGRectGetHeight(triangleFrame) + corneradius);
        [bezierPath addArcWithCenter:centerPoint radius:corneradius startAngle:M_PI endAngle:3 * M_PI_2 clockwise:YES];
    }
    else if (self.showArrowDirection == UIPopViewArrowDirectionRight) {
        [bezierPath moveToPoint:CGPointMake(corneradius, 0)];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame) - corneradius, 0)];
        
        //画四分之一圆角，右上
        centerPoint = CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame) - corneradius,corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:-M_PI_2 endAngle:0 clockwise:YES]];
        
        //三角形
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame), triangleFrame.origin.y)];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width, CGRECT_CENTER_POINT(triangleFrame).y)];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame),CGRectGetMaxY(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame), contentSize.height - corneradius)];
        
        //画四分之一圆角，右下
        centerPoint = CGPointMake(contentSize.width - CGRectGetWidth(triangleFrame) - corneradius, contentSize.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:0 endAngle:M_PI_2 clockwise:YES]];
        
        //画横线
        [bezierPath addLineToPoint:CGPointMake(corneradius, contentSize.height)];
        
        //画四分之一圆角，左下
        centerPoint = CGPointMake(corneradius, contentSize.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI_2 endAngle:M_PI clockwise:YES]];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(0, corneradius)];
        
        centerPoint = CGPointMake(corneradius, corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES]];

    }
    else if (self.showArrowDirection == UIPopViewArrowDirectionDown) {
        //画横线
        [bezierPath moveToPoint:CGPointMake(corneradius, 0)];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - corneradius, 0)];
        
        //画四分之一圆角，右上
        centerPoint = CGPointMake(contentSize.width - corneradius, corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:-M_PI_2 endAngle:0 clockwise:YES]];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(contentSize.width, contentSize.height - triangleFrame.size.height - corneradius)];
        
        //画四分之一圆角，右下
        centerPoint = CGPointMake(contentSize.width - corneradius, contentSize.height - triangleFrame.size.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:0 endAngle:M_PI_2 clockwise:YES]];
        
        //画三角
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(triangleFrame), contentSize.height - triangleFrame.size.height)];
        [bezierPath addLineToPoint:CGPointMake(CGRECT_CENTER_POINT(triangleFrame).x, contentSize.height)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(triangleFrame), contentSize.height - triangleFrame.size.height)];
        [bezierPath addLineToPoint:CGPointMake(corneradius, contentSize.height - triangleFrame.size.height)];
        
        //画四分之一圆角，左下
        centerPoint = CGPointMake(corneradius, contentSize.height - triangleFrame.size.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI_2 endAngle:M_PI clockwise:YES]];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(0, corneradius)];
        
        //画四分之一圆角，左上
        centerPoint = CGPointMake(corneradius, corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES]];
    }
    else if (self.showArrowDirection == UIPopViewArrowDirectionLeft) {
        //画横线
        [bezierPath moveToPoint:CGPointMake(CGRectGetWidth(triangleFrame)+corneradius, 0)];
        [bezierPath addLineToPoint:CGPointMake(contentSize.width - corneradius, 0)];
        
        //画四分之一圆角，右上
        centerPoint = CGPointMake(contentSize.width - corneradius, corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:-M_PI_2 endAngle:0 clockwise:YES]];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(contentSize.width, contentSize.height - corneradius)];
        
        //画四分之一圆角，右下
        centerPoint = CGPointMake(contentSize.width - corneradius, contentSize.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:0 endAngle:M_PI_2 clockwise:YES]];
        
        //画横线
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(triangleFrame)+corneradius, 0)];
        
        //画四分之一圆角，左下
        centerPoint = CGPointMake(CGRectGetWidth(triangleFrame) + corneradius, contentSize.height - corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI_2 endAngle:M_PI clockwise:YES]];
        
        //画竖线
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(triangleFrame), CGRectGetMaxY(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(0, CGRECT_CENTER_POINT(triangleFrame).y)];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(triangleFrame), CGRectGetMinY(triangleFrame))];
        [bezierPath addLineToPoint:CGPointMake(0, corneradius)];
        
        //画四分之一圆角，左上
        centerPoint = CGPointMake(CGRectGetWidth(triangleFrame) + corneradius, corneradius);
        [bezierPath appendPath:[UIBezierPath bezierPathWithArcCenter:centerPoint radius:corneradius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES]];
    }
    [bezierPath closePath];
    return bezierPath;
}
#endif

-(NSMutableDictionary*)rowsDicts
{
    if (_rowsDicts == nil) {
        _rowsDicts = [NSMutableDictionary dictionary];
    }
    return _rowsDicts;
}

-(void)setColor:(UIColor *)color
{
    _color = color;

    self.triangleView.color = color;
    self.tableView.backgroundColor = color;
}

-(void)_addToShowInView:(UIView*)showInView
{
    if (showInView == nil) {
        if (self.showInView == nil) {
            showInView = [UIApplication sharedApplication].keyWindow;
        }
        else {
            showInView = self.showInView;
        }
    }
    self.showInView = showInView;
    
    [showInView addSubview:self];
}

-(void)popViewShow:(BOOL)animated
{
    [self popViewShowInView:nil animated:animated];
}

-(void)popViewShowInView:(UIView*)showInView animated:(BOOL)animated
{
    [self _addToShowInView:showInView];
    
    [self _layoutPopContentSubViews];
    
    if (animated) {
        self.popContentView.alpha = 0.1;
        self.popContentView.bounds = CGRectZero;
        [UIView animateWithDuration:animationTimeInterval animations:^{
            self.popContentView.alpha = 1.0;
            self.popContentView.bounds = CGRectMake(0, 0, self.popOverContentSize.width, self.popOverContentSize.height);
        }];
    }
}

-(void)popViewFromOverView:(UIView*)overView showInView:(UIView*)showInView animated:(BOOL)animated
{
    if (overView) {
        self.popOverRect = [overView.superview convertRect:overView.frame toView:showInView];
        self.showInView = showInView;
    }
    [self popViewShowInView:showInView animated:animated];
}

-(void)_coverClickAction:(UIButton*)sender
{
    [UIView animateWithDuration:animationTimeInterval animations:^{
        self.popContentView.alpha = 0.1;
        self.popContentView.bounds = CGRectZero;
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
        self.cover = nil;
        [self.popContentView removeFromSuperview];
        self.popContentView = nil;
        [self.rowsDicts removeAllObjects];
        [self removeFromSuperview];
    }];
}

-(void)setTableSeparatorLine
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)setTableSeparatorLineWithCell:(UITableViewCell*)cell
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.rowsDicts) {
        NSNumber *rowHeight = [self.rowsDicts objectForKey:[NSNumber numberWithInteger:indexPath.row]];
        if (rowHeight) {
            return [rowHeight floatValue];
        }
        return 0;
    }
    else
    {
        if (self.showArrowDirection == UIPopViewArrowDirectionUp || self.showArrowDirection == UIPopViewArrowDirectionDown) {
            return self.popOverContentSize.height - self.triangleViewSize.height;

        }
        return self.popOverContentSize.height;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowsDicts.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIPopViewCell *popViewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UIPopViewCell class])];
    [self.dataSource popView:self popViewCell:popViewCell forRowAtIndexPath:indexPath];
    popViewCell.backgroundColor = self.color;
    if (indexPath.row == self.rowsDicts.count -1) {
        popViewCell.separatorLine.backgroundColor = CLEAR_COLOR.CGColor;
    }
    else {
        popViewCell.separatorLine.backgroundColor = self.separatorLineColor.CGColor;
    }
    return popViewCell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(popView:didSelectedForRowAtIndexPath:)]) {
        [self.delegate popView:self didSelectedForRowAtIndexPath:indexPath];
    }
    [self _coverClickAction:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTableSeparatorLine];
    [self setTableSeparatorLineWithCell:cell];
}

-(void)dealloc
{
    self.arrowDirectionPriorityOrder = nil;
    [self.rowsDicts removeAllObjects];
    self.rowsDicts = nil;
}
@end

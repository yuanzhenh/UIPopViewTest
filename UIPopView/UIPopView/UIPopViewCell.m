//
//  UIPopViewCell.m
//  yzh
//
//  Created by captain on 16/5/4.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UIPopViewCell.h"

@interface UIPopViewCell()

@end

@implementation UIPopViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
    _separatorLine = [[CALayer alloc] init];
    self.separatorLine.backgroundColor = RGB_WITH_INT_WITH_NO_ALPHA(0x999999).CGColor;
    [self.contentView.layer addSublayer:self.separatorLine];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGFloat h = SINGLE_LINE_WIDTH;
    
    CGFloat offset = 0;
    if (((int)(h * SCREEN_SCALE) + 1) % 2 == 0) {
        offset = SINGLE_LINE_ADJUST_OFFSET;
    }
    self.separatorLine.frame = CGRectMake(0, self.contentView.bounds.size.height - h - offset, w, h);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

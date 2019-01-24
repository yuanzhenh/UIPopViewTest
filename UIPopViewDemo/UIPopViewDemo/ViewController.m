//
//  ViewController.m
//  UIPopViewDemo
//
//  Created by captain on 16/12/8.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "ViewController.h"
#import "UIPopView.h"

@interface ViewController ()<UIPopViewDelegate,UIPopViewDataSource>

@property (nonatomic, strong) UIView *testView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self setUpChildView];
    
    [self _setupTestView];
}

-(void)_setupTestView
{
    self.testView = [UIView new];
    self.testView.frame = CGRectMake(50, 50, SCREEN_WIDTH - 100, SCREEN_HEIGHT - 100);
    self.testView.backgroundColor = PURPLE_COLOR;
    [self.view addSubview:self.testView];
}

-(void)setUpChildView
{
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor purpleColor];
//    btn.frame = CGRectMake(SCREEN_WIDTH - 100, 30, 64, 20);
//    btn.frame = CGRectMake(249.500000,16.666656,133.000000,26.000000);
//    btn.frame = CGRectMake(73.000000,290.000000,72.000000,71.000000);
    CGFloat width = 26;
    CGFloat space = 16;
    CGFloat height = 44;
//    btn.frame = CGRectMake(SCREEN_WIDTH - width - space, 20, width, height);
    btn.frame = CGRectMake(160.666656,78.333328,76.000000,40.000000);
    [btn setTitle:@"PopView" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(popViewShow:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, (SCREEN_HEIGHT-200)/2, 200, 200)];
//    
//    NSLog(@"view.frame=(%f,%f,%f,%f)",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height);
//    view.backgroundColor = YELLOW_COLOR;
//    [self.view addSubview:view];
//    
//    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
//    subView.backgroundColor = RED_COLOR;
//    [view addSubview:subView];
//    
//    UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 20, 20)];
//    subView2.backgroundColor = GREEN_COLOR;
//    [subView addSubview:subView2];
//    
////    CGRect rect = [self.view convertRect:subView.frame fromView:view];
//    CGRect rect = [subView.superview convertRect:subView.frame toView:self.view];
//    NSLog(@"rect.x=%f,y=%f,w=%f,h=%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
//    
//    rect = [subView2.superview convertRect:subView2.frame toView:self.view];
//    NSLog(@"rect2.x=%f,y=%f,w=%f,h=%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
//    
//    NSDate *date = [NSDate date];
//    NSDate *futureDate = [[NSDate alloc] initWithTimeIntervalSinceNow:90*24*3600];
//    NSLog(@"date=%@,futureDate=%@,timediff=%f",date,futureDate, [futureDate timeIntervalSince1970]);
//    
//    NSLog(@"datex=%f",[[NSDate date] timeIntervalSince1970]);
//    if ([date timeIntervalSince1970] < 1489033546) {
//        
//    }
}

-(void)setUpBtnViewForPoint:(CGPoint)point
{
    UIView *btn = [[UIView alloc] init];
    btn.backgroundColor = RED_COLOR;
    
    CGFloat w = arc4random()% ((NSInteger)self.testView.bounds.size.width/2) + 2;
    CGFloat h = arc4random()% ((NSInteger)self.testView.bounds.size.height/5) + 2;
//    btn.frame = CGRectMake(SCREEN_WIDTH - 250, (SCREEN_HEIGHT - 64)/2  + 100, 200, 64);
    btn.frame = CGRectMake(point.x - w/2, point.y - h/2, w, h);
//    NSLog(@"btn.frame=(%f,%f,%f,%f)",btn.frame.origin.x,btn.frame.origin.y,w,h);
    [self.testView addSubview:btn];
    
    [self popViewShow:btn];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.testView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UITouch *touch = [[touches allObjects] firstObject];

    CGPoint point = [touch locationInView:self.view];
    
    [self setUpBtnViewForPoint:point];
}

-(void)popViewShow:(UIView *)sender
{
    UIView *toView = self.testView;
    //方法一
//    UIPopView *popView = [[UIPopView alloc] initWithPopOverContentSize:CGSizeMake(180, 200)];
//    [popView setColor:WHITE_COLOR];
//    popView.delegate = self;
//    popView.dataSource = self;
//    popView.separatorLineColor = RGB_WITH_INT_WITH_NO_ALPHA(0X666666);
//    popView.arrowDirectionPriorityOrder = @[@1];//@[@4,@3,@2,@1];
//    [popView popViewFromOverView:sender showInView:toView animated:NO];
    
    //方法二
//    CGRect popRect = [sender.superview convertRect:sender.frame toView:toView];
//    UIPopView *popView = [[UIPopView alloc] initWithPopOverContentSize:CGSizeMake(180, 200) fromRect:popRect];
//    [popView setColor:WHITE_COLOR];
//    popView.delegate = self;
//    popView.dataSource = self;
//    popView.separatorLineColor = RGB_WITH_INT_WITH_NO_ALPHA(0X666666);
//    popView.arrowDirectionPriorityOrder = @[@1];//@[@4,@3,@2,@1];
////    [popView popViewShowInView:toView animated:YES];
//    [popView popViewFromOverView:sender showInView:nil animated:YES];
    
    //方法三
    UIPopView *popView = [[UIPopView alloc] initWithPopOverContentSize:CGSizeMake(180, 200) fromOverView:sender showInView:toView];
    popView.delegate = self;
    popView.dataSource = self;
//    popView.arrowDirectionPriorityOrder = @[@1];//@[@4,@3,@2,@1];
    popView.arrowDirection = UIPopViewArrowDirectionUp;
//    [popView popViewShow:YES];
//    [popView popViewShowInView:toView animated:NO];
    [popView popViewFromOverView:sender showInView:nil animated:YES];
}

-(NSInteger)numberOfRowsInPopView:(UIPopView *)popView
{
    return 20;
}

-(void)popView:(UIPopView *)popView popViewCell:(UIPopViewCell *)popViewCell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NavRightBarItemListModel *model = self.NavRightBarItemListModels[indexPath.row];
//    popViewCell.imageView.image = [UIImage imageNamed:model.iconPath];
//    popViewCell.textLabel.textColor = WHITE_COLOR;
//    popViewCell.textLabel.font = BOLD_FONT(15);//FONT(16);
//    popViewCell.textLabel.text = model.iconTitle;
    popViewCell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
}

-(CGFloat)popView:(UIPopView *)popView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(void)popView:(UIPopView *)popView didSelectedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"popView---------didSelectedRowAtIndexPath=%ld",indexPath.row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

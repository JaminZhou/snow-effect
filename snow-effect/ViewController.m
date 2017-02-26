//
//  ViewController.m
//  snow-effect
//
//  Created by JaminZhou on 2017/2/26.
//  Copyright © 2017年 Hangzhou Tomorning Technology Co., Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic) UIView *segmentBackView;
@property (nonatomic) UIView *segmentSlideView;
@property (nonatomic) UIScrollView *pagingScrollView;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation ViewController

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KSegmentViewtHeight 44
#define KSegmentViewLeading 8
#define KPagingViewHeight (KScreenHeight-64-KSegmentViewtHeight)
#define KOnePixels (1/[UIScreen mainScreen].scale)

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex!=currentIndex) {
        if (_currentIndex) ((UIButton *)[_segmentBackView viewWithTag:_currentIndex]).selected = NO;
        ((UIButton *)[_segmentBackView viewWithTag:currentIndex]).selected = YES;
        _currentIndex = currentIndex;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSegmentView];
    [self addPagingView];
}

- (void)addSegmentView {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KSegmentViewtHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.shadowColor = [UIColor blackColor].CGColor;
    backView.layer.shadowOffset = CGSizeMake(0, 1.5);
    backView.layer.shadowRadius = 3;
    backView.layer.shadowOpacity = 0.04;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, KSegmentViewtHeight-KOnePixels, KScreenWidth, KOnePixels)];
    lineView.backgroundColor = [UIColor colorWithWhite:218/255.0 alpha:1.0];
    
    [self.view addSubview:backView];
    [self.view addSubview:lineView];
    
    for (int i=0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*KScreenWidth/3, 0, KScreenWidth/3, KSegmentViewtHeight);
        button.tag = i+1;
        [button addTarget:self action:@selector(tapSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
        NSDictionary *normal = @{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:78/255.0 green:86/255.0 blue:101/255.0 alpha:1.0]};
        NSDictionary *select = @{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:141/255.0 blue:237/255.0 alpha:1.0]};
        NSString *title;
        switch (i) {
            case 0:
                title = @"Notifications";
                break;
            case 1:
                title = @"Groups";
                break;
            case 2:
                title = @"Message";
                break;
            default:
                break;
        }
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:normal] forState:UIControlStateNormal];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:select] forState:UIControlStateSelected];
    }
    
    UIView *slideView = [[UIView alloc] initWithFrame:CGRectMake(0, KSegmentViewtHeight-2, KScreenWidth/3, 2)];
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(KSegmentViewLeading, 0, CGRectGetWidth(slideView.frame)-2*KSegmentViewLeading, CGRectGetHeight(slideView.frame))];
    blueView.backgroundColor = [UIColor colorWithRed:0 green:141/255.0 blue:237/255.0 alpha:1.0];
    [slideView addSubview:blueView];
    [backView addSubview:slideView];
    
    _segmentSlideView = slideView;
    _segmentBackView = backView;
}

- (void)addPagingView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, KSegmentViewtHeight, KScreenWidth, KPagingViewHeight)];
    scrollView.contentSize = CGSizeMake(3*CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    for (int i=0; i<3; i++) {
        UIView *view = [[NSBundle mainBundle] loadNibNamed:@"ActivityView" owner:self options:nil][i];
        CGRect rect = scrollView.bounds;
        rect.origin.x = i*CGRectGetWidth(view.frame);
        view.frame = rect;
        [scrollView addSubview:view];
        
        if (i==1) [self addSnowEffect:[view viewWithTag:1]];
    }
    
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0);
    _pagingScrollView = scrollView;
}

- (void)addSnowEffect:(UIView *)view {
    CGRect rect = CGRectMake(-0.3*view.frame.size.width, -0.7*view.frame.size.height, view.frame.size.width*1.6, 0.1*view.frame.size.height);
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = rect;
    [view.layer addSublayer:emitter];
    
    emitter.emitterShape = kCAEmitterLayerRectangle;
    emitter.emitterPosition = CGPointMake(rect.size.width/2, rect.size.height/2);
    emitter.emitterSize = rect.size;
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (id)[UIImage imageNamed:@"snow"].CGImage;
    cell.birthRate = 12;
    cell.lifetime = 80;
    cell.lifetimeRange = 1;
    cell.yAcceleration = 4.0;
    cell.scale = 0.8;
    cell.scaleRange = 0.2;
    cell.scaleSpeed = -0.03;
    cell.alphaRange = 0.08;
    cell.alphaSpeed = -0.05;
    
    emitter.emitterCells = @[cell];
}

- (void)tapSegmentButton:(UIButton *)sender {
    if (_currentIndex!=sender.tag) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _pagingScrollView.contentOffset = CGPointMake(KScreenWidth*(sender.tag-1), 0);
                         }
                         completion:^(BOOL finished) {

                         }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGRect rect = _segmentSlideView.frame;
    rect.origin.x = offsetX/3;
    _segmentSlideView.frame = rect;
    self.currentIndex = (offsetX+0.5*KScreenWidth)/KScreenWidth+1;
}

@end

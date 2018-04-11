//
//  ViewController.m
//  婚礼纪欢迎页的实现
//
//  Created by DR_Kun on 2018/4/11.
//  Copyright © 2018年 DR_Kun. All rights reserved.
//

#import "ViewController.h"

#import "DRContentView.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewDecelerationRateNormal;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.scrollView.delegate = self;

    [self addSubviews];
}

- (void)addSubviews {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    for (NSInteger i = 0; i < 4; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%@",@(i+1)];
        UIImage *image = [UIImage imageNamed:imageName];
        DRContentView *subview = [[[NSBundle mainBundle] loadNibNamed:@"DRContentView" owner:nil options:nil] lastObject];
        subview.frame = CGRectMake(i * width, 0, width, height);
        [subview setImage:image];
        [self.scrollView addSubview:subview];
        if (i == 0 || i == 3) {
            continue;
        }
        [subview changeOffset:(width * 0.5)];
    }
    self.scrollView.contentSize = CGSizeMake(4 * width, height - 20);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
}


#pragma mark --- UIScrollViewDelegate

/*
 计算公式:
 初始偏移量 = (width * 0.5)
 滑动偏移量 = (offsetX - width * index)
 改变的值 = 初始偏移量 - 滑动偏移量
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width;
    if (offsetX < width) {
            //获取到第二个 item
        DRContentView *item = scrollView.subviews[1];
        [item changeOffset:(width * 0.5 - offsetX * 0.5)];
    }else if (offsetX < width * 2) {
        DRContentView *item2 = scrollView.subviews[1];
        [item2 changeOffset:0];
            //获取到第三个 item
        DRContentView *item = scrollView.subviews[2];
        [item changeOffset:(width * 0.5 - (offsetX - width) * 0.5)];
    }else if (offsetX < width * 3 - 0.1) {
        DRContentView *item3 = scrollView.subviews[2];
        [item3 changeOffset:0];
            //获取到第四个 item
        DRContentView *item = scrollView.subviews[3];
        [item changeOffset:(width * 0.5 - ((offsetX - 2 * width) * 0.5))];
    }else if (offsetX >= width * 3 - 0.1) {
            //获取到第四个 item
        DRContentView *item = scrollView.subviews[3];
        [item changeOffset:0];
    }
}


//这里应该做一下处理防止快速拖动时 出现下一页显示一小部分又回弹回去
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

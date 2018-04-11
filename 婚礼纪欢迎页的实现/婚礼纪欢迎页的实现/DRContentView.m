//
//  DRContentView.m
//  婚礼纪欢迎页的实现
//
//  Created by DR_Kun on 2018/4/11.
//  Copyright © 2018年 DR_Kun. All rights reserved.
//

#import "DRContentView.h"


@interface DRContentView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;

@end


@implementation DRContentView

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)changeOffset:(CGFloat)value {
    self.leadingSpace.constant =  -value;
    self.trailingSpace.constant = value;
}


@end

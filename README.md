# -
实现婚礼纪类似的欢迎页

老规矩，上图(无图无真相)，看官们可以先自行思考一下怎么实现才不显得代码臃肿，易于维护和调试，效果图奉上：
![婚礼纪原版效果.gif](https://upload-images.jianshu.io/upload_images/258046-bd5129b56e374f8b.gif?imageMogr2/auto-orient/strip)

![仿写效果图.gif](https://upload-images.jianshu.io/upload_images/258046-2c6f1d589f2c1741.gif?imageMogr2/auto-orient/strip)

好的....


思考时间结束。


`观察现象`如下：第二个`imageView2`初始位置显示位置是在最中间的部分处于屏幕的边缘，`scrollView`滚动一屏的宽是全部显示。
`实现思路`如下：根据`scrollView`的滚动的范围动态改变`imageView`的位置。

这里会有一个思维误区：就是直接把`imageView`直接加到`scrollView`上，然后去改变`imageView`在`scrollView`上的布局，这样做你还要动态的改变`scrollView`的`contentSize`，并且你在使用`pagingEnabled`属性时也会出现一些意料之外的问题;

要优雅的实现类似的交互效果，我们应当从面向对象的角度思考(oop)，`imageView`应该被封装出能够单独处理自己偏移的对象，`scrollView`仅处理`偏移量`的计算，不应该改变自身的`contentSize`(类似于`collectionView`和`collectionCell`的处理逻辑);

项目代码[传送门](https://github.com/gitKun/-);

好了，接下来我们来一步步实现：

1. 使用`storyboard`快速创建界面，并添加相应的约束，scrollView设置了背景色方便调试；  
![StoryBoard快速创建.png](https://upload-images.jianshu.io/upload_images/258046-05cbafd7fddc3b97.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
*注意图中约束的条件*

2. 创建`DRContentView`
![指定xib为DRContentView.png](https://upload-images.jianshu.io/upload_images/258046-646fd3b3f61dd46a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![管理imageView偏移量的view.png](https://upload-images.jianshu.io/upload_images/258046-93e4e47bca058344.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. 将`imageView`的需要做偏移的约束设置为`DRContentView`的属性，并将勾选`DRContentViwe`的`Clip to Bounds`，控制偏移的约束如下图所示，`leading`,`trailing`

![控制偏移的属性.png](https://upload-images.jianshu.io/upload_images/258046-1623eec5c0ccd0b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![设置裁剪](https://upload-images.jianshu.io/upload_images/258046-bd5c00cad9eebf19.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


4. 在`DRContentView.h`里暴露一个修改偏移量的方法,并在`.m`实现它;

```
#import <UIKit/UIKit.h>

@interface DRContentView : UIView

- (void)setImage:(UIImage *)image;
/*
 * 修改偏移量
*/
- (void)changeOffset:(CGFloat)value;

@end
```
 ```
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

```

5.回到`ViewController.m`中，添加视图
```
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

@end
```

6.`cmd`+`R` 效果如下如下：

![初步效果.gif](https://upload-images.jianshu.io/upload_images/258046-a3fa6b7affedd2a4.gif?imageMogr2/auto-orient/strip)

7. 我们在`- scrollViewDidScroll:`防范重进行对应`contentView`的偏移量计算;
  **注意：这里设置了`UIScrollView`的`showsVerticalScrollIndicator`和`showsHorizontalScrollIndicator`方法为`NO`(sb中取消勾选),否则你就要在区出`DRContentView`时进行相应的判断了🙈**
  
```
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
```

![不取消showScrollIndicator时scrollView的子视图.png](https://upload-images.jianshu.io/upload_images/258046-c4843b4921c5c402.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
对应的计算问题大家应该都能自己算出来，这里不做过多讨论了,至于其他需要补充的，还是看github源码吧,用到的图片就不单独贴出来
![图片资源](https://upload-images.jianshu.io/upload_images/258046-fc1ed21c79437316.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后来一张 iPhoneX 的截图
![祝好祝顺](https://upload-images.jianshu.io/upload_images/258046-ee657a0c04126f64.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


//
//  FSPageContentView.m
//  Huim
//
//  Created by huim on 2017/4/28.
//  Copyright © 2017年 huim. All rights reserved.
//

#import "FSPageContentView.h"

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
static NSString *collectionCellIdentifier = @"collectionCellIdentifier";

@interface FSCollectionView : UICollectionView

@end

@implementation FSCollectionView

/**
 *  重写手势，如果是左滑，则禁用掉scrollview自带的
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        if (self.contentOffset.x == (self.contentSize.width - self.width) && [pan translationInView:self].x < 0.0f) {
            
            return NO;
        }
        
        if([pan translationInView:self].x > 0.0f && self.contentOffset.x == 0.0f)
        {
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
//    CGSize size = [UIScreen mainScreen].bounds.size;
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
//
//        NSInteger off = (NSInteger)self.contentOffset.x;
//        NSInteger screen = (NSInteger)size.width;
//        NSInteger page = off / screen;
//
//        CGFloat panX = [pan locationInView:self].x;
//
//        if (panX < 20.0f + page * screen && self.contentOffset.x == page * screen) {
//            // 这里返回 NO
//            return NO;
//        }
//    }
//    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end


@interface FSPageContentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    NSThread *checkShownThread;
}

@property (nonatomic, weak) UIViewController *parentVC;//父视图
@property (nonatomic, weak) FSCollectionView *collectionView;
@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, assign) BOOL isSelectBtn;//是否是滑动
@property (nonatomic, assign) CGFloat flowlayoutHeight;

@end

@implementation FSPageContentView

- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC delegate:(id<FSPageContentViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.flowlayoutHeight = frame.size.height;
        
        self.parentVC = parentVC;
        self.childsVCs = childVCs;
        self.delegate = delegate;
        
        [self setupSubViews];
    }
    return self;
}

#pragma mark --LazyLoad

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        FSCollectionView * collectionView = [[FSCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
        collectionView.backgroundColor = [UIColor whiteColor];

        [self addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

#pragma mark --setup
- (void)setupSubViews
{
    _startOffsetX = 0;
    _isSelectBtn = NO;
    _contentViewCanScroll = YES;
    
    for (UIViewController *childVC in self.childsVCs) {
        [self.parentVC addChildViewController:childVC];
    }
//    [self addSubview:self.collectionView];
    [self.collectionView reloadData];
}

//#pragma mark UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(JA_SCREEN_WIDTH, self.flowlayoutHeight);
//}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childsVCs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    if (IOS_VERSION < 8.0) {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIViewController *childVC = self.childsVCs[indexPath.item];
        childVC.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:childVC.view];
    }
    return cell;
}

#ifdef __IPHONE_8_0
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIViewController *childVc = self.childsVCs[indexPath.row];
    childVc.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:childVc.view];
}
#endif

#pragma mark UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isSelectBtn = NO;
    _startOffsetX = scrollView.contentOffset.x;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContentViewWillBeginDragging:)]) {
        [self.delegate FSContentViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isSelectBtn) {
        return;
    }
    CGFloat scrollView_W = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex = floor(_startOffsetX/scrollView_W);
    NSInteger endIndex;
    CGFloat progress;
    if (currentOffsetX > _startOffsetX) {//左滑left
        progress = (currentOffsetX - _startOffsetX)/scrollView_W;
        endIndex = startIndex + 1;
        if (endIndex > self.childsVCs.count - 1) {
            endIndex = self.childsVCs.count - 1;
        }
    }else if (currentOffsetX == _startOffsetX){//没滑过去
        progress = 0;
        endIndex = startIndex;
    }else{//右滑right
        progress = (_startOffsetX - currentOffsetX)/scrollView_W;
        endIndex = startIndex - 1;
        endIndex = endIndex < 0?0:endIndex;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContentViewDidScroll:startIndex:endIndex:progress:)]) {
        [self.delegate FSContentViewDidScroll:self startIndex:startIndex endIndex:endIndex progress:progress];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat scrollView_W = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex = floor(_startOffsetX/scrollView_W);
    NSInteger endIndex = floor(currentOffsetX/scrollView_W);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FSContenViewDidEndDecelerating:startIndex:endIndex:)]) {
        [self.delegate FSContenViewDidEndDecelerating:self startIndex:startIndex endIndex:endIndex];
    }
}

#pragma mark setter

- (void)setContentViewCurrentIndex:(NSInteger)contentViewCurrentIndex
{
    if (_contentViewCurrentIndex < 0||_contentViewCurrentIndex > self.childsVCs.count-1) {
        return;
    }
    _isSelectBtn = YES;
    _contentViewCurrentIndex = contentViewCurrentIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:contentViewCurrentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)setContentViewCanScroll:(BOOL)contentViewCanScroll
{
    _contentViewCanScroll = contentViewCanScroll;
    _collectionView.scrollEnabled = _contentViewCanScroll;
}

@end

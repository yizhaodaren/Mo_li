//
//  JAStoryTopicTableViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/7/12.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTopicView.h"
#import "JAStoryTopicCollectionViewCell.h"

@interface JAStoryTopicView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation JAStoryTopicView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.topics = [NSMutableArray new];
        
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.width, 21)];
        [self addSubview:upView];
        
        UIView *vlineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 3, 15)];
        vlineView.backgroundColor = HEX_COLOR(JA_Green);
        [upView addSubview:vlineView];
        vlineView.centerY = upView.height/2.0;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(vlineView.right+10, 0, 100, upView.height)];
        label.font = JA_REGULAR_FONT(15);
        label.textColor = HEX_COLOR(0x000000);
        [upView addSubview:label];
        label.text = @"热门话题";
        
        UIImageView *arrowIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 11)];
        arrowIV.image = [UIImage imageNamed:@"home_arrow"];
        [upView addSubview:arrowIV];
        arrowIV.centerY = upView.height/2.0;
        arrowIV.right = self.width-15;
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(0, 0, 27, 18);
        moreButton.titleLabel.font = JA_REGULAR_FONT(12);
        [moreButton setTitle:@"更多" forState:UIControlStateNormal];
        [moreButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [upView addSubview:moreButton];
        moreButton.centerY = upView.height/2.0;
        moreButton.right = arrowIV.left-3;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat itemW = WIDTH_ADAPTER(113);
        layout.itemSize = CGSizeMake(itemW, WIDTH_ADAPTER(170));
        layout.minimumLineSpacing = WIDTH_ADAPTER(5);
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 0);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[JAStoryTopicCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([JAStoryTopicCollectionViewCell class])];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        collectionView.y = upView.bottom+15;
        collectionView.width = JA_SCREEN_WIDTH;
        collectionView.height = WIDTH_ADAPTER(170);
        
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton = loadMoreButton;
        loadMoreButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [loadMoreButton setTitle:@"左\n滑\n更\n多" forState:UIControlStateNormal];
        [loadMoreButton setTitle:@"释\n放\n加\n载" forState:UIControlStateSelected];
        [loadMoreButton setTitleColor:HEX_COLOR(0xC6C6C6) forState:UIControlStateNormal];
        loadMoreButton.titleLabel.font = JA_REGULAR_FONT(12);
        [loadMoreButton setImage:[UIImage imageNamed:@"branch_album_load"] forState:UIControlStateNormal];
        [loadMoreButton setImage:[UIImage imageNamed:@"branch_album_loadMore"] forState:UIControlStateSelected];
        loadMoreButton.width = 32;
        loadMoreButton.height = collectionView.height;
        loadMoreButton.y = 0;
        loadMoreButton.x = JA_SCREEN_WIDTH;
        [loadMoreButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:3];
        [collectionView addSubview:loadMoreButton];
        
        // 虚线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-1, JA_SCREEN_WIDTH, 1)];
        [self addSubview:lineView];
        [UIView drawLineOfDashByCAShapeLayer:lineView lineLength:3 lineSpacing:2 lineColor:HEX_COLOR(JA_Line) lineDirection:YES];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)moreAction
{
    if (self.moreBlock)
    {
        self.moreBlock();
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat totalOff = scrollView.contentSize.width - self.collectionView.width;
    CGFloat off = totalOff - scrollView.contentOffset.x;
    if (off < -65) {
        self.loadMoreButton.selected = YES;
    }else{
        self.loadMoreButton.selected = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.loadMoreButton.selected) {
        if (self.loadMoreBlock) {
            self.loadMoreBlock();
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.topics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JAStoryTopicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JAStoryTopicCollectionViewCell class]) forIndexPath:indexPath];
    cell.data = self.topics[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectBlock) {
        self.selectBlock(self.topics[indexPath.item]);
    }
}

@end


//
//  JATimelineView.m
//  Jasmine
//
//  Created by xujin on 04/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JATimelineView.h"

@interface JATimelineCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, copy) NSString *timeString;

- (void)updateTimeString:(NSString *)timeString indexPath:(NSIndexPath *)indexPath;

@end

@implementation JATimelineCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *timeLabel = [UILabel new];
//        timeLabel.backgroundColor = [UIColor greenColor];
        timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        timeLabel.font = JA_REGULAR_FONT(12);
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.centerX.equalTo(self.mas_centerX);
            make.height.offset(17);
        }];
        self.timeLabel = timeLabel;
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = HEX_COLOR(0xd1d1d1);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.centerX.equalTo(self.mas_centerX);
            make.width.offset(1);
            make.height.offset(11);
        }];
        self.lineView = lineView;
        
        UIView *lowLineView = [UIView new];
        lowLineView.backgroundColor = HEX_COLOR(0xd1d1d1);
        [self addSubview:lowLineView];
        [lowLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.centerX.equalTo(self.mas_centerX);
            make.width.offset(1);
            make.height.offset(3);
        }];
    }
    return self;
}

- (void)updateTimeString:(NSString *)timeString indexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 5 == 0) {
        // 每5个显示时间
        self.timeLabel.text = timeString;
        self.lineView.hidden = NO;
        self.timeLabel.hidden = NO;
    } else {
        self.lineView.hidden = YES;
        self.timeLabel.hidden = YES;
    }
}

@end

@interface JATimelineView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *datasourceArray;

@end

@implementation JATimelineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _datasourceArray = [NSMutableArray array];
        for (int i=0; i<60*5+2; i++) {
            NSString *timeString = [NSString stringWithFormat:@"%02d:%02d",i/60,i%60];
            [_datasourceArray addObject:timeString];
        }
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    // 设置流水布局
    CGFloat itemWidth = 40;
    CGFloat itemHeight = 30;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(itemWidth, itemHeight);
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    CGRect rect = CGRectMake(0, 0, self.width, itemHeight);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flow];
    _collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[JATimelineCell class] forCellWithReuseIdentifier:@"JATimelineCellID"];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.userInteractionEnabled = NO;
    [self addSubview:collectionView];
}

- (void)updateTimeProgress {
    CGFloat offsetX = self.collectionView.contentOffset.x;
    CGFloat stride = 4;
    [self.collectionView setContentOffset:CGPointMake(offsetX+stride, 0) animated:NO];
}

- (void)resetTimeProgress {
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JATimelineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JATimelineCellID" forIndexPath:indexPath];
    [cell updateTimeString:self.datasourceArray[indexPath.item] indexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    
}

@end

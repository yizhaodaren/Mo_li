//
//  JAMayLikeView.m
//  Jasmine
//
//  Created by xujin on 2018/5/23.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAMayLikeView.h"
#import "JAAlbumModel.h"

@interface AlbumItem : UIView

//- (void)updateData:(JAAlbumModel *)data;

@end

@interface AlbumItem ()

@property (nonatomic, strong) UIImageView *albumImageView;
@property (nonatomic, strong) UILabel *albumLabel;
@property (nonatomic, strong) UILabel *playCountLabel;

- (void)updateData:(JAAlbumModel *)data;

@end

@implementation AlbumItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat itemW = frame.size.width;
        CGFloat itemH = WIDTH_ADAPTER(90);
        
        UIImageView *albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemW, itemH)];
//        albumImageView.backgroundColor = HEX_COLOR(JA_Line);
        albumImageView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
        albumImageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
        [self addSubview:albumImageView];
        self.albumImageView = albumImageView;
        
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemW, WIDTH_ADAPTER(40))];
        shadowImageView.image = [UIImage imageNamed:@"album_alphaCover"];
        [albumImageView addSubview:shadowImageView];
        shadowImageView.bottom = self.albumImageView.bottom;
        
        UIImageView *headsetIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        headsetIcon.image = [UIImage imageNamed:@"album_ear"];
//        headsetIcon.backgroundColor = [UIColor blueColor];
        [albumImageView addSubview:headsetIcon];
        headsetIcon.left = 5;
        headsetIcon.bottom = albumImageView.height-5;
        
        UILabel *playCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, itemW-5*3-20, 20)];
//        playCountLabel.backgroundColor = [UIColor greenColor];
        playCountLabel.font = JA_REGULAR_FONT(12);
        playCountLabel.textColor = HEX_COLOR(0xffffff);
        [albumImageView addSubview:playCountLabel];
        playCountLabel.left = headsetIcon.right+5;
        playCountLabel.bottom = headsetIcon.bottom;
        self.playCountLabel = playCountLabel;
//        self.playCountLabel.text = @"1.5w";
//        [self.playCountLabel sizeToFit];
        
        UILabel *albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, albumImageView.bottom+10, itemW, 0)];
//        albumLabel.backgroundColor = [UIColor redColor];
        albumLabel.font = JA_REGULAR_FONT(15);
        albumLabel.textColor = HEX_COLOR(JA_BlackTitle);
        albumLabel.numberOfLines = 2;
        [self addSubview:albumLabel];
        self.albumLabel = albumLabel;
//        self.albumLabel.text = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
//        [self.albumLabel sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.albumLabel.width = self.width;
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}

- (void)updateData:(JAAlbumModel *)data {
    int w = self.albumImageView.width;
    int h = self.albumImageView.height;
    NSString *url = [data.subjectThumb ja_getFitImageStringWidth:w height:h];
    [self.albumImageView ja_setImageWithURLStr:url];
    self.playCountLabel.text = [NSString convertCountStr:data.playCount];
    self.albumLabel.text = data.subjectName;
    [self.albumLabel sizeToFit];
}

@end

@interface JAMayLikeView ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIScrollView *downView;
@property (nonatomic, weak) UIButton *loadMoreButton;

@end

@implementation JAMayLikeView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        [self addSubview:upView];
        
        UIView *vlineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 3, 15)];
        vlineView.backgroundColor = HEX_COLOR(JA_Green);
//        vlineView.layer.cornerRadius = 1.0;
//        vlineView.layer.masksToBounds = YES;
        [upView addSubview:vlineView];
        vlineView.centerY = upView.height/2.0;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(vlineView.right+10, 0, 100, upView.height)];
        label.font = JA_REGULAR_FONT(15);
        label.textColor = HEX_COLOR(0x000000);
        [upView addSubview:label];
        label.text = @"猜你喜欢";
        
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
        
        CGFloat itemW = WIDTH_ADAPTER(113);
        CGFloat itemH = WIDTH_ADAPTER(90);
        CGFloat oneAlbumHeigh = itemH+10+42+10;
        CGFloat padding = (self.width-itemW*3-30)/2.0;
        UIScrollView *downView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, upView.bottom, self.width, oneAlbumHeigh)];
        _downView = downView;
        downView.showsHorizontalScrollIndicator = NO;
        downView.showsVerticalScrollIndicator = NO;
        downView.delegate = self;
        [self addSubview:downView];
        
        self.items = [NSMutableArray new];
        for (int i=0; i<10; i++) {
//            AlbumItem *bgView = [[AlbumItem alloc] initWithFrame:CGRectMake(15+(i%3)*(itemW+padding), i/3*oneAlbumHeigh, itemW, oneAlbumHeigh)];
             AlbumItem *bgView = [[AlbumItem alloc] initWithFrame:CGRectMake(15+(i)*(itemW+padding), 0, itemW, oneAlbumHeigh)];
            bgView.tag = i;
            [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeAlbumAction:)]];
            [downView addSubview:bgView];
//            bgView.hidden = YES;
            [self.items addObject:bgView];
        }
        
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
        loadMoreButton.height = itemH;
        loadMoreButton.y = 0;
        AlbumItem *bgView = self.items.lastObject;
        loadMoreButton.x = bgView.right;
        [loadMoreButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:3];
        [downView addSubview:loadMoreButton];
        
        self.height = 50+oneAlbumHeigh;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
        [self addSubview:lineView];
        lineView.bottom = self.bottom;
        [UIView drawLineOfDashByCAShapeLayer:lineView lineLength:3 lineSpacing:2 lineColor:HEX_COLOR(JA_Line) lineDirection:YES];
    }
    return self;
}

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    if (datas.count) {
        for (int i=0; i<self.items.count; i++) {
            AlbumItem *item = self.items[i];
            item.hidden = NO;
            if (i < datas.count) {
                [item updateData:datas[i]];
            } else {
                item.hidden = YES;
            }
        }
    }
    
    CGFloat itemW = WIDTH_ADAPTER(113);
    CGFloat padding = (self.width-itemW*3-30)/2.0;
    self.downView.contentSize = CGSizeMake(15+(datas.count)*(itemW+padding), 0);
    AlbumItem *bgView = self.items[datas.count-1];
    if (bgView.right > JA_SCREEN_WIDTH) {
        self.loadMoreButton.hidden = NO;
    }else{
        self.loadMoreButton.hidden = YES;
    }
    self.loadMoreButton.x = bgView.right;
}

- (void)seeAlbumAction:(UITapGestureRecognizer *)sender {
    if (self.seeAlbumBlock)
    {
        if (sender.view.tag < self.datas.count) {
            self.seeAlbumBlock(self.datas[sender.view.tag]);
        }
    }
}


- (void)moreAction
{
    if (self.moreBlock)
    {
        self.moreBlock();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat totalOff = scrollView.contentSize.width - self.downView.width;
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
        [self moreAction];
    }
}
@end

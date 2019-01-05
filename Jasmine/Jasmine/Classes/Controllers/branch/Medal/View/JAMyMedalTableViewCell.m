//
//  JAMyMedalTableViewCell.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/11.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMyMedalTableViewCell.h"

#import "JAMyMedalCollectionViewCell.h"


// Tooltips
#import "JDFTooltips.h"
@interface JAMyMedalTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

// Tooltips
@property (nonatomic, strong) JDFSequentialTooltipManager *tooltipManager;

@property(nonatomic,strong) JDFTooltipView *jdfToolTipView;

@property(nonatomic,assign) BOOL isShowing;
@end


@implementation JAMyMedalTableViewCell

- (void)awakeFromNib {
        [self initUI];
    [super awakeFromNib];

}
-(instancetype)init{
    
   return  [super init];
    
}
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//        if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//
//            [self initUI];
//        }
//    return self;
//}
-(void)initUI{
    
    self.backgroundColor =  HEX_COLOR(0xF9F9F9);
//    self.backgroundColor =   RGB_COLOR(247, 248, 247);

    
    self.tagView.backgroundColor =   HEX_COLOR(0x6bd379);//绿色
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    //medalCollectionView设置
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake((JA_SCREEN_WIDTH / 4) , (JA_SCREEN_WIDTH / 4) * 1.25);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
         self.medalCollectionView.collectionViewLayout = layout;
         self.medalCollectionView.delegate = self;
         self.medalCollectionView.dataSource = self;
         self.medalCollectionView.showsVerticalScrollIndicator = NO;
         self.medalCollectionView.showsHorizontalScrollIndicator = NO;
         self.medalCollectionView.backgroundColor = [UIColor whiteColor];
         self.medalCollectionView.layer.borderWidth = 0.5;
         self.medalCollectionView.layer.borderColor = [HEX_COLOR(0x9b9b9b) CGColor];
         self.medalCollectionView.layer.cornerRadius = 5;
         self.medalCollectionView.clipsToBounds = YES;
    
        [ self.medalCollectionView registerNib:[UINib nibWithNibName:@"JAMyMedalCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"JAMyMedalCollectionViewCell"];

}

-(void)setIndex:(NSInteger)index{
    _index = index;
    switch (index) {
        case 0:
            self.titleView.text = @"连续登录勋章";
            self.aboutButton.hidden = YES;
            break;
        case 1:
            self.titleView.text = @"邀请收徒勋章";
            self.aboutButton.hidden = YES;
            break;
        case 2:
            self.titleView.text = @"创作勋章";
            self.aboutButton.hidden = NO;
            [self.aboutButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeJFDview) name:@"removeJFDview" object:nil];
            break;
        default:
            break;
    }
}
-(void)buttonAction{
    if (!self.jdfToolTipView) {
        CGFloat tooltipWidth = 200.0f;//气泡宽度
        
        //创建气泡
        self.jdfToolTipView = [[JDFTooltipView alloc] initWithTargetView:self.aboutButton hostView:self.superController tooltipText:self.storyMedalRemindStr arrowDirection:JDFTooltipViewArrowDirectionUp width:tooltipWidth];
         //展示气泡
        [self.jdfToolTipView show];
         self.isShowing = YES;
    }else if (_isShowing){
          [self.jdfToolTipView hideAnimated:YES];
           self.jdfToolTipView = nil;
    }
}
-(void)removeJFDview{
    [self.jdfToolTipView hideAnimated:YES];
    self.jdfToolTipView = nil;
    _isShowing = NO;
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
#pragma mark CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionDataArray.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JAMyMedalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JAMyMedalCollectionViewCell" forIndexPath:indexPath];
    JAMedalModel *model = self.collectionDataArray[indexPath.row];
    if ([model.status isEqualToString:@"2"]) {
        if ([self.delegate respondsToSelector:@selector(updateMedalNameWith:)]) {
            [self.delegate updateMedalNameWith:model.medalName];
        }
    }
    cell.medalModel = model;

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    
    [self.delegate MyMedaLCollection:collectionView didSelectRowAtIndexPath:indexPath medal:self.collectionDataArray[indexPath.row]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeJFDview" object:nil];
       
}
-(void)setCollectionDataArray:(NSArray *)collectionDataArray{
    _collectionDataArray = collectionDataArray;
    [self.medalCollectionView reloadData];
}
@end

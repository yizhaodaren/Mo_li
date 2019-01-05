//
//  JAMyMedalTableViewCell.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/11.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMedalModel.h"
@protocol MyMedaLCollectionDelegate <NSObject>

@required
- (void)MyMedaLCollection:(UICollectionView *)collectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath medal:(JAMedalModel*)Medal;
-(void)updateMedalNameWith:(NSString *)medalName;
@end

@interface JAMyMedalTableViewCell : UITableViewCell

@property(nonatomic,assign) id<MyMedaLCollectionDelegate> delegate;

@property(nonatomic,strong) NSArray *collectionDataArray;//数据源
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,copy) NSString *storyMedalRemindStr;//问号弹出提示语

//@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) UIView *superController;
@property(nonatomic,strong) UIButton *button;

//UI
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
//@property (weak, nonatomic) IBOutlet UIView *collectionContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *medalCollectionView;

@end

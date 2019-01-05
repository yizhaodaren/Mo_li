//
//  JAMyMedalCollectionViewCell.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/11.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMedalModel.h"
@interface JAMyMedalCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) JAMedalModel *medalModel;//勋章模型
@property (weak, nonatomic) IBOutlet UIImageView *medalImageView;//勋章图标
@property (weak, nonatomic) IBOutlet UILabel *titleLable;//勋章名称
@property (weak, nonatomic) IBOutlet UILabel *detailLable;//获得条件
@property (weak, nonatomic) IBOutlet UILabel *showingTagLable;//佩戴标示

@end

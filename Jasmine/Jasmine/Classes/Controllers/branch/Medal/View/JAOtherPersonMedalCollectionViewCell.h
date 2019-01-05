//
//  JAOtherPersonMedalCollectionViewCell.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMedalModel.h"

@interface JAOtherPersonMedalCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong) JAMedalModel *medalModel;
@property (weak, nonatomic) IBOutlet UILabel *showingTagLable;
@property (weak, nonatomic) IBOutlet UIImageView *medalImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *detailLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@end

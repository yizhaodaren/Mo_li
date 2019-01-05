//
//  SFAttriLab.h
//  SFClickAbleLab
//
//  Created by Seven on 7/31/15.
//  Copyright (c) 2015 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TransIndexBlock) (NSInteger index);

@interface SFAttriLab : UILabel

@property (nonatomic, copy) TransIndexBlock transBlock;

@property (nonatomic, assign) CGFloat labHeight;
- (CFIndex)characterIndexAtPoint:(CGPoint)point;
+ (SFAttriLab *)attriLabInstanceWithInitialFrame:(CGRect)aFrame andFirstName:(NSString *)aName andContent:(NSString *)aContent;
- (void)clickcCharacterWithBlock:(TransIndexBlock)block;

@end

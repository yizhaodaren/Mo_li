//
//  JFImagePickerViewCell.m
//  JFImagePickerController
//
//  Created by Johnil on 15-7-3.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "JFImagePickerViewCell.h"
#import "JFAssetHelper.h"
#import "UIButton+ReversalAnimation.h"

@interface JFImagePickerViewCell ()

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end


@implementation JFImagePickerViewCell {
	UIView *placeholder;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
        [self addGestureRecognizer:tap];
        self.tap = tap;
    }
    return self;
}
- (void)setupSubviews
{
    // take photo view
    
    UIView *takePhotoView = [[UIView alloc] initWithFrame:self.bounds];
    takePhotoView.backgroundColor = RGB_COLOR(239, 239, 244);
    [self addSubview:takePhotoView];
    
    CGFloat x = (self.width - 25)/2;
    CGFloat y = (self.height - 21 - 5 - 17)/2;
    
    UIImageView *takePhotoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 25, 21)];
    takePhotoImgView.image = [UIImage imageNamed:@"share_takephoto"];
    [takePhotoView addSubview:takePhotoImgView];
    
    x = (self.width - 70)/2;
    y = takePhotoImgView.bottom + 5;
    UILabel *takePhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 70, 17)];
    takePhotoLabel.backgroundColor = [UIColor clearColor];
    takePhotoLabel.text = @"拍一张";
    takePhotoLabel.font = [UIFont systemFontOfSize:14];
    takePhotoLabel.textAlignment = NSTextAlignmentCenter;
    takePhotoLabel.textColor = [UIColor blackColor];
    [takePhotoView addSubview:takePhotoLabel];
    
    
    
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    placeholder = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 4, 26, 26)];
    placeholder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
    placeholder.layer.cornerRadius = 13;
    placeholder.layer.borderColor = [UIColor whiteColor].CGColor;
    placeholder.layer.borderWidth = 1;
    placeholder.userInteractionEnabled = NO;
    [self addSubview:placeholder];
    
}

- (void)selectOfNum:(NSInteger)num
{
	if (_numOfSelect == nil&&num!=-1)
    {
		placeholder.hidden = YES;
		_numOfSelect = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 4, 26, 26)];
		_numOfSelect.backgroundColor = [APP_COLOR colorWithAlphaComponent:.9];
		_numOfSelect.textAlignment = NSTextAlignmentCenter;
		_numOfSelect.textColor = [UIColor whiteColor];
        _numOfSelect.font = [UIFont systemFontOfSize:15];
		_numOfSelect.layer.cornerRadius = 13;
		_numOfSelect.layer.borderColor = [UIColor whiteColor].CGColor;
		_numOfSelect.layer.borderWidth = 1;
		_numOfSelect.clipsToBounds = YES;
		[self addSubview:_numOfSelect];
		_numOfSelect.text = @(num).stringValue;
		_numOfSelect.transform = CGAffineTransformMakeScale(.5, .5);
		[UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			_numOfSelect.transform = CGAffineTransformIdentity;
		} completion:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNum:) name:@"reloadNum" object:nil];
	}
    else
    {
        
        placeholder.hidden = NO;
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[_numOfSelect removeFromSuperview];
		_numOfSelect = nil;
	}
}
- (void)showTakePhoto
{
    placeholder.hidden = YES;
    _imageView.hidden = YES;
}
- (void)hideTakePhoto
{
    placeholder.hidden = NO;
    _imageView.hidden = NO;
}
- (void)removeFromSuperview
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super removeFromSuperview];
}

- (void)reloadNum:(NSNotification *)notifi
{
	for (NSDictionary *temp in ASSETHELPER.selectdPhotos)
    {
		if ([[[temp allKeys] firstObject] isEqualToString:[NSString stringWithFormat:@"%ld-%ld", (long)_indexPath.row, (long)ASSETHELPER.currentGroupIndex]]) {
			_numOfSelect.text = [[[temp allValues] firstObject] stringValue];
		}
	}
}

- (void)tapCell:(UITapGestureRecognizer *)tap
{
	CGPoint location = [tap locationInView:self];
	if (CGRectContainsPoint(CGRectMake(placeholder.frame.origin.x-5, placeholder.frame.origin.y-5, placeholder.frame.size.width+10, placeholder.frame.size.height+10), location))
    {
		if (self.numOfSelect==nil&&ASSETHELPER.selectdPhotos.count >= ASSETHELPER.maxCount)
        {
			return;
		}
		if (self.numOfSelect==nil)
        {
			[ASSETHELPER.selectdPhotos addObject:@{[NSString stringWithFormat:@"%ld-%ld",(long)_indexPath.row, (long)ASSETHELPER.currentGroupIndex]: @(ASSETHELPER.selectdPhotos.count+1)}];

			[ASSETHELPER.selectdAssets addObject:[ASSETHELPER getAssetAtIndex:_indexPath.row]];

			[self selectOfNum:ASSETHELPER.selectdPhotos.count];
		}
        else
        {
			NSInteger index = 0;
			NSInteger num = 0;
			for (NSDictionary *dict in ASSETHELPER.selectdPhotos)
            {
				if ([[[dict allKeys] firstObject] isEqualToString:[NSString stringWithFormat:@"%ld-%ld",(long)_indexPath.row, (long)ASSETHELPER.currentGroupIndex]])
                {
					index = [ASSETHELPER.selectdPhotos indexOfObject:dict];
					num = [[[dict allValues] firstObject] intValue];
				}
			}
			for (NSDictionary *dict in [ASSETHELPER.selectdPhotos copy])
            {
				if ([[[dict allValues] firstObject] intValue]>num)
                {
                    
					NSInteger index = [ASSETHELPER.selectdPhotos indexOfObject:dict];
					[ASSETHELPER.selectdPhotos removeObject:dict];
					[ASSETHELPER.selectdPhotos insertObject:@{[[dict allKeys] firstObject]: @([[[dict allValues] firstObject] intValue]-1)} atIndex:index];
				}
			}


			[ASSETHELPER.selectdAssets removeObjectAtIndex:index];
			[ASSETHELPER.selectdPhotos removeObjectAtIndex:index];
			[self selectOfNum:-1];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadNum" object:nil];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"selectdPhotos" object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"showNormalPhotoBrowser" object:_indexPath];
	}
}

@end

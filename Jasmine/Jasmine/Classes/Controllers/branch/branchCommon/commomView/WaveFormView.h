//
//  WaveFormView.h
//  PlayerDemo
//
//  Created by wzsam on 13-4-16.
//
//

#import <UIKit/UIKit.h>

@interface WaveFormView : UIView{
    //data
    CGPoint *mSampleData;
    int mSampleLength;
    float mProgress;
    
    CGFloat mDrawPixelIndex;
    NSInteger mDrawSampleIndex;
    
    UIImage *mContentImage;
    
    //ui
    UIColor *mMaskColor;
    UIColor *mDarkgrayColor;
}

@property(nonatomic, readonly)CGPoint *sampleData;
@property(nonatomic, readonly)int sampleLength;
@property(nonatomic, assign)float progress;
@property (nonatomic, strong)UIColor *maskColor;
@property (nonatomic, strong)UIColor *darkGrayColor;

- (void)setSampleData:(CGPoint *)sampleData length:(int)length;

- (void)clearWave;

@end

//
//  WaveFormView.m
//  PlayerDemo
//
//  Created by wzsam on 13-4-16.
//
//

#import "WaveFormView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WaveFormView

#define  kPixelsPerBlock 2.f

@synthesize progress = mProgress;
@synthesize maskColor = mMaskColor;
@synthesize darkGrayColor = mDarkgrayColor;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
                
        //mMaskColor = [[UIColor colorWithRed:242.0/255.0 green:97.0/255.0 blue:0.0/255.0 alpha:1.0]retain];
//        mMaskColor = [UIColor colorWithRed:255.0/255.0 green:0.f/255.0 blue:0.0/255.0 alpha:1.0];
        mMaskColor = HEX_COLOR(JA_Green);
        mDarkgrayColor = HEX_COLOR(JA_Line);

        mDrawPixelIndex = 0;
        mDrawSampleIndex = 0;
    }
    return self;
}

- (void)setSampleData:(CGPoint *)sampleData length:(int)length{
    mSampleData = sampleData;
//    mSampleLength = length;
    
    [self setNeedsDisplay];
}

- (void)clearWave {
    mProgress = 0.f;
    mDrawPixelIndex = 0;
    mDrawSampleIndex = 0;
    mContentImage = nil;
    [self setNeedsDisplay];
}


@end

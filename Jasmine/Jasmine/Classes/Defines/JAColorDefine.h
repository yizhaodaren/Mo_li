//
//  JAColorDefine.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#ifndef JAColorDefine_h
#define JAColorDefine_h

#define JA_Line 0xEDEDED
#define JA_Green 0x6BD379 
#define JA_Red 0xff4d4d
#define JA_Background 0xFFFFFF
#define JA_BoardLineColor 0xF9F9F9
#define JA_BtnGrounddColor 0xF5F5F5
#define JA_backGrayColor 0xEBEBEB

#define JA_BlackTitle 0x363636
#define JA_BlackSubTitle 0x9B9B9B
#define JA_BlackSubSubTitle 0xC6C6C6

#define JA_Title 0x525252
#define JA_Branch_Green 0x31C27C
#define JA_Three_Title 0x444444

#define JA_Blue_Title 0x576b95
#define JA_GrayColor 0x9C9CA4
#define JA_GaryTitle 0xC6C6CE
#define JA_ListTitle 0x5D5F6A
// 十六进制颜色值 使用：HEX_COLOR(0xf8f8f8)
#define HEX_COLOR_ALPHA(_HEX_,a) [UIColor colorWithRed:((float)((_HEX_ & 0xFF0000) >> 16))/255.0 green:((float)((_HEX_ & 0xFF00) >> 8))/255.0 blue:((float)(_HEX_ & 0xFF))/255.0 alpha:a]


#define HEX_COLOR(_HEX_) HEX_COLOR_ALPHA(_HEX_, 1.0)

#define HEX_COLOR_PERSONAL(_HEX_) HEX_COLOR_ALPHA(_HEX_, 0.8)


#define RGB_COLOR_ALPHA(r, g, b, a) [UIColor colorWithRed:(CGFloat)r/255.0f green:(CGFloat)g/255.0f blue:(CGFloat)b/255.0f alpha:a]
#define RGB_COLOR(r, g, b) RGB_COLOR_ALPHA(r, g, b, 1.0)

#endif /* JAColorDefine_h */

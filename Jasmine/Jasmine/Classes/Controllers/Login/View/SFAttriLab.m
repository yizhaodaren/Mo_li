//
//  SFAttriLab.m
//  SFClickAbleLab
//
//  Created by Seven on 7/31/15.
//  Copyright (c) 2015 Seven. All rights reserved.
//

#import "SFAttriLab.h"
#import <CoreText/CoreText.h>

#define kStrFontSize 13.0f

@interface SFAttriLab ()
{
@private
    NSString *_theStr;
    NSRange _firstRange;
    NSRange _secondRange;
    NSRange _thirdRange;
}

@end


@implementation SFAttriLab


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

+ (SFAttriLab *)attriLabInstanceWithInitialFrame:(CGRect)aFrame  andFirstName:(NSString *)aName andContent:(NSString *)aContent
{
    NSRange aRange = NSMakeRange(0, aName.length);
    SFAttriLab *attriLab = [[SFAttriLab alloc] init];
    NSString *finalContentStr = [aContent substringWithRange:NSMakeRange(aRange.length, aContent.length - aRange.length)];
    NSString *combinStr = [NSString stringWithFormat:@"%@%@",aName, finalContentStr];
    NSRange firstRange = NSRangeFromString([attriLab dealWithTheSpecificStr:combinStr andFirstNameRange:aRange][0]);
    NSRange secondRange = NSRangeFromString([attriLab dealWithTheSpecificStr:combinStr andFirstNameRange:aRange][1]);
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:combinStr];
    [attriStr addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:kStrFontSize]
                     range:NSMakeRange(0, attriStr.length)];
    
    [attriStr addAttribute:NSForegroundColorAttributeName
                     value:HEX_COLOR(JA_BlackSubTitle)
                     range:aRange];
    
    [attriStr addAttribute:NSForegroundColorAttributeName
                     value:HEX_COLOR(JA_BlackSubTitle)
                     range:firstRange];
    
    [attriStr addAttribute:NSForegroundColorAttributeName
                         value:HEX_COLOR(JA_Blue_Title)
                         range:secondRange];
    
    CGRect rects = [attriStr boundingRectWithSize:aFrame.size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    attriLab.frame = CGRectMake(aFrame.origin.x, aFrame.origin.y, aFrame.size.width, rects.size.height);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    [attriStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attriStr.length)];
    attriLab.attributedText = attriStr;
    attriLab.labHeight = rects.size.height;
    
    return attriLab;
}

//+ (SFAttriLab *)attriLabInstanceWithInitialFrame:(CGRect)aFrame leadingString:(NSString *)leadingStr andFirstName:(NSString *)aName middleStr:(NSString *)middleStr secondStr:(NSString *)secondStr andFinalStr:(NSString *)finalStr
//{
////    注册代表您已阅读或同意 茉莉使用协议 和隐私条款
//    NSRange aRange = NSMakeRange(0, aName.length);
//    SFAttriLab *attriLab = [[SFAttriLab alloc] init];
//    attriLab.numberOfLines = 0;
//    NSString *combinStr = [NSString stringWithFormat:@"%@%@%@%@%@",leadingStr, aName, middleStr, secondStr, finalStr];
//    NSRange firstRange = NSRangeFromString([attriLab dealWithTheSpecificStr:combinStr andFirstNameRange:aRange][0]);
//    NSRange secondRange = NSRangeFromString([attriLab dealWithTheSpecificStr:combinStr andFirstNameRange:aRange][1]);
//    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:combinStr];
//    [attriStr addAttribute:NSFontAttributeName
//                     value:[UIFont systemFontOfSize:kStrFontSize]
//                     range:NSMakeRange(0, attriStr.length)];
//    
//    [attriStr addAttribute:NSForegroundColorAttributeName
//                     value:[UIColor blueColor]
//                     range:aRange];
//    
//    [attriStr addAttribute:NSForegroundColorAttributeName
//                     value:[UIColor blueColor]
//                     range:firstRange];
//    
//    [attriStr addAttribute:NSForegroundColorAttributeName
//                     value:[UIColor blackColor]
//                     range:secondRange];
//    
//    CGRect rects = [attriStr boundingRectWithSize:aFrame.size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    attriLab.frame = CGRectMake(aFrame.origin.x, aFrame.origin.y, rects.size.width, rects.size.height);
//    [attriStr addAttribute:NSParagraphStyleAttributeName value:[NSParagraphStyle defaultParagraphStyle] range:NSMakeRange(0, attriStr.length)];
//    attriLab.attributedText = attriStr;
//    attriLab.labHeight = rects.size.height;
//    
//    return attriLab;
//}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    
    NSMutableAttributedString* optimizedAttributedText = [self.attributedText mutableCopy];
    
    [self.attributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
        
        if ([paragraphStyle lineBreakMode] == kCTLineBreakByTruncatingTail) {
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        }
        
        [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
        [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        
    }];
    
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRect];
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        CFRelease(framesetter);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // TODO: wait to edit
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);

//    NSLog(@"点击了第%ld个字符。。",idx);
    
    CFIndex index = 0;
    if (idx > _theStr.length) {
        index = NSNotFound;
    }else {
        if (idx < _firstRange.length) {
            index = 1;
        }else if (idx >= _secondRange.location && idx <= _secondRange.location + _secondRange.length) {
            index = 2;
        }else {
            index = NSNotFound;
        }
    }
    return index;
}

#pragma mark --

- (CGRect)textRect {
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    textRect.origin.y = (self.bounds.size.height - textRect.size.height)/2;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        textRect.origin.x = (self.bounds.size.width - textRect.size.width)/2;
    }
    if (self.textAlignment == NSTextAlignmentRight) {
        textRect.origin.x = self.bounds.size.width - textRect.size.width;
    }
    
    return textRect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSInteger index = [self characterIndexAtPoint:[touch locationInView:self]];
    if (self.transBlock) {
        self.transBlock(index);
    }
//    NSLog(@"点击第%ld个字",index);
}

- (void)clickcCharacterWithBlock:(TransIndexBlock)block
{
    self.transBlock = block;
}

// 返回 第二段与第三段的range
- (NSArray *)dealWithTheSpecificStr:(NSString *)aStr andFirstNameRange:(NSRange)aRange
{
    _firstRange = aRange;
    _theStr = aStr;
    _secondRange = [self obtainRangeFromPreRange:aRange WithTotalLength:aStr.length];
    
    NSString *firstRangeStr = NSStringFromRange(_firstRange);
    NSString *secondRangeStr = NSStringFromRange(_secondRange);
    NSArray *rangeArr = @[firstRangeStr,secondRangeStr];
    
    return rangeArr;
}

- (NSRange)obtainRangeFromPreRange:(NSRange)aRange WithTotalLength:(CGFloat)aLength
{
    NSRange needRange = NSMakeRange(aRange.location + aRange.length, aLength - aRange.location - aRange.length);
    return needRange;
}

- (NSString *)obtainCombinStrWithFirstStr:(NSString *)aStr andSecondStr:(NSString *)bStr
{
    NSString *combinStr = [NSString stringWithFormat:@"%@%@",aStr,bStr];
    return combinStr;
}

@end

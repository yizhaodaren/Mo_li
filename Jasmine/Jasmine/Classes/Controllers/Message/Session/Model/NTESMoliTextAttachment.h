//
//  NTESMoliTextAttachment.h
//  Jasmine
//
//  Created by xujin on 17/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachmentDefines.h"

@class M80AttributedLabel;
@interface NTESMoliTextAttachment : NSObject<NIMCustomAttachment,NTESCustomAttachmentInfo>

@property (nonatomic,copy) NSString *text;
@property (nonatomic, strong) M80AttributedLabel *label;

@end

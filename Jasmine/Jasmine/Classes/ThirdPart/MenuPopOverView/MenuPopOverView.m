//
//  MenuPopOverView.m
//  SearchBar
//
//  Created by Camel Yang on 4/1/14.
//  Copyright (c) 2014 camelcc. All rights reserved.
//

#import "MenuPopOverView.h"
#import "MenuPopOverButton.h"
// Geometry metrics
#define kPopOverViewPadding 20.f
#define kPopOverViewHeight 60.f
#define kPopOverCornerRadius 8.f
#define kButtonHeight 60.f
#define kLeftButtonWidth 30.f
#define kRightButtonWidth 30.f
#define kArrowHeight 9.5f
#define kTextFont [UIFont systemFontOfSize:11]
#define kTextEdgeInsets 10.f

// Customizable color
#define kDefaultBackgroundColor [UIColor whiteColor]
#define kDefaultHighlightedColor [UIColor lightGrayColor]
#define kDefaultSelectedColor [UIColor whiteColor]
#define kDefaultDividerColor HEX_COLOR(0xF4F1E7)
#define kDefaultTextColor [UIColor whiteColor]
#define kDefaultHighlightedTextColor [UIColor whiteColor]
#define kDefaultSelectedTextColor [UIColor blackColor]

@interface MenuPopOverView()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *buttons; // of MenuPopOverButton
@property (strong, nonatomic) NSMutableArray *pageButtons; // of NSArray for each page of UIButtons.
@property (strong, nonatomic) NSMutableArray *dividers; // of CGRect frame of dividers

@property (nonatomic) BOOL isArrowUp;
@property (nonatomic) CGPoint arrowPoint;
@property (nonatomic) CGRect boxFrame;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic) UIInterfaceOrientation lastInterfaceOrientation;

//- (void)didTapLeftArrowButton:(UIButton *)sender;
//- (void)didTapRightArrowButton:(UIButton *)sender;

@end


@implementation MenuPopOverView

-(instancetype)init {
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

-(void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withStrings:(NSArray *)stringArray selectImage:(NSArray *)selectImageArray image:(NSArray *)imageArray {
    [self presentPopoverFromRect:rect inView:view withStrings:stringArray selectedIndex:-1 selectImage:(NSArray *)selectImageArray image:(NSArray *)imageArray];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withStrings:(NSArray *)stringArray selectedIndex:(NSInteger)selectedIndex selectImage:(NSArray *)selectImageArray image:(NSArray *)imageArray {
    if ([stringArray count] == 0) {
        return;
    }
    
    // listen on device rotation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    _lastInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectZero];

    buttonContainer.backgroundColor = [UIColor clearColor];
    buttonContainer.clipsToBounds = YES;

    self.selectedIndex = selectedIndex;

    self.dividers = [[NSMutableArray alloc] init];
    self.buttons = [[NSMutableArray alloc] initWithCapacity:stringArray.count];

    // generate buttons for string array
    for (NSInteger i = 0; i < stringArray.count; i++) {
        NSString *string = stringArray[i];
        NSString *image = imageArray[i];
        NSString *selectImage = selectImageArray[i];
        CGSize textSize = [string sizeWithAttributes:@{NSFontAttributeName: kTextFont}];
        MenuPopOverButton *textButton = [[MenuPopOverButton alloc] initWithFrame:CGRectMake(0, 0, round(textSize.width + 2 * kTextEdgeInsets), kButtonHeight)];
        textButton.enabled = NO;
        textButton.selected = self.buttons.count == selectedIndex;
        textButton.backgroundColor = [UIColor whiteColor];
        textButton.titleLabel.font = kTextFont;
        [textButton setTitleColor:self.popOverTextColor forState:UIControlStateNormal];
        [textButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [textButton setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
//        [textButton setTitleColor:self.popOverHighlightedTextColor forState:UIControlStateHighlighted];
//        [textButton setTitleColor:self.popOverSelectedTextColor forState:UIControlStateSelected];
        textButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [textButton setTitle:string forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.buttons addObject:textButton];
    }
    
    // put these buttons into right position
    float totalWidth = [self reArrangeButtons:self.buttons];
    for (NSArray *btns in self.pageButtons) {
        for (UIButton *b in btns) {
            [buttonContainer addSubview:b];
        }
    }
    buttonContainer.frame = CGRectMake(0, 0, totalWidth, kButtonHeight);
    
    [self presentPopoverFromRect:rect inView:view withContentView:buttonContainer];
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view withContentView:(UIView *)cView {
    self.contentView = cView;
    
    [self setupLayout:rect inView:view];
    
    // Make the view small and transparent before animation
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
   
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (float)reArrangeButtons:(NSArray *)buttons {
    self.pageButtons = [[NSMutableArray alloc] init];
    _pageIndex = 0;
    
    CGRect screenBounds = [self currentScreenBoundsDependOnOrientation];
    float popoverMaxWidth = screenBounds.size.width - 2 * kPopOverViewPadding;
    
    // if we need multiple pages to display all these buttons
    float allButtonWidth = 0.f;
    for (UIButton *b in buttons) {
        allButtonWidth += b.frame.size.width;
    }
    allButtonWidth += ([buttons count] - 1); // dividers
    BOOL needMultiPage = ([buttons count] > 1 &&  allButtonWidth > popoverMaxWidth);
    
    // figure out which page each button belong to.
    NSMutableArray *firstButtons = [[NSMutableArray alloc]  init];
    if (needMultiPage) {
        float currentButtonsWidth = 0.f;
        for (UIButton *b in buttons) {
            currentButtonsWidth += b.frame.size.width;
            if (currentButtonsWidth > popoverMaxWidth - kRightButtonWidth) {
                if (b == [buttons firstObject]) {
                    currentButtonsWidth = b.frame.size.width + 1;
                } else {
                    [firstButtons addObject:b];
                    currentButtonsWidth = kLeftButtonWidth + 1 + b.frame.size.width + 1;
                }
            } else {
                currentButtonsWidth += 1; // 1 pixel divider
            }
        }
    }

    [self.dividers removeAllObjects];
    float currentX = 0.f;
   
        for (UIButton *b in buttons) {
            b.enabled = YES;
            b.frame = CGRectMake(currentX, 0, b.frame.size.width, b.frame.size.height);
            currentX += b.frame.size.width;
            
            if (b != [buttons lastObject]) {
                // add div between buttons
                CGRect div = CGRectMake(currentX, 0, 1, kButtonHeight);
                [self.dividers addObject:[NSValue valueWithCGRect:div]];
            }
        }
        
        [self.pageButtons addObject:buttons];
    
    
    return currentX;
}

//- (float)adjustButtonsFrame:(NSArray *)buttons withWidth:(float)totalWidth withXOrig:(float)xorig {
//    if ([buttons count] == 0) {
//        return xorig;
//    }
//    
//    if ([buttons count] == 1) {
//        UIButton *b = buttons.firstObject;
//        CGRect bf = b.frame;
//        bf.origin.x = xorig;
//        bf.size.width = totalWidth;
//        b.frame = bf;
//        return xorig + totalWidth;
//    }
//    
//    // get increment width for each button
//    float buttonsWidth = [buttons count] - 1; // 1 pixel dividers
//    for (UIButton *b in buttons) {
//        buttonsWidth += b.frame.size.width;
//    }
//    float incrementWidth = round(totalWidth - buttonsWidth)/[buttons count];
//    
//    // adjust frame
//    float currentX = xorig;
//    for (UIButton *b in buttons) {
//        CGRect bf = b.frame;
//        bf.origin.x = currentX;
//        bf.size.width += incrementWidth;
//        b.frame = bf;
//        currentX += bf.size.width;
//        
//        if (b != [buttons lastObject]) {
//            CGRect div = CGRectMake(currentX, bf.origin.y, 1, bf.size.height);
//            [self.dividers addObject:[NSValue valueWithCGRect:div]];
//            currentX += 1; // 1 pixel divider
//        }
//    }
//    
//    return xorig + totalWidth;
//}

-(void)setupLayout:(CGRect)rect inView:(UIView*)view {
    // get the top view
    // http://stackoverflow.com/questions/3843411/getting-reference-to-the-top-most-view-window-in-ios-application/8045804#8045804
    UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    
    CGRect screenBounds = [self currentScreenBoundsDependOnOrientation];
    float popoverMaxWidth = screenBounds.size.width - 2 * kPopOverViewPadding;

    // determine the arrow position
    CGRect topViewBounds = topView.bounds;
    CGPoint origin = [topView convertPoint:rect.origin fromView:view];
    CGRect destRect = CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
    CGFloat minY = CGRectGetMinY(destRect);
    CGFloat maxY = CGRectGetMaxY(destRect);
    
    // 1 pixel gap
    if (maxY + kPopOverViewHeight + 1 > CGRectGetMidY(topViewBounds)) {
        _isArrowUp = NO;
        _arrowPoint = CGPointMake(CGRectGetMidX(destRect), minY - 1);
    } else {
        _isArrowUp = YES;
        _arrowPoint = CGPointMake(CGRectGetMidX(destRect), maxY + 1);
    }
    
    float contentWidth = self.contentView.frame.size.width;
    float xOrigin = 0.f;
    
    //Make sure the arrow point is within the drawable bounds for the popover.
    if (_arrowPoint.x + kArrowHeight > topViewBounds.size.width - kPopOverViewPadding - kPopOverCornerRadius) {//Too right
        _arrowPoint.x = topViewBounds.size.width - kPopOverViewPadding - kPopOverCornerRadius - kArrowHeight;
        //NSLog(@"Correcting Arrow Point because it's too right");
    } else if (_arrowPoint.x - kArrowHeight < kPopOverViewPadding + kPopOverCornerRadius) {//Too left
        _arrowPoint.x = kPopOverViewPadding + kPopOverCornerRadius + kArrowHeight;
        //NSLog(@"Correcting Arrow Point because it's too far to the left");
    }
//    NSLog(@"arrowPoint:%f,%f", _arrowPoint.x, _arrowPoint.y);
    
    xOrigin = floorf(_arrowPoint.x - contentWidth*0.5f);
    //Check to see if the centered xOrigin value puts the box outside of the normal range.
    if (xOrigin < CGRectGetMinX(topViewBounds) + kPopOverViewPadding) {
        xOrigin = CGRectGetMinX(topViewBounds) + kPopOverViewPadding;
    } else if (xOrigin + contentWidth > CGRectGetMaxX(topViewBounds) - kPopOverViewPadding) {
        //Check to see if the positioning puts the box out of the window towards the left
        xOrigin = CGRectGetMaxX(topViewBounds) - kPopOverViewPadding - contentWidth;
    }
    
    CGRect contentFrame = CGRectZero;
    if (_isArrowUp) {
        _boxFrame = CGRectMake(xOrigin, _arrowPoint.y + kArrowHeight, MIN(contentWidth, popoverMaxWidth), kPopOverViewHeight - kArrowHeight);
        contentFrame = CGRectMake(xOrigin, _arrowPoint.y, contentWidth, kButtonHeight);
    } else {
        _boxFrame = CGRectMake(xOrigin, _arrowPoint.y - kPopOverViewHeight, MIN(contentWidth, popoverMaxWidth), kPopOverViewHeight - kArrowHeight);
        contentFrame = CGRectMake(xOrigin, _arrowPoint.y - kButtonHeight, contentWidth, kButtonHeight);
    }
    
//    NSLog(@"boxFrame:(%f,%f,%f,%f)", _boxFrame.origin.x, _boxFrame.origin.y, _boxFrame.size.width, _boxFrame.size.height);
    
    self.contentView.frame = contentFrame;
    
    //We set the anchorPoint here so the popover will "grow" out of the arrowPoint specified by the user.
    //You have to set the anchorPoint before setting the frame, because the anchorPoint property will
    //implicitly set the frame for the view, which we do not want.
    self.layer.anchorPoint = CGPointMake(_arrowPoint.x / topViewBounds.size.width, _arrowPoint.y / topViewBounds.size.height);
    self.frame = topViewBounds;
    [self setNeedsDisplay];
    
    [self addSubview:_contentView];
    [topView addSubview:self];
    
    
    //Add a tap gesture recognizer to the large invisible view (self), which will detect taps anywhere on the screen.
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//    tap.cancelsTouchesInView = NO; // Allow touches through to a UITableView or other touchable view, as suggested by Dimajp.
//    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

#pragma mark - Touch event recognize


- (void)didTapButton:(UIButton *)sender {
    for (UIButton *button in self.buttons) {
        button.selected = NO;
        button.backgroundColor = self.popOverBackgroundColor;
    }
    sender.selected = YES;
    sender.backgroundColor = self.popOverSelectedColor;

    NSUInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound && self.delegate && [self.delegate respondsToSelector:@selector(popoverView:didSelectItemAtIndex:button:)]) {
        [self.delegate popoverView:self didSelectItemAtIndex:index button:sender];
    }

    
//    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    void (^completion)(BOOL finished) = ^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
            [self.delegate popoverViewDidDismiss:self];
        }

        [self removeFromSuperview];
    };

    if (!animate) {
        completion(YES);
    } else {
        [UIView animateWithDuration:0.3f delay:0.15f options:0 animations:^{
            self.alpha = 0.1f;
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        } completion:completion];
    }
}


#pragma mark - rotation
- (void)onDeviceRotation:(NSNotification *)noti {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (_lastInterfaceOrientation == orientation ||
        (UIInterfaceOrientationIsPortrait(_lastInterfaceOrientation) &&
         UIInterfaceOrientationIsPortrait(orientation))) {
            return;
    }
    
    [self dismiss:NO];
}

- (CGRect)currentScreenBoundsDependOnOrientation
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}

#pragma mark - custom draw
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // Build the popover path
    CGRect frame = _boxFrame;
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    float radius = kPopOverCornerRadius; //Radius of the curvature.
    
    
    /*
     LT2            RT1
     LT1⌜⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⌝RT2
     |               |
     |    popover    |
     |               |
     LB2⌞_______________⌟RB1
     LB1           RB2
     
     Traverse rectangle in clockwise order, starting at LB2
     L = Left
     R = Right
     T = Top
     B = Bottom
     1,2 = order of traversal for any given corner
     */
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef bubblePath = CGPathCreateMutable();
    
    // Move to LB2
    CGPathMoveToPoint(bubblePath, NULL, xMin, yMax - radius);
    // Move to LT2
    CGPathAddArcToPoint(bubblePath, NULL, xMin, yMin, xMin + radius, yMin, radius);
    
    //If the popover is positioned below (!above) the arrowPoint, then we know that the arrow must be on the top of the popover.
    //In this case, the arrow is located between LT2 and RT1
    if (_isArrowUp) {
        // Move to left point of Arrow and draw Arrow
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x - kArrowHeight, yMin);
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x, _arrowPoint.y);
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x + kArrowHeight, yMin);
    }
    
    // Move to RT2
    CGPathAddArcToPoint(bubblePath, NULL, xMax, yMin, xMax, yMin + radius, radius);
    // Move to RB2
    CGPathAddArcToPoint(bubblePath, NULL, xMax, yMax, xMax - radius, yMax, radius);
    
    if (!_isArrowUp) {
        //Move to right point of Arrow and draw Arrow
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x + kArrowHeight, yMax);
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x, _arrowPoint.y);
        CGPathAddLineToPoint(bubblePath, NULL, _arrowPoint.x - kArrowHeight, yMax);
    }
    
    // Move to LB2
    CGPathAddArcToPoint(bubblePath, NULL, xMin, yMax, xMin, yMax - radius, radius);
    CGPathCloseSubpath(bubblePath);
    
    CGContextSaveGState(context);
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bubblePath;
    self.layer.mask = maskLayer;
    CGContextRestoreGState(context);
    
    //Draw the divider rects if we need to
    if (self.dividers && self.dividers.count > 0) {
        for (NSValue *value in self.dividers) {
            CGRect rect = value.CGRectValue;
            rect.origin.x += self.contentView.frame.origin.x;
            rect.origin.y += self.contentView.frame.origin.y;
            
            UIBezierPath *dividerPath = [UIBezierPath bezierPathWithRect:rect];
            [self.popOverDividerColor setFill];
            [dividerPath fill];
        }
    }

    // Add border if popOverBorderColor is set
//    if (self.popOverBorderColor) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = self.bounds;
        layer.path = bubblePath;
        layer.fillColor = nil;
        layer.lineWidth = 2;
        layer.strokeColor = HEX_COLOR(0xF4F1E7).CGColor;
        [self.layer addSublayer:layer];
        CFRelease(bubblePath);
//    }
}

#pragma mark - color getters

-(UIColor *)popOverBackgroundColor {
    if (_popOverBackgroundColor == nil) {
        return kDefaultBackgroundColor;
    }
    
    else {
        return _popOverBackgroundColor;
    }
}

// 文字高亮颜色
-(UIColor *)popOverHighlightedColor {
    if (_popOverHighlightedColor == nil) {
        return kDefaultHighlightedColor;
    }
    
    else {
        return _popOverHighlightedColor;
    }
}


// 选中文字颜色
-(UIColor *)popOverSelectedColor {
    if (_popOverSelectedColor == nil) {
        return kDefaultSelectedColor;
    }

    else {
        return _popOverSelectedColor;
    }
}

-(UIColor *)popOverDividerColor {
    if (_popOverDividerColor == nil) {
        
        return kDefaultDividerColor;
    }
    
    else {
        return _popOverDividerColor;
    }
}

// 文字默认颜色
-(UIColor *)popOverTextColor {
    if (_popOverTextColor == nil) {
        return HEX_COLOR(0x9C9CA4);
    }
    
    else {
        return _popOverTextColor;
    }
}

-(UIColor *)popOverHighlightedTextColor {
    if (_popOverHighlightedTextColor == nil) {
        return kDefaultHighlightedTextColor;
    }

    else {
        return _popOverHighlightedTextColor;
    }
}

-(UIColor *)popOverSelectedTextColor {
    if (_popOverSelectedTextColor == nil) {
        return kDefaultSelectedTextColor;
    }

    else {
        return _popOverSelectedTextColor;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_contentView.frame,point)) {
        
        self.userInteractionEnabled = YES;
    }else{
        self.userInteractionEnabled = NO;
    }
    
    return [super hitTest:point withEvent:event];
}
@end

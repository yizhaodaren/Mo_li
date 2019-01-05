//
//  JAEditInfoViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/24.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAEditInfoViewController.h"
#import "JABirthDayPickV.h"
//#import "JAPersonalApi.h"
#import "JAShareTextView.h"
#import "JAUserApiRequest.h"
#import "JAEditIconViewController.h"
#import "JAVoicePersonApi.h"
#import "WSDatePickerView.h"

static CGFloat const kLeadingGap = 12;
static CGFloat const kRowH = 55;

@interface JAEditInfoViewController ()<UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UIScrollView *scrollview;

@property (nonatomic, assign) BOOL isChange;
//@property (nonatomic, assign) BOOL isMale;
//@property (nonatomic, strong) NSDate *birthDay;
@property (nonatomic, strong) UITextField *nameT;
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *moliLabel;
@property (nonatomic, weak) UILabel *moliIDLabel;
@property (nonatomic, strong) UILabel *ageL;
@property (nonatomic, strong) UILabel *genderL;
@property (nonatomic, strong) JAShareTextView *signT;
@property (nonatomic, strong) UILabel *locationL;
@property (nonatomic, strong) UIView *bottomV;
@property (nonatomic, strong) NSString *ageStr;
@property (nonatomic, strong) NSString *constellationStr;
@property (nonatomic, strong) NSString *birthdayStr;
@property (nonatomic, assign) NSInteger sexValue;

@property (nonatomic, assign) BOOL changeName;

@end

@implementation JAEditInfoViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
 
    [self setCenterTitle:@"编辑资料"];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
    [self setNavRightTitle:@"保存" color:HEX_COLOR(JA_Green)];
    [self setNavigationBarColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyWillShowNote:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)onKeyWillShowNote:(NSNotification *)note{
    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [value CGRectValue];
    CGRect keyboardRectInkeyView = [self.view convertRect:rect fromView:nil];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        if (rect.origin.y == JA_SCREEN_HEIGHT) {
            self.scrollview.height = JA_SCREEN_HEIGHT-JA_StatusBarHeight-44;
        } else {
            self.scrollview.height = keyboardRectInkeyView.origin.y;
            
            [UIView animateWithDuration:0.3 animations:^{
                if ([self.nameT isFirstResponder]) {
                    self.scrollview.contentOffset = CGPointMake(0, self.nameT.y);
                }
                if ([self.signT isFirstResponder]) {
                    self.scrollview.contentOffset = CGPointMake(0, self.scrollview.contentSize.height-self.scrollview.height);
                }
            }];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"编辑资料";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)actionLeft
{
    BOOL edited = [self userEditInfo];
    if (edited) {  // 已经编辑过
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否保存修改？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self actionRight];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [super actionLeft];
        }];
        
        [alert addAction:action2];
        [alert addAction:action1];
        
        [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        
    }else{
        [super actionLeft];
    }
}

- (BOOL)userEditInfo
{
    NSString *nameStr = [self.nameT.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![self.model.name isEqualToString:nameStr]) {
        return YES;
    }
    
    if (![self.model.birthdayName isEqualToString:self.birthdayStr] && (self.model.birthdayName.length || self.birthdayStr.length)) {
        return YES;
    }
    
    if (self.model.sex.integerValue != self.sexValue && (self.model.sex.integerValue != 0 || self.sexValue != 0)) {
        return YES;
    }
    
    if (![self.model.introduce isEqualToString:self.signT.text] && (self.model.introduce.length || self.signT.text)) {
        return YES;
    }
    
    return NO;
}

- (void)actionRight
{
    // 获取昵称
    NSString *nameStr = [self.nameT.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!nameStr.length) {
        [self.view ja_makeToast:@"昵称不能为空"];
        return;
    }
    
    if (nameStr.length > 12) {
        [self.view ja_makeToast:@"昵称长度不能超过12个字符"];
        
        return;
    }

    // 发送网络请求 - 保存用户编辑资料
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (![self.model.name isEqualToString:nameStr]) {
        dic[@"name"] = nameStr;
        self.changeName = YES;
    }
    if (![self.model.birthdayName isEqualToString:self.birthdayStr] && ![self.ageL.text isEqualToString:@"未设置"]) {
    
        dic[@"age"] = self.ageStr;
        dic[@"constellation"] = self.constellationStr;
        dic[@"birthday"] = self.birthdayStr;
    }
    if (![self.model.introduce isEqualToString:self.signT.text] && self.signT.text.length) {
        dic[@"introduce"] = self.signT.text;
    }else if (!self.signT.text.length){
        dic[@"introduce"] = @"";
    }
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    if (self.model.sex.integerValue != self.sexValue) {
        dic[@"sex"] = @(self.sexValue);
    }
    
    [MBProgressHUD showMessage:nil];
    
    [[JAUserApiRequest shareInstance] perfectUserInfo:dic success:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUD];
        
        [self.view ja_makeToast:@"保存成功"];
        if (self.changeName) {
            self.changeName = NO;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_Name value:nameStr];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EDITUSERINFOSUCCESS object:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
       
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUD];
        

    }];
    
}

- (void)editGender{
    [self.view endEditing:YES];
    __weak JAEditInfoViewController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *maleAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        weakSelf.genderL.text = @"男";
        
        weakSelf.sexValue = 1;
    }];
    [alertController addAction:maleAction];
    UIAlertAction *femaleAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        weakSelf.genderL.text = @"女";
        weakSelf.sexValue = 2;
    }];
    [alertController addAction:femaleAction];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancel];

    [self presentViewController:alertController animated:YES completion:^{
        //====
    }];
}

- (void)editAge{
    [self.view endEditing:YES];
    
    NSString *currentString = [NSString dateToString:[NSDate date]];
    NSString *needString = [NSString stringWithFormat:@"1987%@",[currentString substringFromIndex:4]];
    
    NSDate *scrollToDate = [NSDate date:needString WithFormat:@"yyyy-MM-dd"];
    if (self.birthdayStr) {
        scrollToDate = [NSDate date:self.birthdayStr WithFormat:@"yyyy-MM-dd"];
    }
    
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:scrollToDate CompleteBlock:^(NSDate *selectDate) {
        
        if (selectDate) {

            NSString *dateStr = [NSString dateToString:selectDate];
            
            self.birthdayStr = dateStr;
            // 计算年龄
            NSString *age = [NSString ageWithDateString:dateStr];
            self.ageStr = age;
            
            // 星座
            NSString *constellation = [NSString constellationWithDateString:dateStr];
            self.constellationStr = constellation;
            
            self.ageL.text = self.birthdayStr;
//            [NSString stringWithFormat:@"%@  %@",age,constellation];
        }else{
            self.ageL.text = @"未设置";
        }
        
    }];
    //最大最小限制
    datepicker.maxLimitDate = [NSDate date:@"2005-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    
    //最小限制
    datepicker.minLimitDate = [self getminDate];
   
    datepicker.dateLabelColor = HEX_COLOR(0x000000);//年-月-日-时-分 颜色
    datepicker.datePickerColor = HEX_COLOR(0x000000);//滚轮日期颜色
    datepicker.doneButtonColor = HEX_COLOR(0xffffff);//确定按钮的颜色
    
    [datepicker show];

}

- (NSDate *)stringTodate:(NSString *)dateString
{
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:dateString];
    
    return date;
}

- (void)editIcon
{
    // 跳转编辑头像控制器
    JAEditIconViewController *vc = [[JAEditIconViewController alloc] init];
    vc.image = self.iconImageView.image;
    @WeakObj(self);
    vc.imageChangeBlock = ^(UIImage *image) {
        @StrongObj(self);
        self.iconImageView.image = image;
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}
//
//- (void)textFieldChanged:(NSNotification *)note{
//
//    self.isChange = YES;
//}

- (void)checkName:(UITextField *)field
{
    [[JAUserApiRequest shareInstance] checkUserNameWithName:field.text success:^{
        
    } failure:^{
        
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)setUpUI{
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollview = scrollview;
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
    self.scrollview.height = JA_SCREEN_HEIGHT-JA_StatusBarHeight-44;
//    self.scrollview.contentSize = CGSizeMake(0, self.scrollview.height + 1);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboared)];
    [scrollview addGestureRecognizer:tap];
    
    UILabel *iconlabel = [[UILabel alloc] init];
    iconlabel.text = @"头像";
    iconlabel.textColor = HEX_COLOR(0x9b9b9b);
    iconlabel.font = JA_REGULAR_FONT(14);
    iconlabel.x = kLeadingGap;
    iconlabel.width = 30;
    iconlabel.height = 55;
    [scrollview addSubview:iconlabel];
    
    UIImageView *iconImage = [[UIImageView alloc] init];
    [iconImage ja_setImageWithURLStr:self.model.image];
    _iconImageView = iconImage;
    iconImage.width = 40;
    iconImage.height = iconImage.width;
    iconImage.x = self.view.width - 40 - iconImage.width;
    iconImage.centerY = iconlabel.centerY;
    iconImage.layer.cornerRadius = iconImage.width * 0.5;
    iconImage.layer.masksToBounds = YES;
    [scrollview addSubview:iconImage];
    UIButton *iconBtn = [[UIButton alloc] initWithFrame:CGRectMake(iconlabel.right + kLeadingGap, 0, JA_SCREEN_WIDTH-kLeadingGap*2-iconlabel.right, kRowH)];
    [iconBtn setImage:[UIImage imageNamed:@"跳转按钮"] forState:UIControlStateNormal];
    iconBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [iconBtn addTarget:self action:@selector(editIcon) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:iconBtn];
    [self addSeparaterWithY:iconlabel.bottom];
    
    UILabel *nicklabel = [[UILabel alloc] init];
    nicklabel.text = @"昵称";
    nicklabel.textColor = HEX_COLOR(0x9b9b9b);
    nicklabel.font = JA_REGULAR_FONT(14);
    nicklabel.x = kLeadingGap;
    nicklabel.width = 30;
    nicklabel.height = 55;
    nicklabel.y = iconlabel.bottom;
    [scrollview addSubview:nicklabel];
    
    self.nameT = [[UITextField alloc] initWithFrame:CGRectMake(nicklabel.right + kLeadingGap, iconlabel.bottom, JA_SCREEN_WIDTH-kLeadingGap*2-nicklabel.right, kRowH)];
//    [self.nameT addTarget:self action:@selector(checkName:) forControlEvents:UIControlEventEditingDidEnd];
    self.nameT.textColor = HEX_COLOR(0x434343);
    self.nameT.font = JA_REGULAR_FONT(14);
    self.nameT.placeholder = @"请输入昵称";
    self.nameT.text = self.model.name;
    self.nameT.delegate = self;
    [scrollview addSubview:self.nameT];
    [self addSeparaterWithY:self.nameT.bottom];
    
    UILabel *molilabel = [[UILabel alloc] init];
    molilabel.text = @"ID:";
    molilabel.textColor = HEX_COLOR(0x9b9b9b);
    molilabel.font = JA_REGULAR_FONT(14);
    molilabel.x = kLeadingGap;
    molilabel.width = 30;
    molilabel.height = 55;
    molilabel.y = self.nameT.bottom;
    [scrollview addSubview:molilabel];
    
    UILabel *molilIDabel = [[UILabel alloc] initWithFrame:CGRectMake(molilabel.right + kLeadingGap, self.nameT.bottom, JA_SCREEN_WIDTH-kLeadingGap*2, kRowH)];
    _moliIDLabel = molilIDabel;
    molilIDabel.textColor = HEX_COLOR(0x444444);
    molilIDabel.font = JA_REGULAR_FONT(14);
    molilIDabel.text = self.model.uuid;
    molilIDabel.textColor = [UIColor lightGrayColor];
    [scrollview addSubview:molilIDabel];
    molilIDabel.height = kRowH;
    [self addSeparaterWithY:molilIDabel.bottom];
    
    UILabel *agelabel = [[UILabel alloc] init];
    agelabel.text = @"生日";
    agelabel.textColor = HEX_COLOR(0x9b9b9b);
    agelabel.font = JA_REGULAR_FONT(14);
    agelabel.x = kLeadingGap;
    agelabel.width = 30;
    agelabel.height = 55;
    agelabel.y = self.moliIDLabel.bottom;
    [scrollview addSubview:agelabel];
    
    self.ageL = [[UILabel alloc] initWithFrame:CGRectMake(agelabel.right + kLeadingGap, self.moliIDLabel.bottom, JA_SCREEN_WIDTH-kLeadingGap*2-agelabel.right, kRowH)];
    self.ageL.textColor = HEX_COLOR(0x434343);
    self.ageL.font = JA_REGULAR_FONT(14);
    if (self.model.birthdayName) {
        
        self.ageL.text = self.model.birthdayName;
//        [NSString stringWithFormat:@"%@  %@",self.model.age,self.model.constellation];
        self.ageStr = self.model.age;
        self.constellationStr = self.model.constellation;
        self.birthdayStr = self.model.birthdayName;
    }else{
        
        self.ageL.text = @"未设置";
    }
    [scrollview addSubview:self.ageL];
    UIButton *ageBtn = [[UIButton alloc] initWithFrame:self.ageL.frame];
    [ageBtn addTarget:self action:@selector(editAge) forControlEvents:UIControlEventTouchUpInside];
    [ageBtn setImage:[UIImage imageNamed:@"跳转按钮"] forState:UIControlStateNormal];
    ageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [scrollview addSubview:ageBtn];
    [self addSeparaterWithY:self.ageL.bottom];
    
    UILabel *sexlabel = [[UILabel alloc] init];
    sexlabel.text = @"性别";
    sexlabel.textColor = HEX_COLOR(0x9b9b9b);
    sexlabel.font = JA_REGULAR_FONT(14);
    sexlabel.x = kLeadingGap;
    sexlabel.width = 30;
    sexlabel.height = 55;
    sexlabel.y = self.ageL.bottom;
    [scrollview addSubview:sexlabel];
    
    self.genderL = [[UILabel alloc] initWithFrame:CGRectMake(sexlabel.right + kLeadingGap, self.ageL.bottom, JA_SCREEN_WIDTH-kLeadingGap*2-sexlabel.right, kRowH)];
    self.genderL.textColor = HEX_COLOR(JA_Title);
    self.genderL.font = JA_REGULAR_FONT(14);
    if (self.model.sex.integerValue == 1) {
        
        self.genderL.text = @"男";
    }else if (self.model.sex.integerValue == 2){
        self.genderL.text = @"女";
    }else{
        self.genderL.text = @"未设置";
    }
    self.sexValue = self.model.sex.integerValue;
    [scrollview addSubview:self.genderL];
    UIButton *genderBtn = [[UIButton alloc] initWithFrame:self.genderL.frame];
    [genderBtn setImage:[UIImage imageNamed:@"跳转按钮"] forState:UIControlStateNormal];
    genderBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [genderBtn addTarget:self action:@selector(editGender) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:genderBtn];
    [self addSeparaterWithY:self.genderL.bottom];
    
    UILabel *arealabel = [[UILabel alloc] init];
    arealabel.text = @"城市";
    arealabel.textColor = HEX_COLOR(0x9b9b9b);
    arealabel.font = JA_REGULAR_FONT(14);
    arealabel.x = kLeadingGap;
    arealabel.width = 30;
    arealabel.height = 55;
    arealabel.y = self.genderL.bottom;
    [scrollview addSubview:arealabel];
    
    UILabel *locationL = [[UILabel alloc] initWithFrame:CGRectMake(arealabel.right + kLeadingGap, self.genderL.bottom, JA_SCREEN_WIDTH-kLeadingGap*2, kRowH)];
    _locationL = locationL;
    locationL.textColor = HEX_COLOR(0x444444);
    locationL.font = JA_REGULAR_FONT(14);
    locationL.text = self.model.address.length ? self.model.address : @"火星";
    locationL.textColor = [UIColor lightGrayColor];
    [scrollview addSubview:locationL];
    locationL.height = kRowH;
    [self addSeparaterWithY:locationL.bottom];
    
    
    UILabel *instroducelabel = [[UILabel alloc] init];
    instroducelabel.text = @"签名";
    instroducelabel.textColor = HEX_COLOR(0x9b9b9b);
    instroducelabel.font = JA_REGULAR_FONT(14);
    instroducelabel.x = kLeadingGap;
    instroducelabel.width = 30;
    instroducelabel.height = 55;
    instroducelabel.y = self.locationL.bottom;
    [scrollview addSubview:instroducelabel];
    
    self.signT = [[JAShareTextView alloc] initWithFrame:CGRectMake(instroducelabel.right + kLeadingGap - 4, locationL.bottom + kLeadingGap - 1, JA_SCREEN_WIDTH-kLeadingGap*2 - instroducelabel.right, kRowH)];
    
    self.signT.textColor = HEX_COLOR(0x434343);
    self.signT.font = JA_REGULAR_FONT(14);
    self.signT.myPlaceholder = @"添加个性签名";
    self.signT.maxContentLength = 100;
    self.signT.text = self.model.introduce;
    self.signT.delegate = self;
    [scrollview addSubview:self.signT];
    
    self.bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, self.signT.bottom, JA_SCREEN_WIDTH, 1)];
    self.bottomV.backgroundColor = HEX_COLOR(JA_Line);
    [scrollview addSubview:self.bottomV];
    
    self.scrollview.contentSize = CGSizeMake(0, self.bottomV.bottom + 1);

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.nameT];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.signT];
}


- (void)addSeparaterWithY:(CGFloat)y{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, y, JA_SCREEN_WIDTH-10, .5)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    [self.scrollview addSubview:line];
}

// 中英文字符长度
- (NSInteger)caculaterName:(NSString *)name
{
    NSInteger length = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    length -= (length - name.length) / 2;
    //    length = (length +1) / 2;
    return length;
}

- (NSDate *)getminDate
{
    
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeInterval time = 80.0 * 365 * 24 * 60 * 60;//80年的秒数
    
    NSDate * lastYear = [date dateByAddingTimeInterval:-time];
    
    return lastYear;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollview.contentOffset = CGPointMake(0, self.nameT.y);
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollview.contentOffset = CGPointMake(0, self.scrollview.contentSize.height-self.scrollview.height);
    }];
}

@end

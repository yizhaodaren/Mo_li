//
//  NSObject+Extention.m
//  iTrends
//
//  Created by wujin on 12-8-29.
//
//

#import "NSObject+Extention.h"
#import <objc/runtime.h>
#import "NSDictionary+Extention.h"
#import "NSString+Extention.h"

//NSString * const kAssociatedObjectKey=@"associatedobjectkey-234242";
//NSString * const kAssociatedObjectRetainKey=@"associatedobjectretainkey-235424";

static char kAssociatedObjectRetainKey;
static char kAssociatedObjectKey;

@implementation NSObject (Extention)

/**
 获取关联的一个参数对象
 此对象会被 retain一次，
 此对象会在dealloc的时候释放，所以请注意不要发生retinCycle
 */
-(void)setAssociatedObjectRetain:(id)object
{
    objc_setAssociatedObject(self, &kAssociatedObjectRetainKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)associatedObjectRetain
{
    return objc_getAssociatedObject(self, &kAssociatedObjectRetainKey);
}

/**
 获取关联的一个参数对象
 此对象不会被 retain，只是一个弱引用
 */
-(void)setAssociatedObject:(id)object
{
    objc_setAssociatedObject(self, &kAssociatedObjectKey, object, OBJC_ASSOCIATION_ASSIGN);
}
-(id)associatedObject
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}

- (NSString *)YCJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
}

#pragma mark - NSObject And NSDictionary convert
- (NSDictionary *)infoDictionary
{
    return nil;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [self init]) {
        u_int    count;

        objc_property_t* properties= class_copyPropertyList([self class], &count);
        for (int i = 0; i < count ; i++)
        {
            objc_property_t property = properties[i];
            const char* propertyName = property_getName(property);
            //nsobject类中属性名为声明的默认存取器名前加"_"
            Ivar ivar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%s",propertyName] UTF8String]);
            if (ivar == nil) {
                continue;
            }
            const char *typeEncode = ivar_getTypeEncoding(ivar);
            NSString *typeEncodeStr = [NSString stringWithCString:typeEncode encoding:NSUTF8StringEncoding];
            NSString *propertyNameStr = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            NSString *campPropertyName = [propertyNameStr capitalizedStringWithoutChangeOtherCharacter];
            id value = [dict objectForKeyWithNilForNull:campPropertyName];
            
            //如果没有对应的值，直接寻找下一个
            if (value == nil) {
                continue;
            }
            
            //TODO:内置类型仅支持int，float，BOOL
            if ([typeEncodeStr hasPrefix:@"@"] && typeEncodeStr.length ==1) {
                //id 类型直接设值
                
               [self setValue:value forKey:propertyNameStr];
            }
            else if ([typeEncodeStr hasPrefix:@"@"] && typeEncodeStr.length > 1)
            {
                //只有是同一类型的才赋值
              
                
                Class class = NSClassFromString([typeEncodeStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]]);
                if ([value isKindOfClass:class]) {
                    [self setValue:value forKey:propertyNameStr];

                }
            }
            else if ([typeEncodeStr hasPrefix:@"i"])
            {
                if ([value respondsToSelector:@selector(intValue)]) {
                    int intValue = [value intValue];
                    [self setValue:[NSNumber numberWithInt:intValue] forKey:propertyNameStr];
                }
            }
            else if ([typeEncodeStr hasPrefix:@"d"])
            {
                if ([value respondsToSelector:@selector(floatValue)]) {
                    float floatValue = [value floatValue];
                    [self setValue:[NSNumber numberWithFloat:floatValue] forKey:propertyNameStr];
                }
            }
            else if ([typeEncodeStr hasPrefix:@"B"])
            {
                if ([value respondsToSelector:@selector(boolValue)]) {
                    BOOL boolValue = [value boolValue];
                    [self setValue:[NSNumber numberWithBool:boolValue] forKey:propertyNameStr];
                }
            }else if ([typeEncodeStr hasPrefix:@"q"])
            {
                if ([value respondsToSelector:@selector(stringValue)]) {
                    [self setValue:[value stringValue] forKey:propertyNameStr];
                }
            }        }
        free(properties);
    }
    
    return self;
}


- (NSDictionary *)dictionary
{
    //TODO:yangxu 设置
    return nil;
}

- (void)updateWithDict:(NSDictionary *)dict
{
    //TODO:yangxu 以后编写
}

@end

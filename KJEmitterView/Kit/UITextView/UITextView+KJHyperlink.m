//
//  UITextView+KJHyperlink.m
//  KJEmitterView
//
//  Created by 杨科军 on 2019/12/4.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "UITextView+KJHyperlink.h"
#import <objc/runtime.h>

@interface UITextView ()<UITextViewDelegate>
@property(nonatomic,copy,readwrite) KJTextViewURLHyperlinkBlock xxblock;
@property(nonatomic,copy) NSArray *URLTemps;
@end

@implementation UITextView (KJHyperlink)

- (KJTextViewURLHyperlinkBlock)xxblock{
    return objc_getAssociatedObject(self, @selector(xxblock));
}
- (void)setXxblock:(KJTextViewURLHyperlinkBlock)xxblock{
    objc_setAssociatedObject(self, @selector(xxblock), xxblock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray*)URLTemps{
    return objc_getAssociatedObject(self, @selector(URLTemps));
}
- (void)setURLTemps:(NSArray*)URLTemps{
    objc_setAssociatedObject(self, @selector(URLTemps), URLTemps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**识别点击TextView里面的超链接网址地址
 备注事项：
 1、里面实现了委托UITextViewDelegate，外界再用会失效
 2、需要在调用此方法之前设置text内容 self.textView.text = @"xxxx";
 3、关闭了text的编辑功能
 4、默认URL地址颜色为蓝色
 */
- (void)kj_clickTextViewURLCustom:(URLCustom)custom URLHyperlink:(KJTextViewURLHyperlinkBlock)block{
    self.xxblock  = block;
    self.delegate = self;
    self.editable = NO; /// 关闭编辑
    UIColor *color = custom.color?:UIColor.blueColor;
    UIFont  *font = custom.font?:self.font;
    NSString *str = self.text;
    NSArray *array = getURLWithText(str);
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableAttributedString *abs = [[NSMutableAttributedString alloc]initWithString:str];
    [abs beginEditing];
    self.linkTextAttributes = @{}; /// 解决设置NSLinkAttributeName字体颜色无效的处理
    //字体大小
    [abs addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0,str.length)];
    for (NSInteger i=0; i<array.count; i++) {
        NSValue *customValue = array[i];
        struct kURLBody value;
        [customValue getValue:&value];
        [temp addObject:[NSString stringWithCString:value.charURLString encoding:NSUTF8StringEncoding]];
        //点击传值
        [abs addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"%ld",i] range:value.range];
        //字体颜色
        [abs addAttribute:NSForegroundColorAttributeName value:color range:value.range];
        //字体大小
        [abs addAttribute:NSFontAttributeName value:font range:value.range];
    }
    self.URLTemps = temp.copy;
    array = temp = nil;
    self.attributedText = abs;
}

// 定义网址结构体类型
struct kURLBody {
    char *charURLString;
    NSRange range;
};
/// IOS 正则表达式匹配文本中URL位置并获取URL所在位置
static inline NSArray * getURLWithText(NSString *string) {
    NSError *error;
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSTextCheckingResult *match in array) {
        NSString *substring = [string substringWithRange:match.range];
        struct kURLBody URL = {(char*)[substring UTF8String],match.range};
        NSValue *value = [NSValue value:&URL withObjCType:@encode(struct kURLBody)];
        [temp addObject:value];
    }
    return temp.copy;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView*)textView shouldInteractWithURL:(NSURL*)URL inRange:(NSRange)characterRange {
    NSInteger i = [URL.absoluteString integerValue];
    NSString *url = self.URLTemps[i];
    !self.xxblock?:self.xxblock(url);
    return YES;
}

@end

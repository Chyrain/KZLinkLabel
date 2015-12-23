//
//  NSAttributedString+Emotion.m
//  LinkTest
//
//  Created by joywii on 14/12/9.
//  Edit by chyrain on 15/12/23.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "NSAttributedString+Emotion.h"

@implementation KZTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    //return CGRectMake( 0 , 0 , lineFrag.size.height + 6, lineFrag.size.height + 6);
    return CGRectMake( 0 , -5, 20, 20);
}
@end

@implementation NSAttributedString (Emotion)

//--------------------------------------实例方法-----------------------------------------------------
/*
 * 返回绘制NSAttributedString所需要的区域
 */
- (CGRect)boundsWithSize:(CGSize)size {
    CGRect contentRect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];//NSStringDrawingUsesLineFragmentOrigin
    return contentRect;
}

//--------------------------------------静态方法-----------------------------------------------------
/*
 * 返回绘制文本需要的区域
 */
+ (CGRect)boundsForString:(NSString *)string size:(CGSize)size attributes:(NSDictionary *)attrs {
    NSAttributedString *attributedString = [NSAttributedString emotionAttributedStringFrom:string attributes:attrs];
    CGRect contentRect = [attributedString boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return contentRect;
}

/*
 * 返回Emotion替换过的 NSAttributedString
 */
+ (NSAttributedString *)emotionAttributedStringFrom:(NSString *)string attributes:(NSDictionary *)attrs {
    NSMutableAttributedString *attributedEmotionString = [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
    
    // 表情替换
    NSArray *attachmentArray = [NSAttributedString attachmentsForAttributedString:attributedEmotionString];
    NSInteger lengthChange = 0;
    for (KZTextAttachment *attachment in attachmentArray) {
        NSAttributedString *emotionAttachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange newRange = NSMakeRange(attachment.range.location - lengthChange, attachment.range.length);
        lengthChange = lengthChange + attachment.range.length - emotionAttachmentString.length;
        [attributedEmotionString replaceCharactersInRange:newRange withAttributedString:emotionAttachmentString];
    }
    
    return attributedEmotionString;
}

+(NSDictionary *)getFaceMap {
    static NSDictionary * dic=nil;
    if(dic == nil) {
        NSString* path=[[NSBundle mainBundle] pathForResource:@"v5_qface" ofType:@"plist"];
        dic =[NSDictionary dictionaryWithContentsOfFile:path];
    }
    return dic;
}

/*
 * 查找所有表情文本并替换
 */
+ (NSArray *)attachmentsForAttributedString:(NSMutableAttributedString *)attributedString {
    NSString *string      = attributedString.string;
    NSMutableArray *array = [NSMutableArray array];
    // 微信QQ表情符号正则式
    NSString *pattern = @"/::\\)|/::~|/::B|/::\\||/:8-\\)|/::<|/::\\$|/::X|/::Z|/::'\\(|/::-\\||/::@|/::P|/::D|/::O|/::\\(|/::\\+|/:--b|/::Q|/::T|/:,@P|/:,@-D|/::d|/:,@o|/::g|/:\\|-\\)|/::!|/::L|/::>|/::,@|/:,@f|/::-S|/:\\?|/:,@x|/:,@@|/::8|/:,@!|/:!!!|/:xx|/:bye|/:wipe|/:dig|/:handclap|/:&-\\(|/:B-\\)|/:<@|/:@>|/::-O|/:>-\\||/:P-\\(|/::'\\||/:X-\\)|/::\\*|/:@x|/:8\\*|/:pd|/:<W>|/:beer|/:basketb|/:oo|/:coffee|/:eat|/:pig|/:rose|/:fade|/:showlove|/:heart|/:break|/:cake|/:li|/:bome|/:kn|/:footb|/:ladybug|/:shit|/:moon|/:sun|/:gift|/:hug|/:strong|/:weak|/:share|/:v|/:@\\)|/:jj|/:@@|/:bad|/:lvu|/:no|/:ok|/:love|/:<L>|/:jump|/:shake|/:<O>|/:circle|/:kotow|/:turn|/:skip|/:oY|/:#-0|/:hiphot|/:kiss|/:<&|/:&>";
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, string.length)];
    
    for (NSTextCheckingResult *result in matches) {
        KZTextAttachment *attachment = [[KZTextAttachment alloc] initWithData:nil ofType:nil];
        attachment.range = result.range;
        NSString *emojiStr = [[self getFaceMap] objectForKey:[string substringWithRange:result.range]];
        
        attachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", emojiStr]];
        [array addObject:attachment];
    }
    return array;
}
@end

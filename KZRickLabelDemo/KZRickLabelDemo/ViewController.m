//
//  ViewController.m
//  KZRickLabelDemo
//
//  Created by joywii on 14/12/9.
//
//

#import "ViewController.h"
#import "KZLinkLabel.h"

#define kScreenHeight         [UIScreen mainScreen].bounds.size.height
#define kScreenWidth          [UIScreen mainScreen].bounds.size.width

@interface ViewController () <UIActionSheetDelegate>

@property (nonatomic,strong) NSDictionary *selectedLinkDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSString *emojiString = @"<a href=\"http://www.baidu.com\" _target=\"_blank\">百度一下</a>http://www.hao123.com 哈哈an example:15701669932.哈哈.13888888888;哈哈哈哈哈 http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights/18746930#18746930表情/::)/::)<a href=\"http://www.baidu.com\" _target=\"_blank\">百度一下</a>";
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font, // 字体
                                 NSBackgroundColorAttributeName: [UIColor clearColor] // 背景颜色
                                 };
    NSAttributedString *attributedString = [NSAttributedString emotionAttributedStringFrom:emojiString attributes:attributes];
    
    KZLinkLabel *kzLabel = [[KZLinkLabel alloc] init];
    kzLabel.automaticLinkDetectionEnabled = YES;
    kzLabel.font = [UIFont systemFontOfSize:18];
    kzLabel.backgroundColor = [UIColor clearColor];
    kzLabel.textColor = [UIColor grayColor];
    kzLabel.numberOfLines = 0;
    kzLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    kzLabel.linkColor = [UIColor colorWithRed:0/255.0 green:240/255.0 blue:255/255.0 alpha:1.0];
    kzLabel.linkHighlightColor = [UIColor orangeColor];
    kzLabel.attributedText = attributedString;
    
    // 实际frame大小
    CGRect attributeRect = [kzLabel.KZAttributedString boundsWithSize:CGSizeMake(kScreenWidth - 30, CGFLOAT_MAX)];
    kzLabel.frame = CGRectMake(15, 40, kScreenWidth - 30, attributeRect.size.height);
    [kzLabel sizeToFit];
    
    [self.view addSubview:kzLabel];
    
    kzLabel.linkTapHandler = ^(KZLinkType linkType, NSString *string, NSRange range){
        if (linkType == KZLinkTypeURL) {
            [self openURL:[NSURL URLWithString:string]];
        } else if (linkType == KZLinkTypePhoneNumber) {
            [self openTel:string];
        } else {
            NSLog(@"Other Link: %@", string);
        }
    };
    kzLabel.linkLongPressHandler = ^(KZLinkType linkType, NSString *string, NSRange range){
        NSMutableDictionary *linkDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        [linkDictionary setObject:@(linkType) forKey:@"linkType"];
        [linkDictionary setObject:string forKey:@"link"];
        [linkDictionary setObject:[NSValue valueWithRange:range] forKey:@"range"];
        self.selectedLinkDic = linkDictionary;
        
        NSString *openTypeString;
        if (linkType == KZLinkTypeURL) {
            openTypeString = @"在Safari中打开";
        } else if (linkType == KZLinkTypePhoneNumber) {
            openTypeString = @"直接拨打";
        }
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"拷贝",openTypeString, nil];
        [sheet showInView:self.view];
    };
}
- (BOOL)openURL:(NSURL *)url
{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)openTel:(NSString *)tel
{
    NSString *telString = [NSString stringWithFormat:@"tel://%@",tel];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telString]];
}
#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.selectedLinkDic) {
        return;
    }
    switch (buttonIndex)
    {
        case 0:
        {
            [UIPasteboard generalPasteboard].string = self.selectedLinkDic[@"link"];
            break;
        }
        case 1:
        {
            KZLinkType linkType = [self.selectedLinkDic[@"linkType"] integerValue];
            if (linkType == KZLinkTypeURL) {
                NSURL *url = [NSURL URLWithString:self.selectedLinkDic[@"link"]];
                [self openURL:url];
            } else if (linkType == KZLinkTypePhoneNumber) {
                [self openTel:self.selectedLinkDic[@"link"]];
            }
            break;
        }
    }
}

@end

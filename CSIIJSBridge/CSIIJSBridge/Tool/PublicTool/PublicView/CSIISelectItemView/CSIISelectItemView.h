//
//  CSIISelectItemView.h
//  CSIIJSBridge
//
//  Created by 松 on 2021/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIISelectItemView : UIView

@property(nonatomic,copy)void (^FinishClick)(NSString *jsonStr);


- (instancetype)initWithTextArray:(NSArray *)array Title:(NSString *)title;

- (void)showDateTimePickerView;

@end

NS_ASSUME_NONNULL_END

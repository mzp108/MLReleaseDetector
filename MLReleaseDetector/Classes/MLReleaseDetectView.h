//
//  MLReleaseDetectView.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLReleaseDetectView : NSObject

@property (nonatomic, weak, readonly) UIView * rootView;
@property (nonatomic, copy, readonly) NSString * rootViewClassString;
@property (nonatomic, copy) NSString * rootViewControllerClassString;
@property (nonatomic, strong, readonly) NSArray * subReleaseDetectViews;

- (instancetype)initWithRootView:(UIView *)rootView;

- (NSString *)getLeakMsg;

@end

NS_ASSUME_NONNULL_END

//
//  UIViewController+MLReleaseDetect.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (MLReleaseDetect)

+ (void)startReleaseDetect;

// The subViewController will do the release detection when self is released
- (void)addSubViewController:(UIViewController *)subViewController;

@end

NS_ASSUME_NONNULL_END

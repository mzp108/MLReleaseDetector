//
//  MLReleaseDetector.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>
#import "MLTypeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLReleaseDetector : NSObject

/// Start release detect.
/// @param whiteList Classes in the whiteList will not do release detection.
/// @param leakCallback Called when a potential leak object is detected.
+ (void)startupWithWhiteList:(NSArray<NSString *> *)whiteList leakCallback:(MLLeakCallback)leakCallback;

/// The subViewController will do the release detection when mainViewController is released.
/// Note: You don't need to call this method if addChildViewController is called.
/// @param subViewController The subViewController.
/// @param mainViewController The mainViewController.
+ (void)addSubViewController:(UIViewController *)subViewController forMainViewController:(UIViewController *)mainViewController;

@end

NS_ASSUME_NONNULL_END

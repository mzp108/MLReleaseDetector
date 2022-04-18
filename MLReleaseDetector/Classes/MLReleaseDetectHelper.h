//
//  MLReleaseDetectHelper.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>
#import "MLTypeDefine.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLReleaseDetectHelper : NSObject

+ (NSPointerArray *)getAliveViewControllers;
+ (void)addAliveViewController:(UIViewController *)viewController;

+ (NSSet<NSString *> *)getWhiteListSet;
+ (void)addWhiteList:(NSArray<NSString *> *)whiteList;
+ (void)showAlert:(NSString *)msg pageName:(NSString *)pageName leakType:(VSLeakType)leakType;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(dispatch_block_t)block;

+ (void)setLeakCallback:(MLLeakCallback)leakCallback;

@end

NS_ASSUME_NONNULL_END

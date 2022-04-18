//
//  MLReleaseDetector.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "MLReleaseDetector.h"
#import "MLReleaseDetectHelper.h"
#import "UIViewController+MLReleaseDetect.h"

static BOOL hasStartDetect = NO;

@implementation MLReleaseDetector

+ (void)startupWithWhiteList:(NSArray<NSString *> *)whiteList leakCallback:(MLLeakCallback)leakCallback {
    [MLReleaseDetectHelper addWhiteList:whiteList];
    [MLReleaseDetectHelper setLeakCallback:leakCallback];
    [UIViewController startReleaseDetect];
    hasStartDetect = YES;
}

+ (void)addSubViewController:(UIViewController *)subViewController forMainViewController:(UIViewController *)mainViewController {
    if (hasStartDetect && [subViewController isKindOfClass:[UIViewController class]] && [mainViewController isKindOfClass:[UIViewController class]]) {
        [mainViewController addSubViewController:subViewController];
    }
}

@end

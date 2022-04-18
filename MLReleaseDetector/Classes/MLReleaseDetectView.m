//
//  MLReleaseDetectView.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "MLReleaseDetectView.h"
#import "NSObject+MLReleaseDetect.h"
#import "MLReleaseDetectHelper.h"

@implementation MLReleaseDetectView

- (instancetype)initWithRootView:(UIView *)rootView {
    if (!rootView ||
        rootView.disableReleaseDetect ||
        [[MLReleaseDetectHelper getWhiteListSet] containsObject:NSStringFromClass([rootView class])]) {
        return nil;
    }
    
    if (self = [super init]) {
        _rootView = rootView;
        _rootViewClassString = NSStringFromClass([rootView class]);
        [self doData];
    }
    return self;
}

- (void)doData {
    NSMutableArray *objectArray = [NSMutableArray array];
    for (UIView * subView in self.rootView.subviews) {
        MLReleaseDetectView * releaseDetectView = [[MLReleaseDetectView alloc] initWithRootView:subView];
        if (releaseDetectView) {
            [objectArray addObject:releaseDetectView];
        }
    }
    if (objectArray.count) {
        _subReleaseDetectViews = [objectArray copy];
    }
}

- (NSString *)getLeakMsg {
    if (self.rootView) {
        return [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([self.rootView class]), self.rootView];
    } else {
        for (MLReleaseDetectView * releaseDetectView in self.subReleaseDetectViews) {
            NSString * leakMsg = [releaseDetectView getLeakMsg];
            if (leakMsg.length) {
                return [NSString stringWithFormat:@"%@->%@", _rootViewClassString, leakMsg];
            }
        }
    }
    
    return nil;
}

@end

//
//  UIViewController+MLReleaseDetect.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "UIViewController+MLReleaseDetect.h"
#import "MLReleaseDetectHelper.h"
#import "NSObject+MLReleaseDetect.h"
#import "MLReleaseDetectView.h"
#import "MLReleaseDetectObject.h"
#import "MLReleaseDetectWeakObject.h"

NSString * const kIsSubViewControllerKey = @"kIsSubViewControllerKey";
NSString * const kReleaseDetectArrayWhenDeallocKey = @"kReleaseDetectArrayWhenDeallocKey";
NSString * const kWeakObjectKey = @"kWeakObjectKey";

@implementation UIViewController (MLReleaseDetect)

// detect object
- (void)expectReleaseAllObjectsAfterTime:(NSTimeInterval)timeInterval {
    if ([[MLReleaseDetectHelper getWhiteListSet] containsObject:NSStringFromClass([self class])]) {
        return;
    }
    
    MLReleaseDetectObject * releaseDetectObject = [[MLReleaseDetectObject alloc] initWithRootObject:self weakObject:[self weakObject]];
    [MLReleaseDetectHelper scheduledTimerWithTimeInterval:timeInterval block:^{
        NSString * leakMsg = [releaseDetectObject getLeakMsg];
        if (leakMsg.length) {
            [MLReleaseDetectHelper showAlert:[NSString stringWithFormat:@"%@%@", leakMsg, @" not released !"] pageName:releaseDetectObject.rootObjectClassString leakType:VSLeakType_Object];
        }
    }];
}

// detect view
- (void)expectReleaseAllSubViewsAfterTime:(NSTimeInterval)timeInterval {
    if (!self.view || [[MLReleaseDetectHelper getWhiteListSet] containsObject:NSStringFromClass([self class])]) {
        return;
    }
    MLReleaseDetectView * releaseDetectView = [[MLReleaseDetectView alloc] initWithRootView:self.view];
    releaseDetectView.rootViewControllerClassString = NSStringFromClass([self class]);
    [MLReleaseDetectHelper scheduledTimerWithTimeInterval:timeInterval block:^{
        NSString * leakMsg = [releaseDetectView getLeakMsg];
        if (leakMsg.length) {
            [MLReleaseDetectHelper showAlert:[NSString stringWithFormat:@"%@->%@%@", releaseDetectView.rootViewControllerClassString, leakMsg, @" not released !"] pageName:releaseDetectView.rootViewControllerClassString leakType:VSLeakType_View];
        }
    }];
}

// detect viewController
- (void)expectReleaseObjects:(NSArray *)objects afterTime:(NSTimeInterval)timeInterval {
    if (!objects.count || timeInterval < 0) {
        return;
    }
    NSSet<NSString *> * whiteListSet = [MLReleaseDetectHelper getWhiteListSet];
    NSPointerArray *objectsPointerArray = [NSPointerArray weakObjectsPointerArray];
    for (id object in objects) {
        BOOL disableReleaseDetect = NO;
        if ([object isKindOfClass:[NSObject class]] && ![object isKindOfClass:[NSString class]]) {
            disableReleaseDetect = [(NSObject *)object disableReleaseDetect];
            if (!disableReleaseDetect && ![whiteListSet containsObject:NSStringFromClass([object class])]) {
                [objectsPointerArray addPointer:(__bridge void *)object];
            }
        }
    }
    
    if (objectsPointerArray.allObjects.count) {
        [MLReleaseDetectHelper scheduledTimerWithTimeInterval:timeInterval block:^{
            [objectsPointerArray compact];
            if (objectsPointerArray.allObjects.count) {
                NSMutableArray * objectsClassArray = [NSMutableArray array];
                NSString * pageName = nil;
                for (id object in objectsPointerArray.allObjects) {
                    if ([object respondsToSelector:@selector(class)]) {
                        if (!pageName.length) {
                            pageName = NSStringFromClass([object class]);
                        }
                        [objectsClassArray addObject:[NSString stringWithFormat:@"%@(%p)", NSStringFromClass([object class]), object]];
                    }
                }
                if (objectsClassArray.count) {
                    NSString * msg = [NSString stringWithFormat:@"%@ not released !", [objectsClassArray componentsJoinedByString:@","]];
                    [MLReleaseDetectHelper showAlert:msg pageName:pageName?:@"" leakType:VSLeakType_ViewController];
                }
            }
        }];
    }
}

- (void)addSubViewController:(UIViewController *)subViewController {
    if ([subViewController isKindOfClass:[UIViewController class]] && (subViewController != self)) {
        subViewController.isSubViewController = YES;
        NSPointerArray * objectsPointerArray = [self releaseDetectArrayWhenDealloc];
        if (!objectsPointerArray) {
            objectsPointerArray = [NSPointerArray weakObjectsPointerArray];
        }
        [objectsPointerArray addPointer:(__bridge void *)subViewController];
        [self setReleaseDetectArrayWhenDealloc:objectsPointerArray];
    }
}

+ (void)startReleaseDetect {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSELForReleaseDetect:@selector(didMoveToParentViewController:) withSEL:@selector(swizzled_didMoveToParentViewController:)];
        [self swizzleSELForReleaseDetect:@selector(addChildViewController:) withSEL:@selector(swizzled_addChildViewController:)];
        [self swizzleSELForReleaseDetect:@selector(dismissViewControllerAnimated:completion:) withSEL:@selector(swizzled_dismissViewControllerAnimated:completion:)];
        [self swizzleSELForReleaseDetect:NSSelectorFromString(@"dealloc") withSEL:@selector(swizzled_dealloc)];
        [self swizzleSELForReleaseDetect:@selector(alloc) withSEL:@selector(swizzled_alloc) isClassSelector:YES];
    });
}

- (NSPointerArray *)releaseDetectArrayWhenDealloc {
    return objc_getAssociatedObject(self, (__bridge const void *)(kReleaseDetectArrayWhenDeallocKey));
}

- (void)setReleaseDetectArrayWhenDealloc:(NSPointerArray *)releaseDetectArrayWhenDealloc {
    objc_setAssociatedObject(self, (__bridge const void *)kReleaseDetectArrayWhenDeallocKey, releaseDetectArrayWhenDealloc , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSubViewController {
    NSNumber *number = objc_getAssociatedObject(self, (__bridge const void *)(kIsSubViewControllerKey));
    return [number boolValue];
}

- (void)setIsSubViewController:(BOOL)isSubViewController {
    NSNumber *number = [NSNumber numberWithBool:isSubViewController];
    objc_setAssociatedObject(self, (__bridge const void *)kIsSubViewControllerKey, number , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLReleaseDetectWeakObject *)weakObject {
    return objc_getAssociatedObject(self, (__bridge const void *)(kWeakObjectKey));
}

- (void)setWeakObject:(MLReleaseDetectWeakObject *)weakObject {
    objc_setAssociatedObject(self, (__bridge const void *)kWeakObjectKey, weakObject , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)swizzled_addChildViewController:(UIViewController *)childController {
    [self addSubViewController:childController];
    
    [self swizzled_addChildViewController:childController];
}

- (void)swizzled_didMoveToParentViewController:(UIViewController *)parent {
    if (!parent && self && !self.isSubViewController) {
        [self expectReleaseObjects:@[self] afterTime:1];
    }
    
    if (parent && self.navigationController) {
        MLReleaseDetectWeakObject * weakObject = [[MLReleaseDetectWeakObject alloc] init];
        weakObject.navigationController = self.navigationController;
        weakObject.adaptorView = [self getAdaptorView];
        [self setWeakObject:weakObject];
    }
    
    [self swizzled_didMoveToParentViewController:parent];
}

- (UIView *)getAdaptorView {
    if (self.navigationItem.titleView.superview) {
        return self.navigationItem.titleView.superview;
    } else {
        return nil;
    }
}

- (void)swizzled_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController *dismissedViewController = self.presentedViewController;
    if (!dismissedViewController && self.presentingViewController) {
        dismissedViewController = self;
    }
    
    if (dismissedViewController && !dismissedViewController.isSubViewController) {
        [self expectReleaseObjects:@[dismissedViewController] afterTime:2];
    }
    
    [self swizzled_dismissViewControllerAnimated:flag completion:completion];
}

- (void)swizzled_dealloc {
    NSMutableSet * needReleaseDetectSet = [NSMutableSet set];
    
    if (self.childViewControllers.count) {
        [needReleaseDetectSet addObjectsFromArray:self.childViewControllers];
    }
    if (self.presentedViewController) {
        [needReleaseDetectSet addObject:self.presentedViewController];
    }
    
    NSPointerArray * objectsPointerArray = [self releaseDetectArrayWhenDealloc];
    [objectsPointerArray compact];
    if (objectsPointerArray.allObjects.count) {
        [needReleaseDetectSet addObjectsFromArray:objectsPointerArray.allObjects];
    }
    
    if (needReleaseDetectSet.allObjects.count) {
        [self expectReleaseObjects:needReleaseDetectSet.allObjects afterTime:1];
    }
    
    [self expectReleaseAllSubViewsAfterTime:1];
    [self expectReleaseAllObjectsAfterTime:1.5];
    
    [self swizzled_dealloc];
}

+ (instancetype)swizzled_alloc {
    id object = [self swizzled_alloc];
    if ([NSBundle bundleForClass:[self class]] == [NSBundle mainBundle]) {
        [MLReleaseDetectHelper addAliveViewController:object];
    }
    return object;
}

@end

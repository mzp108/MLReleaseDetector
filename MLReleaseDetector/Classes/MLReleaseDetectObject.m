//
//  MLReleaseDetectObject.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "MLReleaseDetectObject.h"
#import "NSObject+MLReleaseDetect.h"
#import "MLReleaseDetectHelper.h"

@interface MLReleaseDetectObject ()

@property (nonatomic, strong) MLReleaseDetectWeakObject * weakObject;

@end

@implementation MLReleaseDetectObject

- (instancetype)initWithRootObject:(NSObject *)rootObject weakObject:(MLReleaseDetectWeakObject *)weakObject {
    NSMutableSet * objectsSet = [NSMutableSet set];
    return [self initWithRootObject:rootObject weakObject:weakObject isRootViewController:YES objectSet:&objectsSet];
}

- (instancetype)initWithRootObject:(NSObject *)rootObject weakObject:(MLReleaseDetectWeakObject *)weakObject isRootViewController:(BOOL)isRootViewController objectSet:(NSMutableSet **)objectsSet {
    if (!rootObject ||
        rootObject.disableReleaseDetect ||
        ([NSBundle bundleForClass:[rootObject class]] != [NSBundle mainBundle]) ||
        [[MLReleaseDetectHelper getWhiteListSet] containsObject:NSStringFromClass([rootObject class])]) {
        return nil;
    }
    
    if (self = [super init]) {
        if (!isRootViewController) {
            _rootObject = rootObject;
        }
        _weakObject = weakObject;
        _rootObjectClassString = NSStringFromClass([rootObject class]);
        [self doData:rootObject weakObject:weakObject objectsSet:objectsSet];
    }
    return self;
}

- (void)doData:(NSObject *)rootObject weakObject:(MLReleaseDetectWeakObject *)weakObject objectsSet:(NSMutableSet **)objectsSet {
    NSMutableArray *objectArray = [NSMutableArray array];
    for (NSString * ivarName in [rootObject getIvarNameList]) {
        NSObject * ivarValue = [rootObject valueForKey:ivarName];
        if ([ivarValue isKindOfClass:[NSObject class]]) {
            NSMutableSet * set = *objectsSet;
            if ([set containsObject:[NSString stringWithFormat:@"%p", ivarValue]]) {
                continue;
            } else {
                [set addObject:[NSString stringWithFormat:@"%p", ivarValue]];
            }
            MLReleaseDetectObject * releaseDetectObject = [[MLReleaseDetectObject alloc] initWithRootObject:ivarValue weakObject:weakObject isRootViewController:NO objectSet:objectsSet];
            if (releaseDetectObject) {
                [objectArray addObject:releaseDetectObject];
            }
        }
    }
    
    if (objectArray.count) {
        _subReleaseDetectObjects = [objectArray copy];
    }
}

- (NSString *)getLeakMsg {
    NSMutableDictionary * aliveViewControllersObjectsDict = [NSMutableDictionary dictionary];
    return [self getLeakMsg:&aliveViewControllersObjectsDict];
}

- (BOOL)rootViewhasSubView:(UIView *)rootView subView:(UIView *)subView {
    if (![rootView isKindOfClass:[UIView class]] || ![subView isKindOfClass:[UIView class]]) {
        return NO;
    }
    
    if (subView.superview == rootView) {
        return YES;
    }
    
    for (UIView * view in rootView.subviews) {
        if([self rootViewhasSubView:view subView:subView]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)getLeakMsg:(NSMutableDictionary **)aliveViewControllersObjectsDict {
    if (self.rootObject) {
        NSString * rootObjectAddressString = [NSString stringWithFormat:@"%p", self.rootObject];
        NSMutableDictionary * dict = *aliveViewControllersObjectsDict;
        NSPointerArray * aliveObjects = [MLReleaseDetectHelper getAliveViewControllers];
        [aliveObjects compact];
        BOOL isInNavigationBar = NO;
        BOOL isInAdaptorView = NO;
        if ([self.rootObject isKindOfClass:[UIView class]]) {
            UIView * view = (UIView *)self.rootObject;
            isInNavigationBar = [self rootViewhasSubView:self.weakObject.navigationController.navigationBar subView:view];
            isInAdaptorView = [self rootViewhasSubView:self.weakObject.adaptorView subView:view];
        }
        
        BOOL __block isLeak = YES;
        if (isInNavigationBar || isInAdaptorView) {
            isLeak = NO;
        } else {
            NSArray * aliveViewControllersArray = [aliveObjects.allObjects copy];
            [aliveViewControllersArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSObject class]]) {
                    NSString * key = [NSString stringWithFormat:@"%p", obj];
                    NSSet * set = [dict objectForKey:key];
                    if (!set) {
                        set = [NSSet setWithArray:[obj getAllIvarValues]];
                        if (set) {
                            [dict setObject:set forKey:key];
                        }
                    }
                    if ([set containsObject:rootObjectAddressString]) {
                        isLeak = NO;
                        *stop = YES;
                    }
                };
            }];
        }
        
        if (isLeak) {
            return [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([self.rootObject class]), self.rootObject];
        }
    } else {
        for (MLReleaseDetectObject * releaseDetectObject in self.subReleaseDetectObjects) {
            NSString * leakMsg = [releaseDetectObject getLeakMsg:aliveViewControllersObjectsDict];
            if (leakMsg.length) {
                return [NSString stringWithFormat:@"%@->%@", _rootObjectClassString, leakMsg];
            }
        }
    }
    
    return nil;
}

@end

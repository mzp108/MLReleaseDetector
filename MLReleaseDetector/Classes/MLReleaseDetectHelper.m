//
//  MLReleaseDetectHelper.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "MLReleaseDetectHelper.h"

VSLeakType const VSLeakType_ViewController = @"viewController";
VSLeakType const VSLeakType_View = @"view";
VSLeakType const VSLeakType_Object = @"object";

static UIWindow *alertWindow = nil;
static NSSet<NSString *> *releaseDetectWhiteListSet = nil;
static NSPointerArray *aliveViewControllers = nil;

static MLLeakCallback _leakCallback;

static inline NSArray<NSString *> *VSReleaseDetectWhiteListArray(void) {
    return @[@"UISystemInputAssistantViewController",
             @"UICompatibilityInputViewController",
             @"UIInputWindowController",
             @"_UIScrollViewScrollIndicator",
             @"_UIRemoteInputViewController",
             @"UIKeyboardMediaServiceRemoteViewController",
             @"UITextField",
             @"WKContentView",
             @"UIImagePickerController",
             @"PHPickerViewController",
    ];
}

@implementation MLReleaseDetectHelper

+ (NSPointerArray *)getAliveViewControllers {
    return aliveViewControllers;
}

+ (void)addAliveViewController:(UIViewController *)viewController {
    if (![viewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    if (!aliveViewControllers) {
        aliveViewControllers = [NSPointerArray weakObjectsPointerArray];
    }
    
    [aliveViewControllers addPointer:(__bridge void *)viewController];
}

+ (NSSet<NSString *> *)getWhiteListSet {
    if (!releaseDetectWhiteListSet) {
        releaseDetectWhiteListSet = [NSSet setWithArray:VSReleaseDetectWhiteListArray()];
    }
    return releaseDetectWhiteListSet;
}

+ (void)addWhiteList:(NSArray<NSString *> *)whiteList {
    NSMutableSet<NSString *> * mutableWhiteListSet = [NSMutableSet setWithSet:[self getWhiteListSet]];
    for (NSString * item in whiteList) {
        if ([item isKindOfClass:[NSString class]] && item.length) {
            [mutableWhiteListSet addObject:item];
        }
    }
    releaseDetectWhiteListSet = [mutableWhiteListSet copy];
}

+ (NSString *)removeAddress:(NSString *)msg leakType:(VSLeakType)leakType {
    if (!msg.length) {
        return nil;
    }
    
    NSArray * array = [msg componentsSeparatedByString:@","];
    if (array.count > 1) {
        NSMutableArray * retArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSString * subString in array) {
            [retArray addObject:[self removeAddress:subString]];
        }
        return [retArray componentsJoinedByString:@","];
    } else {
        return [self removeAddress:msg];
    }
}

+ (NSString *)removeAddress:(NSString *)msg {
    if (!msg.length) {
        return nil;
    }
    
    NSRange range = [msg rangeOfString:@"(" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        return [msg substringToIndex:range.location];
    } else {
        return msg;
    }
}

+ (void)setLeakCallback:(MLLeakCallback)leakCallback {
    _leakCallback = leakCallback;
}

+ (void)showAlert:(NSString *)msg pageName:(NSString *)pageName leakType:(VSLeakType)leakType {
    if (!msg.length || UIAccessibilityIsVoiceOverRunning()) {
        return;
    }
    
    if (_leakCallback) {
        _leakCallback([self removeAddress:msg leakType:leakType]?:@"", pageName?:@"", leakType?:@"");
    }
    
#ifdef DEBUG
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        alertWindow = nil;
    }];
    [alertController addAction:action];
    alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (@available(iOS 13.0, *)) {
        UIWindow * keyWindow = nil;
        for (UIWindowScene * windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow * window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                break;
            }
        }
        alertWindow.windowScene = keyWindow.windowScene;
        alertWindow.overrideUserInterfaceStyle = keyWindow.traitCollection.userInterfaceStyle;
    }
    alertWindow.backgroundColor = [UIColor clearColor];
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    alertWindow.rootViewController = [UIViewController new];
    alertWindow.hidden = NO;
    [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
#endif
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(dispatch_block_t)block {
    NSParameterAssert(block != nil);
    return [NSTimer scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeBlockFromTimer:) userInfo:[block copy] repeats:NO];
}

+ (void)executeBlockFromTimer:(NSTimer *)aTimer {
    dispatch_block_t block = [aTimer userInfo];
    if (block) {
        block();
    }
}

@end

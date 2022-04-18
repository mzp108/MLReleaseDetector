//
//  NSObject+MLReleaseDetect.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MLReleaseDetect)

/// Set to YES will not perform release detection on the object. The default value is NO.
/// Note: Currently no scene use, reserved for future expansion.
@property (nonatomic, assign) BOOL disableReleaseDetect;

+ (void)swizzleSELForReleaseDetect:(SEL)originalSelector withSEL:(SEL)swizzledSelector;
+ (void)swizzleSELForReleaseDetect:(SEL)originalSelector withSEL:(SEL)swizzledSelector isClassSelector:(BOOL)isClassSelector;

- (NSArray *)getAllIvarValues;
- (NSArray *)getIvarNameList;

@end

NS_ASSUME_NONNULL_END

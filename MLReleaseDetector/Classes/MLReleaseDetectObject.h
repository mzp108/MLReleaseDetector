//
//  MLReleaseDetectObject.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>
#import "MLReleaseDetectWeakObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLReleaseDetectObject : NSObject

@property (nonatomic, weak, readonly) NSObject * rootObject;
@property (nonatomic, copy, readonly) NSString * rootObjectClassString;
@property (nonatomic, strong, readonly) NSArray * subReleaseDetectObjects;

- (instancetype)initWithRootObject:(NSObject *)rootObject weakObject:(MLReleaseDetectWeakObject *)weakObject;

- (NSString *)getLeakMsg;

@end

NS_ASSUME_NONNULL_END

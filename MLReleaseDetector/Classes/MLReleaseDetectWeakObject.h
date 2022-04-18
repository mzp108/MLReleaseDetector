//
//  MLReleaseDetectWeakObject.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLReleaseDetectWeakObject : NSObject

@property (nonatomic, weak) UINavigationController * navigationController;
@property (nonatomic, weak) UIView *adaptorView;

@end

NS_ASSUME_NONNULL_END

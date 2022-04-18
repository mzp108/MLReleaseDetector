//
//  NSObject+MLReleaseDetect.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#import "NSObject+MLReleaseDetect.h"
#import "MLReleaseDetectHelper.h"

NSString * const kDisableReleaseDetectKey = @"kDisableReleaseDetectKey";

static NSMutableDictionary *ivarNameListCacheDict = nil;

@implementation NSObject (MLReleaseDetect)

+ (void)swizzleSELForReleaseDetect:(SEL)originalSelector withSEL:(SEL)swizzledSelector {
    return [self swizzleSELForReleaseDetect:originalSelector withSEL:swizzledSelector isClassSelector:NO];
}

+ (void)swizzleSELForReleaseDetect:(SEL)originalSelector withSEL:(SEL)swizzledSelector isClassSelector:(BOOL)isClassSelector {
    Class class = isClassSelector ? object_getClass(self) : [self class];
    
    Method originalMethod = isClassSelector ? class_getClassMethod(class, originalSelector) : class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = isClassSelector ? class_getClassMethod(class, swizzledSelector) : class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)disableReleaseDetect {
    NSNumber *number = objc_getAssociatedObject(self, (__bridge const void *)(kDisableReleaseDetectKey));
    return [number boolValue];
}

- (void)setDisableReleaseDetect:(BOOL)disableReleaseDetect {
    NSNumber *number = [NSNumber numberWithBool:disableReleaseDetect];
    objc_setAssociatedObject(self, (__bridge const void *)kDisableReleaseDetectKey, number , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)getAllIvarValues {
    NSMutableSet * objectsSet = [NSMutableSet set];
    return [self getAllIvarValues:&objectsSet];
}

- (NSArray *)getAllIvarValues:(NSMutableSet **)objectsSet  {
    NSMutableArray *retArray = [NSMutableArray array];
    
    if ([self isKindOfClass:[NSArray class]]) {
        for (NSObject * object in [(NSArray *)self copy]) {
            [self addIvarValue:object retArray:&retArray objectsSet:objectsSet];
        }
        return [retArray copy];
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        for (NSObject * object in [[(NSDictionary *)self allValues] copy]) {
            [self addIvarValue:object retArray:&retArray objectsSet:objectsSet];
        }
        return [retArray copy];
    }
    
    for (NSString * ivarName in [self getIvarNameList]) {
        if (!ivarName.length) {
            continue;
        }
        NSObject * ivarValue = [self valueForKey:ivarName];
        [self addIvarValue:ivarValue retArray:&retArray objectsSet:objectsSet];
    }
    return [retArray copy];
}

- (void)addIvarValue:(NSObject *)ivarValue retArray:(NSMutableArray **)retArray objectsSet:(NSMutableSet **)objectsSet {
    if (![ivarValue isKindOfClass:[NSObject class]]) {
        return;
    }
    
    if ([ivarValue isKindOfClass:[NSArray class]] || [ivarValue isKindOfClass:[NSDictionary class]]) {
        [*retArray addObjectsFromArray:[ivarValue getAllIvarValues:objectsSet]];
    } else if ([NSBundle bundleForClass:[ivarValue class]] == [NSBundle mainBundle]) {
        NSString * ivarValueAddressString = [NSString stringWithFormat:@"%p", ivarValue];
        if (![*objectsSet containsObject:ivarValueAddressString]) {
            [*objectsSet addObject:ivarValueAddressString];
            [*retArray addObject:ivarValueAddressString];
            [*retArray addObjectsFromArray:[ivarValue getAllIvarValues:objectsSet]];
        }
    }
}

- (NSArray *)getIvarNameList {
    if (!ivarNameListCacheDict) {
        ivarNameListCacheDict = [NSMutableDictionary dictionary];
    }
    
    NSArray *ivarNameListCache = [ivarNameListCacheDict objectForKey:NSStringFromClass([self class])];
    if ([ivarNameListCache isKindOfClass:[NSArray class]]) {
        return ivarNameListCache;
    }
    
    NSMutableArray *ivarNameList = [NSMutableArray array];
    for (Class class = [self class]; [NSBundle bundleForClass:class] == [NSBundle mainBundle]; class = class_getSuperclass(class)) {
        NSIndexSet * strongIndexes = [self strongIndexes:class];
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList(class, &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            const char *type = ivar_getTypeEncoding(ivar);
            if (type[0] != _C_ID) {
                continue;
            }
            
            //block type
            if (strncmp(type, "@?", 2) == 0) {
                continue;
            }
            
            NSUInteger index = ivar_getOffset(ivar) / (sizeof(void *));
            if (![strongIndexes containsIndex:index]) {
                continue;
            }
            
            NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if (ivarName.length) {
                [ivarNameList addObject:ivarName];
            }
        }
        if (ivars) {
            free(ivars);
        }
    }
    
    NSArray * retArray = [ivarNameList copy];
    [ivarNameListCacheDict setValue:retArray forKey:NSStringFromClass([self class])];
    
    return retArray;
}

- (NSIndexSet *)strongIndexes:(Class)acls {
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(acls, &ivarCount);
    const uint8_t *layoutDescription = class_getIvarLayout(acls);
    if (ivars && layoutDescription) {
        NSMutableIndexSet *interestingIndexes = [NSMutableIndexSet new];
        NSUInteger currentIndex = ivar_getOffset(ivars[0]) / (sizeof(void *));
        while (*layoutDescription != '\x00') {
            int upperNibble = (*layoutDescription & 0xf0) >> 4;
            int lowerNibble = *layoutDescription & 0xf;
            
            currentIndex += upperNibble;
            [interestingIndexes addIndexesInRange:NSMakeRange(currentIndex, lowerNibble)];
            currentIndex += lowerNibble;
            
            ++layoutDescription;
        }
        free(ivars);
        return [interestingIndexes copy];
    } else {
        return nil;
    }
}

@end

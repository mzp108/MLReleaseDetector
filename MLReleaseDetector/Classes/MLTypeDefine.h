//
//  MLTypeDefine.h
//  MLReleaseDetector
//
//  Created by mazhipeng on 2022/4/16.
//

#ifndef MLTypeDefine_h
#define MLTypeDefine_h

typedef NSString *VSLeakType NS_STRING_ENUM;
FOUNDATION_EXPORT VSLeakType const VSLeakType_ViewController;
FOUNDATION_EXPORT VSLeakType const VSLeakType_View;
FOUNDATION_EXPORT VSLeakType const VSLeakType_Object;

typedef void (^MLLeakCallback)(NSString * leakMsg, NSString * pageName, VSLeakType leakType);

#endif /* MLTypeDefine_h */

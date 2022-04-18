//
//  MLObjectLeakViewController.m
//  MLReleaseDetector_Example
//
//  Created by mazhipeng on 2022/4/16.
//  Copyright © 2022 mazhipeng. All rights reserved.
//

#import "MLObjectLeakViewController.h"

@interface MLObject : NSObject

@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation MLObject;

@end

@interface MLObjectLeakViewController ()

@property (nonatomic, strong) MLObject * object;

@end

@implementation MLObjectLeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Object Leak";
    
    MLObject * object = [[MLObject alloc] init];
    object.block = ^{
        NSLog(@"%@", object);
    };
    self.object = object;
}


@end

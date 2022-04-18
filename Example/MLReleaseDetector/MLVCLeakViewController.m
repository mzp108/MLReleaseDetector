//
//  MLVCLeakViewController.m
//  MLReleaseDetector_Example
//
//  Created by mazhipeng on 2022/4/16.
//  Copyright © 2022 mazhipeng. All rights reserved.
//

#import "MLVCLeakViewController.h"

@interface MLVCLeakViewController ()

@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation MLVCLeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ViewController Leak";
    
    self.block = ^{
        NSLog(@"%@", self);
    };
}


@end

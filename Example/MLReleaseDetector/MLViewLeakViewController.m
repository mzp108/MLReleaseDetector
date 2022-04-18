//
//  MLViewLeakViewController.m
//  MLReleaseDetector_Example
//
//  Created by mazhipeng on 2022/4/16.
//  Copyright © 2022 mazhipeng. All rights reserved.
//

#import "MLViewLeakViewController.h"

@interface MLView : UIView

@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation MLView;

@end

@interface MLViewLeakViewController ()

@end

@implementation MLViewLeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"View Leak";
    
    MLView * view = [[MLView alloc] init];
    view.block = ^{
        NSLog(@"%@", view);
    };
    [self.view addSubview:view];
}


@end

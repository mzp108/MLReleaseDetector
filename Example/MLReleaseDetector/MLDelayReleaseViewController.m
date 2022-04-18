//
//  MLDelayReleaseViewController.m
//  MLReleaseDetector_Example
//
//  Created by mazhipeng on 2022/4/16.
//  Copyright © 2022 mazhipeng. All rights reserved.
//

#import "MLDelayReleaseViewController.h"

@interface MLPerson : NSObject

@end

@implementation MLPerson

@end

@interface MLDelayReleaseViewController ()

@property (nonatomic, strong) MLPerson * person;

@end

@implementation MLDelayReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Delay Release";
    
    MLPerson * person = [[MLPerson alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", person);
    });
    self.person = person;
}


@end

//
//  MLViewController.m
//  MLReleaseDetector
//
//  Created by mazhipeng on 04/16/2022.
//  Copyright (c) 2022 mazhipeng. All rights reserved.
//

#import "MLViewController.h"
#import "MLVCLeakViewController.h"
#import "MLViewLeakViewController.h"
#import "MLObjectLeakViewController.h"
#import "MLDelayReleaseViewController.h"
#import "MLReleaseDetector_Example-Swift.h"

@interface MLViewController ()

@end

@implementation MLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnOneClick {
    [self.navigationController pushViewController:[[MLVCLeakViewController alloc] init] animated:YES];
}

- (IBAction)btnTwoClick {
    [self.navigationController pushViewController:[[MLViewLeakViewController alloc] init] animated:YES];
}

- (IBAction)btnThreeClick {
    [self.navigationController pushViewController:[[MLObjectLeakViewController alloc] init] animated:YES];
}

- (IBAction)btnFourClick {
    [self.navigationController pushViewController:[[MLDelayReleaseViewController alloc] init] animated:YES];
}

- (IBAction)btnFiveClick {
    [self.navigationController pushViewController:[[MLSwiftLeakViewController alloc] init] animated:YES];
}

@end

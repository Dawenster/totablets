//
//  PaymentViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(455,372,290,55)
                                                  andKey:@"pk_test_mHRnRqLpMebdwnbKedxjzUvf"];
    } else {
        self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(715,372,290,55)
                                                  andKey:@"pk_test_mHRnRqLpMebdwnbKedxjzUvf"];
    }
    
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.stripeView.frame = CGRectMake(455,372,290,55);
    } else {
        self.stripeView.frame = CGRectMake(715,372,290,55);
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            
        case 1:
            return 2;
        
        case 2:
            return 3;
        
        case 3:
            return 1;
    }
    return 0;
}

@end

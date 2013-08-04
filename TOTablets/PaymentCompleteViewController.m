//
//  PaymentCompleteViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-19.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentCompleteViewController.h"

@interface PaymentCompleteViewController ()

@end

@implementation PaymentCompleteViewController {
    NSTimer *timer;
    int secondsRemaining;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateLabels];
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    secondsRemaining = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabels
{
    self.titleLabel.text = [NSString stringWithFormat:@"Thank you, %@, for renting with %@ :)", self.customerName, self.locationName];
    self.emailLabel.text = [NSString stringWithFormat:@"Your receipt has been emailed to %@", self.email];
    self.endDateLabel.text = [NSString stringWithFormat:@"You have this iPad until %@", self.endDate];
}

- (void)updateCountdown
{
    if (secondsRemaining > 9) {
        self.timerLabel.text = [NSString stringWithFormat:@"%d", secondsRemaining];
    } else if (secondsRemaining == 1) {
        self.secondsLabel.text = @"second";
        self.timerLabel.text = [NSString stringWithFormat:@"0%d", secondsRemaining];
    } else {
        self.timerLabel.text = [NSString stringWithFormat:@"0%d", secondsRemaining];
    }
    secondsRemaining -= 1;
    if (secondsRemaining < 0) {
        [timer invalidate];
        timer = nil;
        self.messageLabel.text = @"Your iPad is now ready for use. Enjoy!";
        self.rentalStartLabel.text = @"";
        self.secondsLabel.text = @"";
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            exit(0);
        });
    }
}

@end

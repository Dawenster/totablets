//
//  PaymentCompleteViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-19.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentCompleteViewController.h"
#import "AppDelegate.h"

const CGRect AlertPortraitLocation = { { 200.0f, 510.0f }, { 486.0f, 89.0f } };
const CGRect AlertLandscapeLocation = { { 200.0f, 800.0f }, { 486.0f, 89.0f } };

@interface PaymentCompleteViewController ()

@end

@implementation PaymentCompleteViewController {
    NSTimer *timer;
    int secondsRemaining;
    bool firstTimeLoaded;
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.paymentCompleteViewController = self;
//    appDelegate.endDate = [NSDate date];
    
    self.finishRental.hidden = YES;
    self.upArrow.hidden = YES;
    self.leftArrow.hidden = YES;
    self.bottomArrow.hidden = YES;
    self.rightArrow.hidden = YES;
    
    [self updateLabels];
    
    if (!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.signOutWarning.frame = AlertLandscapeLocation;
    }
    
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
    self.endDateLabel.text = [NSString stringWithFormat:@"You have this iPad until %@", self.endDateString];
}

- (void)updateCountdown
{
    if (secondsRemaining > 9) {
        self.timerLabel.text = [NSString stringWithFormat:@"%d", secondsRemaining];
    } else if (secondsRemaining == 1) {
        self.secondsLabel.text = @"second.";
        self.timerLabel.text = [NSString stringWithFormat:@"0%d", secondsRemaining];
    } else {
        self.timerLabel.text = [NSString stringWithFormat:@"0%d", secondsRemaining];
    }
    secondsRemaining -= 1;
    if (secondsRemaining < 0) {
        [timer invalidate];
        timer = nil;
        self.messageLabel.text = @"Click the home button to use your iPad (follow the yellow arrow).";
        self.messageLabel.textColor = [UIColor yellowColor];
        [self.messageLabel sizeToFit];
        self.rentalStartLabel.text = @"";
        self.secondsLabel.text = @"";
        self.timerLabel.font = [UIFont boldSystemFontOfSize:75.0];
        self.timerLabel.text = @"Enjoy!";
        self.finishRental.hidden = NO;
        
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            self.leftArrow.hidden = NO;
        } else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            self.rightArrow.hidden = NO;
        } else if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            self.upArrow.hidden = NO;
        } else {
            self.bottomArrow.hidden = NO;
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.upArrow.hidden = YES;
    self.leftArrow.hidden = YES;
    self.bottomArrow.hidden = YES;
    self.rightArrow.hidden = YES;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        if (secondsRemaining < 0) {
            self.leftArrow.hidden = NO;
        }
        self.signOutWarning.frame = AlertLandscapeLocation;
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (secondsRemaining < 0) {
            self.rightArrow.hidden = NO;
        }
        self.signOutWarning.frame = AlertLandscapeLocation;
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (secondsRemaining < 0) {
            self.upArrow.hidden = NO;
        }
        self.signOutWarning.frame = AlertPortraitLocation;
    } else {
        if (secondsRemaining < 0) {
            self.bottomArrow.hidden = NO;
        }
        self.signOutWarning.frame = AlertPortraitLocation;
    }
    
    [self.signOutWarning setNeedsDisplay];
}

@end

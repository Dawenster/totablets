//
//  PaymentCompleteViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-19.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentCompleteViewController.h"
#import "AppDelegate.h"

const CGRect AlertPortraitLocation = { { 170.0f, 508.0f }, { 500.0f, 300.0f } };
const CGRect AlertLandscapeLocation = { { 170.0f, 555.0f }, { 730.0f, 150.0f } };

@interface PaymentCompleteViewController ()

@end

@implementation PaymentCompleteViewController {
    NSTimer *timer;
    int secondsRemaining;
    bool firstTimeLoaded;
    NSString *environmentURL;
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
    environmentURL = appDelegate.environmentURL;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    self.finishRental.hidden = YES;
    self.upArrow.hidden = YES;
    self.leftArrow.hidden = YES;
    self.bottomArrow.hidden = YES;
    self.rightArrow.hidden = YES;
    
    [self updateLabels];
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    
    secondsRemaining = 60;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    self.warningLabel.text = self.warning;
    self.passwordLabel.text = [NSString stringWithFormat:@"'%@'", self.appleIdPassword];
    
//    [self.signOutWarningLabel sizeToFit];
}

- (void)updateCountdown
{
    if (secondsRemaining > 9) {
        self.timerLabel.text = [NSString stringWithFormat:@"%d", secondsRemaining];
    } else if (secondsRemaining == 1) {
        [self installApps];
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
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (secondsRemaining < 0) {
            self.rightArrow.hidden = NO;
        }
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (secondsRemaining < 0) {
            self.upArrow.hidden = NO;
        }
    } else {
        if (secondsRemaining < 0) {
            self.bottomArrow.hidden = NO;
        }
    }
}

- (void)finishRentalLock
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Return device"
                                                        message:@"Please enter password"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Return", nil];
    
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    if (buttonIndex == 1 && [textField.text isEqualToString:self.adminPassword]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"Ending current rental and locking device";
        [self adminCommand:@"lock"];
    } else if (buttonIndex == 1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"Incorrect password - please try again";
        [HUD hide:YES afterDelay:3];
    }
}

- (void)adminCommand:(NSString *)command
{
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    self.responseData = [NSMutableData data];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/admin_command", environmentURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"ipad_name=%@&command=%@&origin=%@", deviceUDID, command, @"finish_rental"];
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Escaped Body: %@", escapedBody);
    
    request.HTTPBody = [escapedBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"Connection description: %@",connection.description);
}

- (void)installApps
{
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    self.responseData = [NSMutableData data];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/install_apps", environmentURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"ipad_name=%@", deviceUDID];
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Escaped Body: %@", escapedBody);
    
    request.HTTPBody = [escapedBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"Connection description: %@",connection.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
    [self noConnectionError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Device will lock itself shortly.";
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    if ([res[@"command"] isEqualToString:@"lock"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.endDate = [NSDate date];
        
        [appDelegate.paymentCompleteViewController dismissViewControllerAnimated:YES completion:nil];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [appDelegate.paymentViewController dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)noConnectionError
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:@"No internet connection - please see the front desk for assistance."
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

@end

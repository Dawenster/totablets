//
//  PaymentViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

const CGRect StripePortraitLocation = { { 452.0f, 395.0f }, { 290.0f, 55.0f } };
const CGRect StripeLandscapeLocation = { { 708.0f, 395.0f }, { 290.0f, 55.0f } };
const int rentalFee = 2500;
const int GST = 5;
const int PST = 7;
NSString *publishableKey = @"pk_test_mHRnRqLpMebdwnbKedxjzUvf";

@interface PaymentViewController ()

@end

@implementation PaymentViewController {
    NSDictionary *taxesByLocation;
    NSDate *startDate;
    NSDate *endDate;
    NSString *locationName;
    NSString *currency;
    float days;
    float subtotal;
    int tax;
    float taxAmount;
    float grandTotal;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.stripeView = [[STPView alloc] initWithFrame:StripePortraitLocation andKey:publishableKey];
    } else {
        self.stripeView = [[STPView alloc] initWithFrame:StripeLandscapeLocation andKey:publishableKey];
    }
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
    
    self.payButton.enabled = NO;
    locationName = @"Shangri-La, Vancouver";
    self.locationLabel.text = locationName;

    taxesByLocation = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @[@"GST and PST", [NSNumber numberWithInteger:(GST + PST)], @"CAD"], @"Shangri-La, Vancouver",
                                    @[@"GST", [NSNumber numberWithInteger:GST], @"CAD"], @"Nuvo Hotel, Calgary"
                                    ,nil];
    
    [self updateLabels];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.stripeView.frame = StripePortraitLocation;
    } else {
        self.stripeView.frame = StripeLandscapeLocation;
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabels;
{
    self.locationLabel.text = locationName;
    days = [self.stepper value];
    subtotal = rentalFee * days;
    tax = [taxesByLocation[self.locationLabel.text][1] integerValue];
    taxAmount = subtotal * tax / 100.0;
    grandTotal = subtotal + taxAmount;
    currency = taxesByLocation[self.locationLabel.text][2];
    
    startDate = [NSDate date];
    NSString *endDateString = [self formatDate:startDate];
    
    if (days == 1) {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f day, ending on %@", days, endDateString];
    } else {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f days, ending on %@", days, endDateString];
    }
    self.subtotalLabel.text = [NSString stringWithFormat:@"Sub-total (%0.0f days x $%d per day):", days, rentalFee / 100];
    self.subtotalAmount.text = [NSString stringWithFormat:@"$%.02f %@", subtotal / 100, currency];
    self.taxesLabel.text = [NSString stringWithFormat:@"Taxes (%@):", taxesByLocation[self.locationLabel.text][0]];
    self.taxesAmount.text = [NSString stringWithFormat:@"(%d%%) $%.02f %@", tax, taxAmount / 100.0, currency];
    self.grandTotalAmount.text = [NSString stringWithFormat:@"$%.02f %@", grandTotal / 100.0, currency];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;
        case 1:return 2;
        case 2:return 3;
        case 3:return 4;
    }
    return 0;
}

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeDays
{
    [self updateLabels];
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    self.payButton.enabled = valid;
}

- (IBAction)pay;
{
    if ([self reachable]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"Processing payment";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.responseData = [NSMutableData data];
                [self stripeCall];
            });
        });
    } else {
        [self noConnectionError];
    }
}

- (void)stripeCall
{
    // Call 'createToken' when the save button is tapped
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [HUD hide:YES];
            [self handleError:error];
        } else {
            // Send off token to your server
            [self handleToken:token];
        }
    }];
}

- (void)handleToken:(STPToken *)token
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self sendCustomerData:token];
    });
    
    NSLog(@"Received token %@", token.tokenId);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.totablets.com/rentals"]];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:3000/rentals"]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"days=%0.0f&location=%@&rate=%d&tax_names=%@&name=%@&email=%@&stripe_token=%@&grand_total=%0.0f&currency=%@",
                          days, self.locationLabel.text, rentalFee, taxesByLocation[self.locationLabel.text][0], self.nameField.text, self.emailField.text, token.tokenId, grandTotal, currency];
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Escaped Body: %@", escapedBody);
    
    request.HTTPBody = [escapedBody dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSError *myError = nil;
                               NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
                               
                               if ([res[@"stripe_error"] isEqualToString:@"None"]) {
                                   // Image based on the work by pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                                   HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                                   HUD.mode = MBProgressHUDModeCustomView;
                                   HUD.labelText = @"Completed";
                                   
                                   double delayInSeconds = 2.0;
                                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                       [self performSegueWithIdentifier:@"PaymentComplete" sender:nil];
                                   });
                               } else {
                                   [HUD hide:YES];
                                   NSLog(@"Error: %@", [error localizedDescription]);
                                   [self handleErrorWithString:res[@"stripe_error"]];
                               }
                           }];
}

- (void)sendCustomerData:(STPToken *)token
{
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.totablets.com/capture_customer_data"]];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:3000/capture_customer_data"]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"days=%0.0f&start_date=%@&end_date=%@&location=%@&location_detail=%@&email=%@&rate=%d&subtotal=%0.0f&tax_names=%@&tax_percentage=%d&tax_amount=%0.0f&grand_total=%0.0f&currency=%@&device_name=%@",
                          days, startDate, endDate, self.locationLabel.text, self.locationDetailField.text, self.emailField.text, rentalFee, subtotal, taxesByLocation[self.locationLabel.text][0], tax, taxAmount, grandTotal, currency, deviceUDID];
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Send Customer Data Escaped Body: %@", escapedBody);
    
    request.HTTPBody = [escapedBody dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"%@", error.localizedDescription);
                               }
                           }];
}

- (void)handleError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)handleErrorWithString:(NSString *)errorMessage
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:errorMessage
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)noConnectionError
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:@"No internet connection - please see the front desk for assistance."
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [formatter setLocale:locale];
    
    NSDateComponents *futureComponents = [NSDateComponents new];
    futureComponents.day = [self.stepper value];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate *futureDate = [gregorian dateByAddingComponents:futureComponents toDate:date options:0];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: futureDate];
    
    [components setHour: 16];
    [components setMinute: 0];
    [components setSecond: 0];
    
    endDate = [gregorian dateFromComponents: components];
    
    [formatter setDateFormat:@"MMM d, YYYY (EEE)"];
    NSString *dateAsString = [formatter stringFromDate:endDate];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeAsString = [formatter stringFromDate:endDate];
    
    NSString *endDateString = [NSString stringWithFormat:@"%@ at %@", dateAsString, timeAsString];
    return endDateString;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationPickerViewController *controller = (LocationPickerViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.selectedLocationName = locationName;
    }
}

- (void)locationPicker:(LocationPickerViewController *)picker didPickLocation:(NSString *)theLocationName
{
    locationName = theLocationName;
    [self updateLabels];
}

- (BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

@end

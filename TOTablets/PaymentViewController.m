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
#import "PaymentCompleteViewController.h"

const CGRect StripePortraitLocation = { { 452.0f, 395.0f }, { 290.0f, 55.0f } };
const CGRect StripeLandscapeLocation = { { 708.0f, 395.0f }, { 290.0f, 55.0f } };

@interface PaymentViewController ()

@end

@implementation PaymentViewController {
    NSDate *startDate;
    NSDate *endDate;
    NSString *publishableKey;
    NSString *locationName;
    NSString *currency;
    NSString *allTaxes;
    NSString *formattedEndDateString;
    NSString *environmentURL;
    NSInteger rentalFee;
    int tax;
    float days;
    float subtotal;
    float taxAmount;
    float grandTotal;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    environmentURL = @"http://localhost:3000";
//    environmentURL = @"https://www.totablets.com";
    
    self.locationDetailField.delegate = self;
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.stripeView = [[STPView alloc] initWithFrame:StripePortraitLocation];
    } else {
        self.stripeView = [[STPView alloc] initWithFrame:StripeLandscapeLocation];
    }
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
    
    self.payButton.enabled = NO;
    locationName = @"Hotel";
    self.locationLabel.text = locationName;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(hideKeyboard:)];
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"Loading info";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self locationInfo];
        });
    });
    
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
    taxAmount = subtotal * tax / 100.0;
    grandTotal = subtotal + taxAmount;
    
    startDate = [NSDate date];
    NSString *endDateString = [self formatDate:startDate];
    
    if (days == 1) {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f day, ending on %@", days, endDateString];
    } else {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f days, ending on %@", days, endDateString];
    }
    self.subtotalLabel.text = [NSString stringWithFormat:@"Sub-total (%0.0f days x $%d per day):", days, rentalFee / 100];
    self.subtotalAmount.text = [NSString stringWithFormat:@"$%.02f %@", subtotal / 100, currency];
    self.taxesLabel.text = [NSString stringWithFormat:@"Taxes (%@):", allTaxes];
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
    if (valid && [self fieldsFilledOut:0]) {
        self.payButton.enabled = YES;
        self.fillInAllFieldsLabel.text = @"";
    } else {
        self.payButton.enabled = NO;
        self.fillInAllFieldsLabel.text = @"Please fill in all fields";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.stripeView.paymentView isValid] && [self fieldsFilledOut:[text length]]) {
        self.payButton.enabled = YES;
        self.fillInAllFieldsLabel.text = @"";
    } else {
        self.payButton.enabled = NO;
        self.fillInAllFieldsLabel.text = @"Please fill in all fields";
    }
    return YES;
}

- (BOOL)fieldsFilledOut:(int)currentCharacters
{
    return ([self.locationDetailField.text length] + currentCharacters) > 0 &&
            ([self.nameField.text length] + currentCharacters) > 0 &&
            ([self.emailField.text length] + currentCharacters) > 0;
}

- (void)locationInfo
{
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    self.responseData = [NSMutableData data];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/location_info", environmentURL];
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
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    locationName = res[@"location_name"];
    self.locationLabel.text = locationName;
    currency = res[@"currency"];
    rentalFee = [res[@"rental_fee"] intValue];
    publishableKey = res[@"publishable_key"];
    self.stripeView.key = publishableKey;
    
    NSDictionary *taxes = res[@"taxes"];
    tax = 0;
    for (id key in taxes) {
        tax += [taxes[key] intValue];
    }
    
    NSArray *allTaxesAsArray = [taxes allKeys];
    allTaxes = [allTaxesAsArray componentsJoinedByString:@" and "];
        
    [self updateLabels];
    [HUD hide:YES];
}

- (IBAction)pay;
{
    self.payButton.enabled = NO;
    
    if ([self reachable]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"Processing payment";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.locationDetailField becomeFirstResponder];
                [self.locationDetailField resignFirstResponder];
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
    NSLog(@"Received token %@", token.tokenId);
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/rentals", environmentURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"days=%0.0f&location=%@&rate=%d&tax_names=%@&name=%@&email=%@&stripe_token=%@&grand_total=%0.0f&currency=%@&device_name=%@",
                          days, self.locationLabel.text, rentalFee, allTaxes, self.nameField.text, self.emailField.text, token.tokenId, grandTotal, currency, deviceUDID];
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
                                       [self sendCustomerData:token];
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@/capture_customer_data", environmentURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"days=%0.0f&start_date=%@&end_date=%@&location=%@&location_detail=%@&email=%@&rate=%d&subtotal=%0.0f&tax_names=%@&tax_percentage=%d&tax_amount=%0.0f&grand_total=%0.0f&currency=%@&device_name=%@",
                          days, startDate, endDate, self.locationLabel.text, self.locationDetailField.text, self.emailField.text, rentalFee, subtotal, allTaxes, tax, taxAmount, grandTotal, currency, deviceUDID];
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
    
    [components setHour: [components hour] + 1];
    [components setMinute: 0];
    [components setSecond: 0];
    
    endDate = [gregorian dateFromComponents: components];
    
    [formatter setDateFormat:@"MMM d, YYYY (EEE)"];
    NSString *dateAsString = [formatter stringFromDate:endDate];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeAsString = [formatter stringFromDate:endDate];
    
    NSString *endDateString = [NSString stringWithFormat:@"%@ at %@", dateAsString, timeAsString];
    formattedEndDateString = endDateString;
    return endDateString;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PaymentComplete"]) {
        PaymentCompleteViewController *controller = (PaymentCompleteViewController *)segue.destinationViewController;
        controller.customerName = self.nameField.text;
        controller.locationName = locationName;
        controller.email = self.emailField.text;
        controller.endDate = formattedEndDateString;
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

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    [self.locationDetailField becomeFirstResponder];
    [self.locationDetailField resignFirstResponder];
}

@end

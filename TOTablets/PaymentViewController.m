//
//  PaymentViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "PaymentViewController.h"
#import <QuartzCore/QuartzCore.h>

const CGRect StripePortraitLocation = { { 452.0f, 395.0f }, { 290.0f, 55.0f } };
const CGRect StripeLandscapeLocation = { { 708.0f, 395.0f }, { 290.0f, 55.0f } };
const int rentalFee = 25;
const int GST = 5;
const int PST = 7;
NSString *publishableKey = @"pk_test_mHRnRqLpMebdwnbKedxjzUvf";

@interface PaymentViewController ()

@end

@implementation PaymentViewController {
    NSString *locationDetail;
    NSString *name;
    NSString *email;
    NSDictionary *taxesByLocation;
    NSDate *startDate;
    NSDate *endDate;
    NSString *locationName;
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
                                    @[@"GST + PST", [NSNumber numberWithInteger:(GST + PST)]], @"Shangri-La, Vancouver",
                                    @[@"GST", [NSNumber numberWithInteger:GST]], @"Nuvo Hotel, Calgary"
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
    float subtotal = rentalFee * [self.stepper value];
    int tax = [taxesByLocation[self.locationLabel.text][1] integerValue];
    float taxAmount = subtotal * tax / 100.0;
    float grandTotal = subtotal + taxAmount;
    float days = [self.stepper value];
    
    startDate = [NSDate date];
    NSString *endDateString = [self formatDate:startDate];
    
    if (days == 1) {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f day, ending on %@", days, endDateString];
    } else {
        self.daysLabel.text = [NSString stringWithFormat:@"%0.0f days, ending on %@", days, endDateString];
    }
    self.subtotalLabel.text = [NSString stringWithFormat:@"Sub-total (%0.0f days x $%d per day):", days, rentalFee];
    self.subtotalAmount.text = [NSString stringWithFormat:@"$%.02f CAD", subtotal];
    self.taxesLabel.text = [NSString stringWithFormat:@"Taxes (%@):", taxesByLocation[self.locationLabel.text][0]];
    self.taxesAmount.text = [NSString stringWithFormat:@"(%d%%) $%.02f CAD", tax, taxAmount];
    self.grandTotalAmount.text = [NSString stringWithFormat:@"$%.02f CAD", grandTotal];
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
    // Call 'createToken' when the save button is tapped
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [self handleError:error];
        } else {
            // Send off token to your server
            [self handleToken:token];
            // Send name to own server
            // NSString *deviceUDID = [[UIDevice currentDevice] name];
        }
    }];
}

- (void)handleToken:(STPToken *)token
{
    NSLog(@"Received token %@", token.tokenId);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://example.com"]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   // Handle error
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

@end

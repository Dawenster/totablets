//
//  PaymentViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface PaymentViewController : UITableViewController <STPViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *daysLabel;
@property (nonatomic, strong) IBOutlet UILabel *location;
@property STPView* stripeView;
@property (nonatomic, strong) IBOutlet UIButton *payButton;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@property (nonatomic, strong) IBOutlet UILabel *subtotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtotalAmount;
@property (nonatomic, strong) IBOutlet UILabel *taxesLabel;
@property (nonatomic, strong) IBOutlet UILabel *taxesAmount;
@property (nonatomic, strong) IBOutlet UILabel *grandTotalAmount;

- (IBAction)cancel:(id)sender;
- (IBAction)changeDays;
- (IBAction)pay;

@end

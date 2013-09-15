//
//  PaymentViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "MBProgressHUD.h"

@interface PaymentViewController : UITableViewController <STPViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UILabel *daysLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UITextField *locationDetailField;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UILabel *creditCardLabel;
@property STPView* stripeView;
@property (nonatomic, strong) IBOutlet UIButton *payButton;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@property (nonatomic, strong) IBOutlet UILabel *subtotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtotalAmount;
@property (nonatomic, strong) IBOutlet UILabel *taxesLabel;
@property (nonatomic, strong) IBOutlet UILabel *taxesAmount;
@property (nonatomic, strong) IBOutlet UILabel *grandTotalAmount;
@property (nonatomic, strong) IBOutlet UILabel *preAuthAmountLabel;
@property (nonatomic, strong) IBOutlet UITextView *termsAndConditionsTextView;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UILabel *fillInAllFieldsLabel;
@property (nonatomic, strong) UIPopoverController *adminPopoverController;
@property (nonatomic, strong) IBOutlet UILabel *adultContentLabel;
@property (nonatomic, strong) IBOutlet UISwitch *adultContentSwitch;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *adminButton;

- (IBAction)cancel:(id)sender;
- (IBAction)changeDays;
- (IBAction)pay;
- (IBAction)restrictionToggled:(id)sender;
- (IBAction)checkBox:(id)sender;

@end

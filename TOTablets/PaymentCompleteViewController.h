//
//  PaymentCompleteViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-19.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface PaymentCompleteViewController : UIViewController <UIAlertViewDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) NSString *endDateString;
@property (nonatomic, strong) IBOutlet UILabel *endDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timerLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *rentalStartLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondsLabel;
@property (nonatomic, strong) IBOutlet UIView *signOutWarning;
@property (nonatomic, strong) IBOutlet UIButton *finishRental;
@property (nonatomic, strong) IBOutlet UIImageView *upArrow;
@property (nonatomic, strong) IBOutlet UIImageView *bottomArrow;
@property (nonatomic, strong) IBOutlet UIImageView *leftArrow;
@property (nonatomic, strong) IBOutlet UIImageView *rightArrow;
@property (nonatomic, strong) NSMutableData *responseData;

- (IBAction)finishRentalLock;

@end

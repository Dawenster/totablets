//
//  PaymentCompleteViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-19.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentCompleteViewController : UIViewController

@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) IBOutlet UILabel *endDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timerLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *rentalStartLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondsLabel;

@end

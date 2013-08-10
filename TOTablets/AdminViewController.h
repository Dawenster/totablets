//
//  AdminViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-08-08.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PaymentViewController.h"

@interface AdminViewController : UITableViewController <UITextFieldDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) PaymentViewController *paymentView;
@property (nonatomic, strong) NSString *adminPassword;

@end

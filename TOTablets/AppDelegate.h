//
//  AppDelegate.h
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"
#import "PaymentCompleteViewController.h"
#import "AdminViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PaymentViewController *paymentViewController;
@property (strong, nonatomic) PaymentCompleteViewController *paymentCompleteViewController;

@end

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

@property STPView* stripeView;

@end

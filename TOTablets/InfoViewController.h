//
//  ViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPCard.h"
#import "MBProgressHUD.h"

@interface InfoViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableData *responseData;

- (IBAction)finishRentalLock;

@end

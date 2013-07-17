//
//  LocationPickerViewController.h
//  TOTablets
//
//  Created by David Wen on 2013-07-16.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationPickerViewController;

@protocol LocationPickerViewControllerDelegate <NSObject>

- (void)locationPicker:(LocationPickerViewController *)picker didPickLocation:(NSString *)locationName;

@end

@interface LocationPickerViewController : UITableViewController

@property (nonatomic, weak) id <LocationPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedLocationName;

- (IBAction)cancel:(id)sender;

@end

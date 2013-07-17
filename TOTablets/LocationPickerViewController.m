//
//  LocationPickerViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-16.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "LocationPickerViewController.h"

@implementation LocationPickerViewController {
    NSArray *locations;
    NSIndexPath *selectedIndexPath;
}

@synthesize delegate, selectedLocationName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locations = [NSArray arrayWithObjects:
                  @"Shangri-La, Vancouver",
                  @"Nuvo Hotel, Calgary",
                  nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *locationName = [locations objectAtIndex:indexPath.row];
    cell.textLabel.text = locationName;
    
    if ([locationName isEqualToString:self.selectedLocationName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != selectedIndexPath.row) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        selectedIndexPath = indexPath;
    }
    
    NSString *locationName = [locations objectAtIndex:indexPath.row];
    [self.delegate locationPicker:self didPickLocation:locationName];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

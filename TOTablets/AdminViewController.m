//
//  AdminViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-08-08.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "AdminViewController.h"

@interface AdminViewController ()

@end

@implementation AdminViewController {
    NSString *environmentURL;
    NSString *enteredPassword;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(250, 240);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    environmentURL = @"http://localhost:3000";
    environmentURL = @"https://www.totablets.com";
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 120);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 300, 60)];
        textField.clearsOnBeginEditing = NO;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.font = [UIFont fontWithName:@"Helvetica" size:30];
        textField.placeholder = @"Password";
        textField.autocapitalizationType = NO;
        textField.secureTextEntry = YES;
        [cell.contentView addSubview:textField];
    } else {
        UIButton *unlock = [UIButton buttonWithType:UIButtonTypeCustom];
        [unlock addTarget:self action:@selector(unlock:)
           forControlEvents:UIControlEventTouchUpInside];
        unlock.frame = CGRectMake(10, 12, 145, 36);
        UIImage *unlockImage = [[UIImage imageNamed:@"greenButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0,10.0,0.0,10.0)];
        UIImage *unlockImageHighlighted = [[UIImage imageNamed:@"greenButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0,10.0,0.0,10.0)];
        [unlock setTitle:@"Unlock" forState:UIControlStateNormal];
        [unlock setBackgroundImage:unlockImage forState:UIControlStateNormal];
        [unlock setBackgroundImage:unlockImageHighlighted forState:UIControlStateHighlighted];
        unlock.userInteractionEnabled = YES;

        [cell.contentView addSubview:unlock];
        
        UIButton *lock = [UIButton buttonWithType:UIButtonTypeCustom];
        [lock addTarget:self action:@selector(lock:)
         forControlEvents:UIControlEventTouchUpInside];
        lock.frame = CGRectMake(165, 12, 145, 36);
        UIImage *lockImage = [[UIImage imageNamed:@"tanButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0,10.0,0.0,10.0)];
        UIImage *lockImageHighlighted = [[UIImage imageNamed:@"tanButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0,10.0,0.0,10.0)];
        [lock setTitle:@"Lock" forState:UIControlStateNormal];
        [lock setBackgroundImage:lockImage forState:UIControlStateNormal];
        [unlock setBackgroundImage:lockImageHighlighted forState:UIControlStateHighlighted];
        [lock setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:lock];
        
        lock.userInteractionEnabled = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)unlock:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if ([self.adminPassword isEqualToString:enteredPassword]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.paymentView.view animated:YES];
        HUD.labelText = @"Unlocking...";
        [self adminCommand:@"unlock"];
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.paymentView.view animated:NO];
        HUD.labelText = @"Incorrect password - please try again.";
        [HUD hide:YES afterDelay:2];
    }
}

- (void)lock:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([self.adminPassword isEqualToString:enteredPassword]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.paymentView.view animated:YES];
        HUD.labelText = @"Locking...";
        [self adminCommand:@"lock"];
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.paymentView.view animated:NO];
        HUD.labelText = @"Incorrect password - please try again.";
        [HUD hide:YES afterDelay:2];
    }
}

- (void)adminCommand:(NSString *)command
{
    NSString *deviceUDID = [[UIDevice currentDevice] name];
    self.responseData = [NSMutableData data];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/admin_command", environmentURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"ipad_name=%@&command=%@", deviceUDID, command];
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Escaped Body: %@", escapedBody);
    
    request.HTTPBody = [escapedBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"Connection description: %@",connection.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
    [self noConnectionError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSString *command = res[@"command"];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    if ([command isEqualToString:@"unlock"]) {
        HUD.labelText = @"Device being unlocked - try pressing the home key in one minute.";
        [self.paymentView.adminPopoverController dismissPopoverAnimated:YES];
    } else {
        HUD.labelText = @"Device will lock itself shortly.";
        [self.paymentView.adminPopoverController dismissPopoverAnimated:YES];
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.paymentView.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)noConnectionError
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:@"No internet connection - please see the front desk for assistance."
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    enteredPassword = text;
    return YES;
}

@end

//
//  ViewController.m
//  TOTablets
//
//  Created by David Wen on 2013-07-15.
//  Copyright (c) 2013 TOTablets. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController {
    NSArray *images;
    int offset;
    int offsetAmount;
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self loadImages:self.interfaceOrientation];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.scrollView.frame = CGRectMake(0, -20, 768, 1024);
    } else {
        self.scrollView.frame = CGRectMake(0, 255, 1024, 768);
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self loadImages:toInterfaceOrientation];
}

- (void)loadImages:(UIInterfaceOrientation)interfaceOrientation
{
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        UIImageView *map_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_portrait.jpg"]];
        UIImageView *facebook_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook_portrait.jpg"]];
        UIImageView *netflix_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"netflix_portrait.jpg"]];
        UIImageView *game_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game_portrait.jpg"]];
        UIImageView *skype_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skype_portrait.png"]];
        UIImageView *vancouver_p = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vancouver_portrait.jpg"]];
        
        images = @[map_p, facebook_p, netflix_p, game_p, skype_p, vancouver_p];
        
        self.scrollView.frame = CGRectMake(0, -255, 768, 1024);
        self.scrollView.contentSize = CGSizeMake(768 * [images count], 1024);
        offsetAmount = 768;
    } else {
        UIImageView *map_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_landscape.jpg"]];
        UIImageView *facebook_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook_landscape.jpg"]];
        UIImageView *netflix_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"netflix_landscape.jpg"]];
        UIImageView *game_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game_landscape.jpg"]];
        UIImageView *skype_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skype_landscape.jpg"]];
        UIImageView *vancouver_l = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vancouver_landscape.jpg"]];
        
        images = @[map_l, facebook_l, netflix_l, game_l, skype_l, vancouver_l];
        
        self.scrollView.frame = CGRectMake(0, 260, 1024, 768);
        self.scrollView.contentSize = CGSizeMake(1024 * [images count], 768);
        offsetAmount = 1024;
    }
    
    int page = 0;
    
    for (UIImageView *imageView in images) {
        float imageWidth = imageView.image.size.width;
        float imageHeight = imageView.image.size.height;
        imageView.frame = CGRectMake(page * imageWidth, 0, imageWidth, imageHeight);
        [self.scrollView addSubview:imageView];
        
        page += 1;
    }
    offset = offset - (offset % offsetAmount);
}

- (void) onTimer {
    offset += offsetAmount;
    if (self.scrollView.contentSize.width <= offset) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        offset = 0;
    } else {
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    offset = scrollView.contentOffset.x;
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

@end

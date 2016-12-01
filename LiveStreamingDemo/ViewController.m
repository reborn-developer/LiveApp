//
//  ViewController.m
//  LiveStreamingDemo
//
//  Created by reborn on 16/11/21.
//  Copyright © 2016年 reborn. All rights reserved.
//

#import "ViewController.h"
#import "CustomPreview.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CustomPreview *customPreview = [[CustomPreview alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:customPreview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end

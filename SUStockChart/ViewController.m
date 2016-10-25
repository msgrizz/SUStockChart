//
//  ViewController.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "SSCDataSource.h"
#import "SSCChartViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.button];
    [self makeConstraints];
    
    [SSCDataSource loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)buttonTapped:(UIButton *)sender{
    SSCChartViewController *toViewController = [[SSCChartViewController alloc] init];
    [self presentViewController:toViewController animated:NO completion:NULL];
}

#pragma mark - Constraints
    
- (void)makeConstraints{
    __weak typeof(self) weakSelf = self;
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.view);
    }];
}

#pragma mark - Properties
    
- (UIButton *)button{
    if (!_button) {
        _button = [UIButton new];
        [_button setTitle:@"Launch Chart" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

@end

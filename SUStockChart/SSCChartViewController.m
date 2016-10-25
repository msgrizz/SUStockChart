//
//  SSCChartViewController.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCChartViewController.h"
#import "Masonry.h"
#import "SSCChartView.h"
#import "SSCDataSource.h"

@interface SSCChartViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) SSCChartView *chartView;
@end

@implementation SSCChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.chartView];
    
    [self makeConstraints];
    
    NSArray *dataSource = [SSCDataSource loadData];
    [_chartView setContent:dataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)buttonTapped:(UIButton *)sender{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark - Constraints

- (void)makeConstraints{
    CGFloat headerHeight = 30.;
    CGFloat margin = 20.;
    __weak typeof(self) weakSelf = self;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(10.);
        make.height.mas_equalTo(headerHeight);
        make.width.equalTo(weakSelf.view).multipliedBy(0.5);
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(headerHeight);
        make.right.top.equalTo(weakSelf.view);
    }];
    
    [_chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(headerHeight);
        make.left.equalTo(weakSelf.view).offset(margin);
        make.right.bottom.equalTo(weakSelf.view).offset(-margin);
    }];
}

#pragma mark - Properties

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
    }
    return _nameLabel;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton new];
        [_closeButton setTitle:@"X" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (SSCChartView *)chartView{
    if (!_chartView) {
        _chartView = [SSCChartView new];
    }
    return _chartView;
}

@end

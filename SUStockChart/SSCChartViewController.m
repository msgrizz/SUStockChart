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
#import "UIColor+SSCColorStyle.h"
#import "SSCDayModel.h"

@interface SSCChartViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) SSCChartView *chartView;
@end

@implementation SSCChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ssc_backgroundColor];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.chartView];
    
    [self makeConstraints];
    
    NSArray *dataSource = [SSCDataSource loadData];
    [_chartView setContent:dataSource];
    
    if (dataSource.count > 0) {
        SSCDayModel *dayModel = dataSource.firstObject;
        _nameLabel.text = [NSString stringWithFormat:@"%@  %@", dayModel.name, dayModel.code];
    }
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
    CGFloat headerHeight = 40.;
    CGFloat margin = 20.;
    __weak typeof(self) weakSelf = self;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(10.);
        make.height.mas_equalTo(headerHeight);
        make.width.equalTo(weakSelf.view).multipliedBy(0.5);
    }];
    
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.equalTo(weakSelf.view).offset(-5.);
        make.centerY.equalTo(weakSelf.nameLabel);
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
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton new];
        [_closeButton setTitle:@"X" forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont fontWithName:@"PingFangHK-Light" size:15.];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.backgroundColor = [UIColor blackColor];
        _closeButton.layer.cornerRadius = 12.;
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

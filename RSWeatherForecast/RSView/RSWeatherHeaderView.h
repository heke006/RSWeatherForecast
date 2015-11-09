//
//  RSWeatherHeaderView.h
//  RSWeatherForecast
//
//  Created by hehai on 10/29/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSWeatherHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *cityLabel; // 城市名称
@property (weak, nonatomic) IBOutlet UIImageView *iconView; // 天气图标
@property (weak, nonatomic) IBOutlet UILabel *conditionsLabel; // 天气描述
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel; // 此时天气的温度
@property (weak, nonatomic) IBOutlet UILabel *hiloLabel; // 当天最高、最低温

/**
 *下一个版本使用，此版暂时留空
 */
@property (weak, nonatomic) IBOutlet UIImageView *smileImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smileBottemConstraint;

@end

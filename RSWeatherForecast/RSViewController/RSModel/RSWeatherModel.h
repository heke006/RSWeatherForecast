//
//  RSWeatherModel.h
//  RSWeatherForecast
//
//  Created by hehai on 10/29/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSWeatherModel : NSObject
@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) float maxTemp;
@property (nonatomic, assign) float minTemp;
@property (nonatomic, assign) float time;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, assign) float temp;
@property (nonatomic, strong) NSString *weatherDesc;
@property (nonatomic, strong) NSString *cityName;

+ (id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic;
+ (id)weatherWithDailyJSON:(NSDictionary *)dailyDic;
+ (id)weatherWithCurrentJSON:(NSDictionary *)currentDic;
@end

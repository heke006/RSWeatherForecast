//
//  RSWeatherModel.m
//  RSWeatherForecast
//
//  Created by hehai on 10/29/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import "RSWeatherModel.h"

@implementation RSWeatherModel

+ (id)weatherWithHourlyJSON:(NSDictionary *)hourlyDic {
    return [[self alloc] initWithHourlyJSON:hourlyDic];
}

- (id)initWithHourlyJSON:(NSDictionary *)hourlyDic {
    if (self = [super init]) {
        self.temp = [hourlyDic[@"tempC"] floatValue];
        self.time = [hourlyDic[@"time"] floatValue] / 100;
        NSString *iconStr = hourlyDic[@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    return self;
}

+ (id)weatherWithDailyJSON:(NSDictionary *)dailyDic {
    return [[self alloc] initWithDailyJSON:dailyDic];
}

- (id)initWithDailyJSON:(NSDictionary *)dailyDic {
    if (self = [super init]) {
        self.date = dailyDic[@"date"];
        self.maxTemp = [dailyDic[@"maxtempC"] floatValue];
        self.minTemp = [dailyDic[@"mintempC"] floatValue];
        NSString *str = dailyDic[@"hourly"][0][@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:str];
    }
    return self;
}

+ (id)weatherWithCurrentJSON:(NSDictionary *)currentDic {
    return [[self alloc] initWithCurrentJSON:currentDic];
}
- (id)initWithCurrentJSON:(NSDictionary *)currentDic {
    if (self = [super init]) {
        NSDictionary *dataDic = currentDic[@"data"];
        
        self.cityName = dataDic[@"request"][0][@"query"];
        NSString *iconStr = dataDic[@"current_condition"][0][@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
        self.weatherDesc = dataDic[@"current_condition"][0][@"weatherDesc"][0][@"value"];
        self.temp = [dataDic[@"current_condition"][0][@"temp_C"] floatValue];
        self.maxTemp = [dataDic[@"weather"][0][@"maxtempC"] floatValue];
        self.minTemp = [dataDic[@"weather"][0][@"mintempC"] floatValue];
    }
    return self;
}

@end

















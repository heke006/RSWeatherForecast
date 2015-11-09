;//
//  RSWeatherViewController.m
//  RSWeatherForecast
//
//  Created by hehai on 10/29/15.
//  Copyright (c) 2015 hehai. All rights reserved.
//

#import "RSWeatherViewController.h"
#import "RSWeatherHeaderView.h"
#import "RSWeatherModel.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface RSWeatherViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RSWeatherHeaderView *headerView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) NSArray *hourlyArray;
@property (nonatomic, strong) NSArray *dailyArray;
// 图片缓存 相关属性
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *imagesDic;
@property (nonatomic, strong) NSString *cachesPath;

@end

@implementation RSWeatherViewController

#pragma mark - lifeCycle

/**
 针对正在下载的操作：
 遇到内存警告时，取消所有正在下载的操作，清除字典中的数据
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [NSThread sleepForTimeInterval:3]; // 延迟加载，使得launchImage显示时间加长
    
    [self.queue cancelAllOperations];
    [self.imagesDic removeAllObjects];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *viewContainer = self.view;
    [viewContainer addSubview:self.tableView];
    
    [self sendRequestGetJSON];
    
    [self reFreshTableView];
    
}

#pragma mark - headerRefresh

- (void)reFreshTableView {
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 马上进入刷新状态(即，刚运行程序就自动刷新)
//    [self.tableView.header beginRefreshing];
}

- (void)loadNewData
{
    // 1.重新发送网络请求
    [self sendRequestGetJSON];
    // 2.刷新tableView的数据
    [self.tableView reloadData];
    // 3.拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.header endRefreshing];
}

#pragma mark - sendRequest & parseData

- (void)sendRequestGetJSON {
    // get请求写法 http
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=beijing&num_of_days=4&format=json&tp=6&key=fc13dda9c3d3298029579d2016d32"]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (statusCode == 200) {
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.hourlyArray = [self hourlyWeatherFromJSON:jsonDic];
            self.dailyArray = [self dailyWeatherFromJSON:jsonDic];
            // reload data for tableView
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateHeaderView:jsonDic];
                
                [self.tableView reloadData];
            });
            
        } else {
            NSLog(@"error:%@",error.userInfo);
        }
    }];
    
    [task resume];
}

- (void)updateHeaderView:(NSDictionary *)jsonDic {
    RSWeatherModel *weatherModel = [RSWeatherModel weatherWithCurrentJSON:jsonDic];
    self.headerView.cityLabel.text = weatherModel.cityName;
    self.headerView.conditionsLabel.text = weatherModel.weatherDesc;
    self.headerView.temperatureLabel.text = [NSString stringWithFormat:@"%.0f˚",weatherModel.temp];
    self.headerView.hiloLabel.text = [NSString stringWithFormat:@"%.0f˚-%.0f˚",weatherModel.maxTemp,weatherModel.minTemp];

//#warning TODO placeholder不显示？
    // 使用第三方库 设置 headerView
    [self.headerView.iconView sd_setImageWithURL:weatherModel.iconURL placeholderImage:[UIImage imageNamed:@"weather-clear"]];
}

- (NSArray *)hourlyWeatherFromJSON:(NSDictionary *)jsonDic {
    NSMutableArray *hourlyMutableArray = [NSMutableArray array];
    NSArray *hourlyArray = jsonDic[@"data"][@"weather"][0][@"hourly"];
    for (NSDictionary *hourlyDic in hourlyArray) {
        RSWeatherModel *hourlyModel = [RSWeatherModel weatherWithHourlyJSON:hourlyDic];
        [hourlyMutableArray addObject:hourlyModel];
    }
    return [hourlyMutableArray copy];
}

- (NSArray *)dailyWeatherFromJSON:(NSDictionary *)jsonDic {
    NSMutableArray *dailyMutableArray = [NSMutableArray array];
    NSArray *dailyArray = jsonDic[@"data"][@"weather"];
    for (NSDictionary *dailyDic in dailyArray) {
        RSWeatherModel *dailyModel = [RSWeatherModel weatherWithDailyJSON:dailyDic];
        [dailyMutableArray addObject:dailyModel];
    }
    
    return [dailyMutableArray copy];
}

#pragma mark - tableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.hourlyArray.count + 1 : self.dailyArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Cell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    // iOS6+此方法一定会返回一个可用的cell,但是，需要注册registe，而且不能在此设置cell的style；对于自定义cell的情况更加适合（在定义的位置已经设置好了）
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    } // 使用此方法，不需要提前注册，可以设置cell的style，对于系统定义的style比较合适
    
    //设置cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Hourly Forecast";
            cell.imageView.image = nil;
            cell.detailTextLabel.text = @"";
        } else {
            //
            RSWeatherModel *weatherModel = self.hourlyArray[indexPath.row - 1];
            [self configureCell:cell weather:weatherModel atIndexPath:indexPath isHourly:YES];
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Daily Forecast";
        } else {
            //
            RSWeatherModel *weatherModel = self.dailyArray[indexPath.row - 1];
            [self configureCell:cell weather:weatherModel atIndexPath:indexPath isHourly:NO];
        }
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell weather:(RSWeatherModel *)weatherModel atIndexPath:(NSIndexPath *)indexPath isHourly:(BOOL)isHourly {
    // isHourly : YES / NO
    cell.textLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f:00",weatherModel.time] :weatherModel.date;
    
    cell.detailTextLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f",weatherModel.temp] : [NSString stringWithFormat:@"%.f˚/%.f˚",weatherModel.maxTemp,weatherModel.minTemp];
    
/**
 图片缓存的主逻辑:
 图片缓存是为了：节省用户流量，程序优化，不占用太大内存
 */
    
    // 使用第三方库
    [cell.imageView sd_setImageWithURL:weatherModel.iconURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return [UIScreen mainScreen].bounds.size.height / cellCount;
}

#pragma mark - setter & getter

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect bounds = self.view.bounds;
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:bounds];
        self.backgroundImageView.image = [UIImage imageNamed:@"RSWeather_bg"];
        [self.view addSubview:self.backgroundImageView];
        
        _tableView = [UITableView new];
        _tableView.frame = bounds;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.pagingEnabled = YES;
        _tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        
        _tableView.tableHeaderView = self.headerView;

    }
    return _tableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        
        // 注意：此处是在加载 RSWeatherHeaderView 对应的 xib 文件
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"RSWeatherHeaderView" owner:self options:nil] lastObject];
        
        [_headerView setFrame:[UIScreen mainScreen].bounds];
        _headerView.backgroundColor = [UIColor clearColor];

    }
    return _headerView;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSMutableDictionary *)imagesDic {
    if (!_imagesDic) {
        _imagesDic = [NSMutableDictionary new];
    }
    return _imagesDic;
}

- (NSString *)cachesPath {
    if (!_cachesPath) {
        _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
    return _cachesPath;
}

@end

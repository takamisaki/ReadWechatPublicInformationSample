#import "ViewController.h"
#import "SVProgressHUD.h" //引入弹窗框架


@interface ViewController ()
@property (weak,   nonatomic) IBOutlet UIImageView    *user1;       //三个显示头像的 UIImageView
@property (weak,   nonatomic) IBOutlet UIImageView    *user2;
@property (weak,   nonatomic) IBOutlet UIImageView    *user3;
@property (strong, nonatomic)          NSMutableArray *imageArray;  //存储图片的数组
@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = [NSMutableArray array];
}


/*  点击按钮开始获取用户头像
    1. 建立服务器连接, 获取用户头像的原始数据(是个字符串)
    2. 分割字符串, 根据字符串下载对应的头像图片, 存在数组里
    3. 主线程更新UI: 把数组里的图片都显示在界面上.
 */
- (IBAction)buttonClicked: (id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://takawechat.duapp.com/getUserInfo.php"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error)
    {
        //容错处理
        if (error) {
            NSLog(@"%@",error);
            [self showHudWithString:@"网络错误, 请稍后重试"];
            return;
        }
        
        
        //如果下载到数据
        if (data.bytes != 0) {
            
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //分割字符串, 我在 php 文件里加入了后缀#####, 用来标识每个头像网址的结束
            NSArray<NSString*> *headImageArray = [string componentsSeparatedByString:@"#####"];
            
            int count = (int)headImageArray.count;
            
            for (int index = 0; index < count; index ++) {
            
                if ([headImageArray[index] hasPrefix:@"http:"]) {
                    NSURL *urlTemp = [NSURL URLWithString:headImageArray[index]];
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlTemp]];
                    [self.imageArray addObject:image];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.user1.image = self.imageArray[0];
                self.user2.image = self.imageArray[1];
                
                //如果老师帮忙关注一下, 可以显示第三个头像
                if (self.imageArray.count > 2) {
                    self.user3.image = self.imageArray[2];
                }
            });
            
        }else {
            [self showHudWithString:@"获取数据失败"];
            return;
        }
    }];
    [dataTask resume];
}


//弹窗时间为2秒, 显示内容是参数 string
- (void)showHudWithString: (NSString *)string {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:string];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

@end

//
//  RFDevicesVC.m
//  kangtai
//
//  Created by 张群 on 14/12/15.
//
//

#import "RFDevicesVC.h"
#import "Open_CloseManage.h"
#import "Open_CloseStatu.h"
#import "UIImage+CH.h"
static CGFloat CellHeight = 80.f;
static NSString *CellIdentifier = @"CellIdentifier";

@interface RFDevicesVC () <EditableTableControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    int backNumber;
    NSMutableArray *nameArr;
    NSMutableArray *typeArr;
    NSMutableArray *iconArr;
}

@property (nonatomic, strong) EditableTableController *editableTableController;
@property (nonatomic, strong) UITableView *RFTableView;
@property (strong,nonatomic) NSString  *imageSTring;

@end

@implementation RFDevicesVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSLog(@"=== %@ ===",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES));
    
    [MMProgressHUD showWithStatus:NSLocalizedString(@"Loading", nil)];

    [self.RFMacStrArr removeAllObjects];
    NSMutableArray *deviceArr = [DataBase ascWithRFtableINOrderNumber];
    for (int i = 0; i < deviceArr.count; i++) {
        Device *device = deviceArr[i];
        if ([device.deviceType intValue] == 31) {
            if (![self.RFMacStrArr containsObject:device.macString]) {
                [self.RFMacStrArr addObject:device.macString];
            }
        }
    }
    
    self.dataDAY = [RFDataBase ascWithRFTableINorderNumber];

//    [NSThread detachNewThreadSelector:@selector(downloadTableViewData) toTarget:self withObject:nil];
    for (int i = 0; i < 3; i++) {
        [self.RFTableView reloadData];
    }

    [self performSelector:@selector(dismisHUD) withObject:nil afterDelay:1.3f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getOnlineOrOfflineInfo:) name:@"getOnlineOrOfflineInfo" object:nil];
    
    [self initVariable];
    [self initUI];
}

#pragma mark - initUI & initVariable
- (void)initVariable
{
    backNumber = 1;
    self.hide = 1;
    self.isClicked = YES;
    self.dataDAY = [[NSMutableArray alloc] initWithCapacity:0];
    self.RFMacStrArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    typeArr = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Switch", nil), NSLocalizedString(@"Dimmer", nil), NSLocalizedString(@"Curtain", nil), NSLocalizedString(@"Thermostat", nil), nil];
}

- (void)initUI
{
    self.titlelab.text = NSLocalizedString(@"RF Devices", nil);
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_normal.png"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_click.png"] forState:UIControlStateHighlighted];
    [self.rightBut setBackgroundImage:[UIImage imageNamed:@"add_normal.png"] forState:UIControlStateNormal];
    [self.rightBut setBackgroundImage:[UIImage imageNamed:@"add_click.png"] forState:UIControlStateHighlighted];
    
    self.RFTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, barViewHeight, kScreen_Width, kScreen_Height - barViewHeight - iOS_6_height) style:UITableViewStylePlain];
    self.RFTableView.rowHeight = CellHeight;
    self.RFTableView.delegate = self;
    self.RFTableView.dataSource = self;
    self.RFTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.RFTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

    [self.RFTableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [self.view addSubview:self.RFTableView];
    
    self.editableTableController = [[EditableTableController alloc] initWithTableView:self.RFTableView];
    [self.editableTableController setEnabled:NO];
    self.editableTableController.delegate = self;
}

#pragma mark - dismisHUD
- (void)dismisHUD
{
    [MMProgressHUD dismiss];
}

- (void)downloadTableViewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self getDeviceRFTableRequestHttpToServerWord:[defaults objectForKey:KEY_USERMODEL] WithPassWord:[defaults objectForKey:KEY_PASSWORD]];
}

- (void)updateData
{
    [self performSelector:@selector(reloadTableViewData) withObject:nil afterDelay:.6f];
}

- (void)reloadTableViewData
{
    [self.RFTableView reloadData];
}

#pragma mark - getOnlineOrOfflineInfo
- (void)getOnlineOrOfflineInfo:(NSNotification *)notification
{
    NSString *macStr = [notification object];
    
    Device *decix = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:macStr];
    if (decix == nil) {
        return;
    }
    
    if ([decix.deviceType isEqualToString:@"31"]) {
        if ([decix.localContent isEqualToString:@"0"] && [decix.remoteContent isEqualToString:@"0"])
        {
            decix.hver = @"0";
        }
        else{
            
            decix.hver = @"1";
            
        }
    }
    
    [self.RFTableView reloadData];
}

#pragma mark - headerBeginRefresh
- (void)refreshHeader
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self getDeviceRFTableRequestHttpToServerWord:[defaults objectForKey:KEY_USERMODEL] WithPassWord:[defaults objectForKey:KEY_PASSWORD]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.RFTableView reloadData];
        [self.RFTableView headerEndRefreshing];
    });
}

#pragma mark - 获取 RF 设备列表
- (void)getDeviceRFTableRequestHttpToServerWord:(NSString *)email WithPassWord:(NSString *)passwprd
{
    NSString *tempString = [Util getPassWordWithmd5:passwprd];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:email forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [HTTPService GetHttpToServerWith:GetRFInfoURL WithParameters:dict  success:^(NSDictionary *dic) {
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            
            NSArray *tempArray = [dic objectForKey:@"list"];
            
            if (tempArray.count !=0 || tempArray.count == 0)
            {
                
                NSMutableArray *listArray = [RFDataBase ascWithRFTableINorderNumber];
                
                if (listArray.count != 0) {
                    for (RFDataModel *model in listArray)
                    {
                        [RFDataBase deleteDataFromDataBase:model];
                    }
                }
            }
            
            // 添加到数据库
            for (NSDictionary *dictary in tempArray)
            {
                RFDataModel *model = [[RFDataModel alloc] init];
                model.rfDataLogo = [dictary objectForKey:@"imageName"];
                model.rfDataMac = [dictary objectForKey:@"macAddress"];
                model.rfDataName = [dictary objectForKey:@"deviceName"];
                model.typeRF = [dictary objectForKey:@"type"];
                model.address = [dictary objectForKey:@"addressCode"];
                model.orderNumber = [[dictary objectForKey:@"orderNumber"] integerValue];
                
                [RFDataBase insertIntoDataBase:model];
                
            }
            self.dataDAY = [RFDataBase ascWithRFTableINorderNumber];

            [self downLoadRFimageView];
            
        }
        if ([success boolValue] == false) {
            
            
        }
        
        
    } error:^(NSError *error) {
        NSLog(@"error");
    }];
    
}

- (void)downLoadRFimageView
{
    NSMutableArray *modelArray =[RFDataBase ascWithRFTableINorderNumber];
    
    for (RFDataModel *model in modelArray) {
        
        
        NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@",model.rfDataLogo]];//获取程序包中相应文件的路径
        NSFileManager *fileMa = [NSFileManager defaultManager];
        
        if(![fileMa fileExistsAtPath:dataPath]) //
        {
        
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:[Util getFilePathWithImageName:model.rfDataLogo]]) {
                
                [self httdpwnload:model.rfDataLogo];
            }
            
            
        }else{
            
            continue;
            
        }
        
        [_RFTableView reloadData];
    }
}

- (void)httdpwnload:(NSString *)url
{
    [HTTPService downloadWithFilePathString:[NSString stringWithFormat:@"%@/%@",UploadedFileImageUrl,url] downLoadPath:^(NSString *filePath) {
        
        NSLog(@"file=%@",filePath);
    } error:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataDAY.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    RFDeviceCell *cell = [[RFDeviceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    RFDataModel *model = [self.dataDAY objectAtIndex:indexPath.row];
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:model.rfDataMac];
    
    UIImage *endImage;
    NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@",model.rfDataLogo]];//获取程序包中相应文件的路径
    NSFileManager *fileMa = [NSFileManager defaultManager];
    
    NSLog(@"---> rf device image name === %d", (int)model.rfDataLogo.length);
    
    if (model.rfDataLogo.length != 0) {
        if(![fileMa fileExistsAtPath:dataPath]){
            
            NSData *imgData = [NSData dataWithContentsOfFile:[Util getFilePathWithImageName:model.rfDataLogo]];
            if (imgData.length == 0) {
                endImage = [UIImage imageNamed:@"13.png"];
            } else {
                endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:model.rfDataLogo]];
            }
        }else{
            endImage = [UIImage imageNamed:model.rfDataLogo];
        }
    } else {
        endImage = [UIImage imageNamed:@"13.png"];
    }
    
    UIImage *grayImage = [UIImage grayImage:endImage];
    Open_CloseStatu *HJFstatu = [Open_CloseManageInstance getDevicePreFWithRfDataId:model.rfDataId];
    if (HJFstatu.deviceOpen) {
        cell.iconImageV.image = endImage;
    }else{
        cell.iconImageV.image = grayImage;
    }
    
//    cell.iconImageV.image = endImage;
    cell.deviceName.text = model.rfDataName;
    cell.deviceTypeLabel.text = device.name;
    
    if ([device.hver intValue] == 0) {
        cell.offlineLabel.hidden = NO;
    } else {
        cell.offlineLabel.hidden = YES;
    }

    
    if (self.hide == 1) {
        cell.delView.hidden = YES;
    }
    if (self.hide == 2) {
        cell.delView.hidden = NO;
        [cell bringSubviewToFront:cell.delView];
    }
    
    cell.tag = indexPath.row + 333;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(showDeleteView:)];
    longPress.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *delTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelectedCell:)];
    delTap.tag = [NSString stringWithFormat:@"%d", 10000 + (int)indexPath.row];
    cell.delView.userInteractionEnabled = YES;
    [cell.delView addGestureRecognizer:delTap];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Util getAppDelegate].rootVC.pan.enabled = NO;
    [Util getAppDelegate].rootVC.tap.enabled = NO;

    RFDataModel *model = [self.dataDAY objectAtIndex:indexPath.row];
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:model.rfDataMac];
    NSLog(@"zq === %@",device.hver);
    
    if (self.isClicked == YES && [device.hver intValue] != 0) {
        RFDataModel *model = [self.dataDAY objectAtIndex:indexPath.row];
        
        RFControlVC *rfControlVC = [[RFControlVC alloc] init];
        rfControlVC.nameStr = model.rfDataName;
        rfControlVC.iconStr = model.rfDataLogo;
        rfControlVC.RFMacStrArr = self.RFMacStrArr;
        rfControlVC.macStr = model.rfDataMac;
        rfControlVC.model = model;
        [self.navigationController pushViewController:rfControlVC animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - EditableTableViewDelegate
// 拖动 排序
- (void)editableTableController:(EditableTableController *)controller movedCellWithInitialIndexPath:(NSIndexPath *)initialIndexPath fromAboveIndexPath:(NSIndexPath *)fromIndexPath toAboveIndexPath:(NSIndexPath *)toIndexPath
{
    [self.RFTableView moveRowAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
    
    RFDataModel *model = [self.dataDAY objectAtIndex:toIndexPath.row];
    
    [self.dataDAY removeObjectAtIndex:toIndexPath.row];
    
    if (fromIndexPath.row == [self.dataDAY count])
    {
        [self.dataDAY addObject:model];
    }
    else
    {
        [self.dataDAY insertObject:model atIndex:fromIndexPath.row];
    }
    // 重置所有数据库中 device数据的orderNumber
    for (int i = 0; i < self.dataDAY.count; i++) {
        RFDataModel *rfDevice = [self.dataDAY objectAtIndex:i];
        if (rfDevice == nil) {
            return;
        }
        
        rfDevice.orderNumber = 1 + i;
        [RFDataBase updateFromDataBase:rfDevice];
        [self editRFDeviceSendToServer:rfDevice WithNewImageName:rfDevice.rfDataLogo];
        
    }
    
    self.dataDAY = [RFDataBase ascWithRFTableINorderNumber];
    [self.RFTableView reloadData];
}

#pragma mark-图片去色
//图片去色
- (UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

#pragma mark - 编辑RF设备信息
- (void)editRFDeviceSendToServer:(RFDataModel *)devices_ WithNewImageName:(NSString *)imageName
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:[devices_.rfDataMac uppercaseStringWithLocale:[NSLocale currentLocale]]   forKey:@"macAddress"];
    [dict setValue:devices_.address forKey:@"addressCode"];
    [dict setValue:devices_.typeRF  forKey:@"type"];
    [dict setValue:devices_.rfDataName forKey:@"deviceName"];
    [dict setValue:devices_.rfDataLogo forKey:@"imageName"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)devices_.orderNumber] forKey:@"orderNumber"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    [dict setValue:[temp objectAtIndex:0] forKey:@"lastOperation"];
    
    [HTTPService POSTHttpToServerWith:EditRFURL WithParameters:dict   success:^(NSDictionary *dic) {
        
        NSLog(@"dicfssr=====%@",dic);
        //        [[Util getUtitObject] HUDHide];
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"成功");
            
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
        
        
    } error:^(NSError *error) {
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:NSLocalizedString(@"Link Timeout", nil)];
        
    }];
}

#pragma mark-长按手势移动
- (void)showDeleteView:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        backNumber = 2;
        self.hide = 2;
        self.isClicked = NO;
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"return_normal.png"] forState:UIControlStateNormal];
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"return_normal_click.png"] forState:UIControlStateHighlighted];
        self.rightBut.hidden = YES;
        [self.editableTableController setEnabled:YES];
        [self.RFTableView setHeaderHidden:YES];
        [self.RFTableView reloadData];
    }
}

#pragma mark - deleteSelectedCell & deleteRFDeviceToServerWith
- (void)deleteSelectedCell:(UITapGestureRecognizer *)tap
{
    RFDataModel *model = [self.dataDAY objectAtIndex:[tap.tag intValue] - 10000];
    // 删除服务器数据
    [self deleteRFDeviceToServerWith:model];
    // 删除本地图片
    [Util deleteCancleImageFileWithPath:model.rfDataLogo];
    // 删除数据库信息
    [RFDataBase deleteDataFromDataBase:model];
    
    [self.dataDAY removeObjectAtIndex:[tap.tag intValue] - 10000];
    
    // 2.更新UITableView UI界面
    if (self.dataDAY.count == 0) {
        backNumber = 1;
        self.hide = 1;
        self.isClicked = YES;
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_normal.png"] forState:UIControlStateNormal];
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_click.png"] forState:UIControlStateHighlighted];
        self.rightBut.hidden = NO;
        [self.RFTableView setHeaderHidden:NO];
        [self.editableTableController setEnabled:NO];
    }
    [self.RFTableView reloadData];
}

- (void)deleteRFDeviceToServerWith:(RFDataModel *)model
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [Util getPassWordWithmd5:[defaults objectForKey:KEY_PASSWORD]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:AccessKey forKey:@"accessKey"];
    [dict setValue:[defaults objectForKey:KEY_USERMODEL] forKey:@"username"];
    [dict setValue:tempString forKey:@"password"];
    [dict setValue:model.rfDataMac forKey:@"macAddress"];
    [dict setValue:model.address forKey:@"addressCode"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    [dict setValue:[temp objectAtIndex:0] forKey:@"lastOperation"];
    [HTTPService POSTHttpToServerWith:DeleteRFURL WithParameters:dict   success:^(NSDictionary *dic) {
        
        NSString * success = [dic objectForKey:@"success"];
        
        if ([success boolValue] == true) {
            NSLog(@"成功");
            
        }
        if ([success boolValue] == false) {
            
//            [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[dic objectForKey:@"msg"]];
            
        }
        
        
    } error:^(NSError *error) {
        //        [[Util getUtitObject] HUDHide];
        
//        [Util showAlertWithTitle:NSLocalizedString(@"Tips", nil) msg:[NSString stringWithFormat:@"%@",error]];
        
    }];
}


#pragma mark - navBtn method
- (void)leftButtonMethod:(UIButton *)but
{
    if (backNumber == 1) {
        RootViewController *root = [Util getAppDelegate].rootVC;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(OhBuyMoveMethod:)]) {
            
            if (root.curView.frame.origin.x == 0) {
                
                [self.delegate OhBuyMoveMethod:OhBuyRightMove];
            } else {
                
                [self.delegate OhBuyMoveMethod:OhBuyResetMove];
            }
        }
    } else if (backNumber == 2) {
        
        backNumber = 1;
        self.hide = 1;
        self.isClicked = YES;
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_normal.png"] forState:UIControlStateNormal];
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"list_menu_click.png"] forState:UIControlStateHighlighted];
        self.rightBut.hidden = NO;
        [self.RFTableView setHeaderHidden:NO];
        [self.editableTableController setEnabled:NO];
        [self.RFTableView reloadData];
    }
}

- (void)reloadButtonMethod:(UIButton *)sender
{
    [Util getAppDelegate].rootVC.pan.enabled = NO;
    AddNewRFDeviceVC *addRFVC = [[AddNewRFDeviceVC alloc] init];
    addRFVC.RFMacStrArr = self.RFMacStrArr;
    addRFVC.fmdbRFTableArray = self.dataDAY;
    addRFVC.typeNumber = 2;
    [self.navigationController pushViewController:addRFVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import "ResponseAnalysis.h"
#import "Gogle.h"

@implementation ResponseAnalysis

+ (NSDictionary *)analysisResponse:(NSData *)response
{
    
    NSLog(@"response===%@",response);
    
    //    self -> hertString= @"sd";
    if (!response)
    {
        return nil;
    }
    UInt8 protocolNo = [self protocolNoFromResponse:response];
    
    NSLog(@"=== %hhu", protocolNo);
    
    if (protocolNo == 0x81)
    {
        return [self workingServerInfo:response];
    }
    if (protocolNo == 0x0A)
    {
        return [self getAbsenceDeviceInfo:response];
    }
    if (protocolNo == 0x0B) {
        return [self getDeviceWattInfo:response];
    }
    if (protocolNo == 0x82)
    {
        return [self keyInfo:response];
    }
    if (protocolNo == 0x85)
    {
        return [self connectionInfo:response];
    }
    if (protocolNo == 0x61)
    {
        return [self heartBeatInfo:response];
    }
    if (protocolNo == 0x83 || protocolNo == 0x84 || protocolNo == 0x63 || protocolNo == 0x65 || protocolNo == 0x22 || protocolNo == 0x24)
    {
        
        return [self resultInfo:response];
    }
    if (protocolNo == 0x86)
    {
        return [self newVersionInfo:response];
    }
    if (protocolNo == 0x62)
    {
        return [self deviceInfo:response];
    }
    if (protocolNo == 0x64)
    {
        return [self addAccountInfo:response];
    }
    if (protocolNo == 0x42)
    {
        
        NSLog(@"42=%@",response);
        //        return [self discoveryInfo:response];
    }
    if (protocolNo == 0x01)
    {
        NSLog(@"=ghg=");
        
        return [self setGPIOInfo:response];
    }
    if (protocolNo == 0x03) {
        return [self timerInfo:response];
    }
    if (protocolNo == 0x04) {
        return  [self alarmClockInfo:response];
        
    }
    if (protocolNo == 0x06) {
        return [self getGPIOStatesInfo:response];
    }
    else if (protocolNo == 0x02)
    {
        return [self queryGPIOInfo:response];
    }
    if (protocolNo == 0x12)
    {
        return [self ClockInfo:response];
    }
    if (protocolNo == 0x0F)
    {
        return [self alarmClockInfo_RF:response];
    }

    return nil;
}

+ (NSDictionary *)analysisLocalServer:(NSData *)response
{
    NSLog(@"response===%@",response);

    //    self -> hertString= @"sd";
    if (!response)
    {
        return nil;
    }
    UInt8 protocolNo = [self protocolNoFromResponse:response];

    if (protocolNo == 0x81)
    {
        return [self workingServerInfo:response];
    }
    if (protocolNo == 0x0A)
    {
        return [self getAbsenceDeviceInfo:response];
    }
    if (protocolNo == 0x0B) {
        return [self getDeviceWattInfo:response];
    }
    if (protocolNo == 0x82)
    {
        return [self keyInfo:response];
    }
    if (protocolNo == 0x85)
    {
        return [self connectionInfo:response];
    }
    if (protocolNo == 0x61)
    {
        return [self heartBeatInfoLocal:response];
    }
    if (protocolNo == 0x83 || protocolNo == 0x84 || protocolNo == 0x63 || protocolNo == 0x65 || protocolNo == 0x22 || protocolNo == 0x24)
    {
        
        return [self resultInfo:response];
    }
    if (protocolNo == 0x86)
    {
        return [self newVersionInfo:response];
    }
    if (protocolNo == 0x62)
    {
        return [self deviceInfo:response];
    }
    if (protocolNo == 0x64)
    {
        return [self addAccountInfo:response];
    }
    if (protocolNo == 0x42)
    {
        
        NSLog(@"42=%@",response);
        //        return [self discoveryInfo:response];
    }
    if (protocolNo == 0x01)
    {
        
        
        NSLog(@"=ghg=");
        
        return [self setGPIOInfo:response];
    }
    if (protocolNo == 0x03) {
        return [self timerInfo:response];
        
    }
    if (protocolNo == 0x04) {
        return  [self alarmClockInfo:response];
        
    }
    if (protocolNo == 0x06) {
        return [self getGPIOStatesInfo:response];
    }
    else if (protocolNo == 0x02)
    {
        return [self queryGPIOInfo:response];
    }
    if (protocolNo == 0x12)
    {
        return [self ClockInfo:response];
    }
    if (protocolNo == 0x0F)
    {
        return [self alarmClockInfo_RF:response];
    }

    return nil;
    
}

#pragma mark - 0x0D
+ (NSDictionary *)getRFResult:(NSData *)response
{
    NSLog(@"===response == %@", response);
    
    return nil;
}

#pragma mark-0x0A
//查询防盗信息的返回
+ (NSDictionary *)getAbsenceDeviceInfo:(NSData *)response
{
    NSLog(@"=== %@",response);
    
    if (response.length < 26) {
        return nil;
    }
    
    NSData *data = [response subdataWithRange:NSMakeRange(17, 10)];
    
    NSData *dataflag = [response subdataWithRange:NSMakeRange(17, 1)];
    
    UInt8 flag = ((UInt8*)[dataflag bytes])[0];
    NSData *data0 = [data subdataWithRange:NSMakeRange(1, 4)];
    NSData *data1 = [data subdataWithRange:NSMakeRange(5, 4)];
    NSLog(@"==zq == %@ %@ %hhu %@ %@",data,dataflag,flag,data0,data1);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Absence" object:@{@"from":data0,@"to": data1,@"flag":[NSString stringWithFormat:@"%d",flag]}];
    
    
    //    [[NSUserDefaults standardUserDefaults] setObject:@{@"from":data0,@"to": data1,@"flag":[NSString stringWithFormat:@"%d",flag]} forKey:OPERAbsence_INFO];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    return @{@"from":data0,@"to": data1,@"flag":[NSString stringWithFormat:@"%d",flag]};
    
}

#pragma mark-0x0B 查询实时电量
+ (NSDictionary *)getDeviceWattInfo:(NSData *)response
{
    NSData *vData = [response subdataWithRange:NSMakeRange(17, 2)];
    NSData *iData = [response subdataWithRange:NSMakeRange(19, 2)];
    NSData *pData = [response subdataWithRange:NSMakeRange(21, 4)];
        
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    [temparray addObject:@{@"voltage":vData, @"elcCurrent": iData, @"power":pData}];
    
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:WATT_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    return @{@"voltage":vData,@"elcCurrent": iData,@"power":pData};
    
}

#pragma mark-0x06
//设备的GPIO事件返回方法
+ (NSDictionary *)getGPIOStatesInfo:(NSData *)response
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPER_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
    NSData *data = [response subdataWithRange:NSMakeRange(17, 4)];
    
    UInt8 on_off = ((UInt8 *)[data bytes])[2];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [temparray addObject:@{@"switch": [NSString stringWithFormat:@"%d",on_off],@"mac":mac}];
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPER_CLOSE_INFO];    
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeState" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSwitchState" object:nil];
    return @{@"switch": [NSString stringWithFormat:@"%d",on_off],@"mac":mac};
}

#pragma mark-0x04
+ (NSDictionary *)alarmClockInfo:(NSData *)response
{
    NSData *data0 = [response subdataWithRange:NSMakeRange(18, response.length-18)];
    
    UInt8 *bytes = (UInt8 *)[response bytes];
    
    UInt8 Locktype = bytes[1];
    
    NSData *macData = [response subdataWithRange:NSMakeRange(2, 6)];
    Device *devic = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[Crypt hexEncode:macData]];
    
    if (Locktype == 66 || Locktype == 2) {
        devic.LockType = @"open";
    }
    else if (Locktype == 70 || Locktype == 6) {
        devic.LockType = @"close";
    }
    
    [[DeviceManagerInstance getlocalDeviceDictary] setObject:devic forKey:[Crypt hexEncode:macData]];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    [temparray removeAllObjects];
    for (int i = 0; i < data0.length/8; i ++) {
        NSData *data =  [data0 subdataWithRange:NSMakeRange(i*8, 8)];
        
        UInt8 indx = ((UInt8*)[data bytes])[0];
        UInt8 flag = ((UInt8*)[data bytes])[1];
        UInt8 hour = ((UInt8*)[data bytes])[2];
        UInt8 min = ((UInt8*)[data bytes])[3];
        UInt8 on_Off = ((UInt8*)[data bytes])[6];
        
        [temparray addObject:@{@"indx": [NSString stringWithFormat:@"%d",indx],@"flag": [NSString stringWithFormat:@"%d",flag] ,@"hour": [NSString stringWithFormat:@"%d",hour],@"min": [NSString stringWithFormat:@"%d",min] ,@"switch": [NSString stringWithFormat:@"%d",on_Off]}];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GetTimer" object:temparray];
        
    }
    
    return nil;
}

#pragma mark-0x0F
+ (NSDictionary *)alarmClockInfo_RF:(NSData *)response
{
    // <0102accf 23379350 16000032 cafd6631 0ffd7a01 00060aa6 fd7a0100 000828>
    
    NSData *data0 = [response subdataWithRange:NSMakeRange(19, response.length - 19)];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    [temparray removeAllObjects];
    for (int i = 0; i < data0.length / 12; i ++) {
        NSData *data =  [data0 subdataWithRange:NSMakeRange(i * 12, 12)];
        
        UInt8 indx = ((UInt8*)[data bytes])[0];
        UInt8 flag = ((UInt8*)[data bytes])[1];
        UInt8 hour = ((UInt8*)[data bytes])[2];
        UInt8 min = ((UInt8*)[data bytes])[3];
        UInt8 on_Off = ((UInt8*)[data bytes])[7];
        
        [temparray addObject:@{@"indx": [NSString stringWithFormat:@"%d",indx],@"flag": [NSString stringWithFormat:@"%d",flag] ,@"hour": [NSString stringWithFormat:@"%d",hour],@"min": [NSString stringWithFormat:@"%d",min] ,@"switch": [NSString stringWithFormat:@"%d",on_Off]}];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GetRFTimer" object:temparray];
    }
    
    return nil;
}

#pragma mark-
#pragma mark-0x81
+ (NSDictionary *)workingServerInfo:(NSData *)response
{
    NSMutableString * host = [[NSMutableString alloc] init];
    for (int i = 17; i < 21; i++)
    {
        UInt8 no = ((UInt8 *)response.bytes)[i];
        [host appendFormat:@"%d.",no];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[host substringToIndex:host.length - 1] forKey:BroHost];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UInt16 port = [Util uint16FromNetData:[response subdataWithRange:NSMakeRange(21, 2)]];
    return @{@"host": [host substringToIndex:host.length - 1],
             @"port": [NSString stringWithFormat:@"%d",port]};
}

+ (NSDictionary *)keyInfo:(NSData *)response
{
    UInt8 keyLen = ((UInt8 *)[response bytes])[17];
    NSData * key = [response subdataWithRange:NSMakeRange(18, keyLen)];
    
    [Util getAppDelegate].connected = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:SERVER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TCPlian" object:@{@"keyLen": [NSString stringWithFormat:@"%d",keyLen],@"key": key }];
    return @{@"keyLen": [NSString stringWithFormat:@"%d",keyLen],
             @"key": key};
}


#pragma mark-0x01
+ (NSDictionary *)timerInfo:(NSData *)response
{
    UInt8 keyLen = ((UInt8 *)[response bytes])[17];
    NSData * key = [response subdataWithRange:NSMakeRange(18, 1)];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"keyLen": [NSString stringWithFormat:@"%d",keyLen],@"key": key} forKey:OPERATION_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"=== %@ ==%hhu", key, keyLen);
    
    return @{@"keyLen": [NSString stringWithFormat:@"%d",keyLen],
             @"key": key};
}

+ (NSDictionary *)heartBeatInfoLocal:(NSData *)response
{
    if (response.length < 18) {
        return nil;
    }
    UInt16 interval = [Util uint16FromNetData:[response subdataWithRange:NSMakeRange(17, 2)]];
    
    NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[Crypt hexEncode:mac]];
    if (device == nil || [[Crypt hexEncode:mac] isEqualToString:@"FFFFFFFFFFFF"]) {
        return nil;
    }

    device.heartBeatNumber = 0;
    [[DeviceManagerInstance getlocalDeviceDictary] setObject:device forKey:[Crypt hexEncode:mac]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"local_interval" object:@{@"interval": [NSString stringWithFormat:@"%d",interval],@"mac_l":mac}];
    
    return @{@"interval": [NSString stringWithFormat:@"%d",interval],@"mac_l":mac};
    
}


+ (NSDictionary *)heartBeatInfo:(NSData *)response
{
    
    UInt16 interval = [Util uint16FromNetData:[response subdataWithRange:NSMakeRange(17, 2)]];
    
    NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"_interval" object:@{@"interval": [NSString stringWithFormat:@"%d",interval]}];
    
    return @{@"interval": [NSString stringWithFormat:@"%d",interval],@"mac":mac};
}

//static int iC = 0;
#pragma mark-84-83-24-65
+ (NSDictionary *)resultInfo:(NSData *)response
{
    UInt8 result = ((UInt8 *)[response bytes])[17];
    
    NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
    UInt8 number = ((UInt8 *)response.bytes)[16];
    
    if (number == 0x84) {
        NSLog(@"== %@ ==", response);
        
        NSMutableArray *temp;
        if (temp == nil) {
            temp= [[NSMutableArray alloc] initWithCapacity:2];
            
            NSString *string =  [Crypt hexEncode:mac];
            
            Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[string uppercaseStringWithLocale:[NSLocale currentLocale]]];
            if (device == nil) {
                return nil;
            }
            UInt8 status = ((UInt8 *)response.bytes)[17];
            
            device.remoteContent = [NSString stringWithFormat:@"%d",status];

            if (device != nil) {
                [[DeviceManagerInstance getlocalDeviceDictary] setObject:device forKey:string];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"OPERATION_INFO" object:@{@"result": [NSString stringWithFormat:@"%d",status],@"mac":mac}];
            
        }
        
    } else if (number == 0x65) {
        
        NSString *sver = [[NSUserDefaults standardUserDefaults] objectForKey:@"SVER"];
        
        NSString *string =  [Crypt hexEncode:mac];
        Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[string uppercaseStringWithLocale:[NSLocale currentLocale]]];
        if ([device.sver floatValue] < [sver floatValue]) {
            
            device.sver = sver;
            [[DeviceManagerInstance getlocalDeviceDictary] setObject:device forKey:string];
        }

    }
    
    return @{@"result": [NSString stringWithFormat:@"%d",result],@"mac":mac};
}


+ (NSDictionary *)newVersionInfo:(NSData *)response
{
    UInt8 * bytes = (UInt8 *)[response bytes];
    UInt8 slen = bytes[17];
    NSData * sver = [response subdataWithRange:NSMakeRange(18, slen)];
    UInt8 urlLen = bytes[18 + slen];
    NSData * url = [response subdataWithRange:NSMakeRange(19 + slen, urlLen)];
    
    NSString *urlStr = [self stringFromHexString:[Crypt hexEncode:url]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"getnewsver" object: @{@"slen":[NSString stringWithFormat:@"%d",slen],
                                                                                      @"sver":[[NSString alloc] initWithData:sver encoding:NSUTF8StringEncoding],
                                                                                      @"urlLen":[NSString stringWithFormat:@"%d",urlLen],
                                                                                      @"url":urlStr,
                                                                                      @"urlData":url}];
    
    return @{@"slen":[NSString stringWithFormat:@"%d",slen],
             @"sver":[[NSString alloc] initWithData:sver encoding:NSUTF8StringEncoding],
             @"urlLen":[NSString stringWithFormat:@"%d",urlLen],
             @"url":urlStr};
}

+ (NSString *)stringFromHexString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}


#pragma mark-0x62
+ (NSDictionary *)deviceInfo:(NSData *)response
{
    NSLog(@"response == %@",response);
    if (response.length < 25) {
        return  nil;
    }
    NSData * tempMac = [response subdataWithRange:NSMakeRange(2, 6)];
    
    UInt8 * bytes = (UInt8 *)[response bytes];
    
    UInt8 Locktype = bytes[1];
    NSLog(@"=== %hhu", Locktype);
    
    
    UInt8 hlen = bytes[17];
    NSData * hver = [response subdataWithRange:NSMakeRange(18, hlen)];
    UInt8 slen = bytes[18 + hlen];
    NSData * sver = [response subdataWithRange:NSMakeRange(19 + hlen, slen)];
    UInt8 nlen = bytes[19 + hlen + slen];
    NSData * name = [response subdataWithRange:NSMakeRange(20 + hlen + slen, nlen)];
    
    Device *devic = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[Crypt hexEncode:tempMac]];
    devic.sver = [NSString stringWithUTF8String:sver.bytes];
    
    if (Locktype == 66 || Locktype == 2) {
        devic.LockType = @"open";
    }
    else if (Locktype == 70 || Locktype == 6) {
        devic.LockType = @"close";
    }
    
    [[DeviceManagerInstance getlocalDeviceDictary] setObject:devic forKey:[Crypt hexEncode:tempMac]];
    
    return @{@"hlen":[NSString stringWithFormat:@"%d",hlen],
             @"hver":[[NSString alloc] initWithData:hver encoding:NSUTF8StringEncoding],
             @"slen":[NSString stringWithFormat:@"%d",slen],
             @"sver":[[NSString alloc] initWithData:sver encoding:NSUTF8StringEncoding],
             @"nlen":[NSString stringWithFormat:@"%d",nlen],
             @"name":[[NSString alloc] initWithData:name encoding:NSUTF8StringEncoding]};
}

+ (NSDictionary *)addAccountInfo:(NSData *)response
{
    NSData * check = [response subdataWithRange:NSMakeRange(17, 16)];
    return @{@"check":check};
}

#pragma mark-0x23
//static BOOL isYS = NO;



+ (NSDictionary *)setGPIOInfo:(NSData *)response
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPER_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
    NSData *data = [response subdataWithRange:NSMakeRange(17, 4)];
    
    UInt8 on_off = ((UInt8 *)[data bytes])[2];
    
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    NSMutableArray *deviceArr =[DataBase selectAllDataFromDataBase];
    //    for (int i = 0; i < [deviceArr count]; i ++)
    //    {
    [temparray addObject:@{@"switch": [NSString stringWithFormat:@"%d",on_off],@"mac":mac}];
    
    //    }
    
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPER_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSwitchState" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeState" object:nil];
    
    NSData * pin = [response subdataWithRange:NSMakeRange(17, 4)];
    
    
    return @{@"pin":pin};
}

//static UInt8 switchIndex = 0;

#pragma mark-0x02
+ (NSDictionary *)queryGPIOInfo:(NSData *)response
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPER_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSData *macData = [response subdataWithRange:NSMakeRange(2, 6)];
    
    NSData * pin = [response subdataWithRange:NSMakeRange(17, 4)];
    
    UInt8 on_off = ((UInt8 *)[pin bytes])[2];
    
    NSString *macKey = [Crypt hexEncode:macData];
    
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:macKey];
    if (device == nil) {
        return nil;
    }
    if (on_off == 255) {
        
        device.alarm = @"on";
    }else{
        device.alarm = @"off";
        
    }
    if (device != nil) {
        [[DeviceManagerInstance getlocalDeviceDictary] setObject:device forKey:macKey];
    }
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [temparray addObject:@{@"switch": [NSString stringWithFormat:@"%d",on_off],@"mac":macData}];
    
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPER_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] setObject:temparray forKey:OPEN_CLOSE_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeSwitchState" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeState" object:nil];
    
    return @{@"pin":pin,@"mac":macData};
}

#pragma mark-85
+ (NSDictionary *)connectionInfo:(NSData *)response
{
    
    NSData *mac = [response subdataWithRange:NSMakeRange(2,6)];
    
    NSString *strin =  [Crypt hexEncode:mac];
    
    UInt8 status = ((UInt8 *)response.bytes)[18];
    
    Device *device = [[DeviceManagerInstance getlocalDeviceDictary] objectForKey:[strin uppercaseStringWithLocale:[NSLocale currentLocale]]];
    if (device == nil) {
        return nil;
    }
    device.remoteContent = [NSString stringWithFormat:@"%d",status];
    if ([device.hver isEqualToString:@"0"]) {
        
        device.alarm = @"off";
        
    }
    
    if (device != nil) {
        [[DeviceManagerInstance getlocalDeviceDictary] setObject:device forKey:[strin uppercaseStringWithLocale:[NSLocale currentLocale]]];
    }
    
    
    for (int i = 0; i < 2; i++) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getState" object:[Crypt hexEncode:mac]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getOnlineOrOfflineInfo" object:[Crypt hexEncode:mac]];
    }
    
    return @{@"status":[NSString stringWithFormat:@"%d",status],@"mac":mac};
}

+ (NSData *)macFromResponse:(NSData *)response
{
    return [response subdataWithRange:NSMakeRange(2, 6)];
}

+ (BOOL)isResponseEncrypt:(NSData *)response
{
    UInt8 flag = ((UInt8 *)[response bytes])[1];
    return (flag & 0x40) == 0x40;
}

+ (UInt16)indexFromResponse:(NSData *)response
{
    if (response.length<12) {
        return 0;
    }
    //    NSLog(@"%0x===", [Util uint16FromNetData:[response subdataWithRange:NSMakeRange(10, 2)]]);
    return [Util uint16FromNetData:[response subdataWithRange:NSMakeRange(10, 2)]];
}

+ (UInt8)protocolNoFromResponse:(NSData *)response
{
    return ((UInt8 *)response.bytes)[16];
}

#pragma mark - 0x12
+ (NSDictionary *)ClockInfo:(NSData *)response
{
    // <0102accf 23379350 13000124 cafd6631 12000180 000001e3 000000ff>
    
    if (response.length != 28) {
        return nil;
    }
    
    // <0140accf 23285f50 20000031 d1f1df6d 09018000 01193f41 38304130 32303030 3142ffff>
    NSData *data =  [response subdataWithRange:NSMakeRange(17, response.length - 17)];
    NSLog(@"data===%@===", data);
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UInt8 indx = ((UInt8*)[data bytes])[1];
    UInt8 flag = ((UInt8*)[data bytes])[2];
    int seconds = ((UInt8*)[data bytes])[4] * 65536 + ((UInt8*)[data bytes])[5] * 256 + ((UInt8*)[data bytes])[6];
    UInt8 on_Off = ((UInt8*)[data bytes])[9];
    
    NSLog(@"countdown === %d %d ===", ((UInt8*)[data bytes])[4], ((UInt8*)[data bytes])[5]);
    
    [temparray addObject:@{@"indx": [NSString stringWithFormat:@"%d",indx],@"flag": [NSString stringWithFormat:@"%d",flag] ,@"seconds": [NSString stringWithFormat:@"%d",seconds],@"switch": [NSString stringWithFormat:@"%d",on_Off]}];
    
    for (int i = 0; i < 2; i++) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"countDown" object:temparray];
    }
    
    return @{@"indx": [NSString stringWithFormat:@"%d",indx],@"flag": [NSString stringWithFormat:@"%d",flag] ,@"seconds": [NSString stringWithFormat:@"%d",seconds],@"switch": [NSString stringWithFormat:@"%d",on_Off]};
}

+ (void)connectDevice:(Device *)device response:(NSData *)response
{
    //    UInt8 * bytes = (UInt8 *)response.bytes;
    //    device.mac = [self macFromResponse:response];
    //    device.accessCode = bytes[9];
    //    device.productor = bytes[12];
    //    device.type = bytes[13];
    //    device.authCode = [response subdataWithRange:NSMakeRange(14, 2)];
}

@end

/********* iosCordovaPushPlugin.m Cordova Plugin Implementation *******/
/*
 * 插件的使用步骤：
 * 1.将插件导入项目，然后在ios的AppDelegate.h声明一个字典属性
 *   例如：@property (nonatomic,strong)NSDictionary * launchOptionDic;
 *   然后在AppDelegate.m的didFinishLaunchingWithOptions方法内接收launchOptions字典
 *   在点击推送启动app时保存的推送消息。
 *   例如:
 if(launchOptions){
 self.launchOptionDic = launchOptions;
 }
 *
 * 2.在js文件实现下面方法
 *   - (void)initPushMethod:(CDVInvokedUrlCommand*)command;
 *   - (void)receiveMessage:(CDVInvokedUrlCommand*)command;
 *
 */
#import <Cordova/CDV.h>
#import "AppDelegate+Push.h"
#import "AppDelegate.h"
@interface iosCordovaPushPlugin : CDVPlugin {
  // Member variables go here.
}
@property (nonatomic,strong)CDVInvokedUrlCommand * myCommand;
@property (nonatomic,strong)CDVInvokedUrlCommand * deviceCommand;
@property (nonatomic,strong)CDVPluginResult * pluginResult;
    
//接收appdelegate类里面的launchOptions字典数据（为了接收到在app被干掉，点击推送拿到推送消息）
@property (nonatomic,strong)NSDictionary * dic;
- (void)initPushMethod:(CDVInvokedUrlCommand*)command;
- (void)receiveMessage:(CDVInvokedUrlCommand*)command;
    @end

@end

@implementation iosCordovaPushPlugin

- (void)initPushMethod:(CDVInvokedUrlCommand*)command
    {
        self.deviceCommand = command;
        
        // KVO 监听 是否接收到推送的deviceToken
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"deviceToken" options:NSKeyValueObservingOptionNew context:nil];
        
        // 注册推送
        UIApplication * app =[UIApplication sharedApplication];
        AppDelegate * appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appdelegate panPushLaunchOptions:nil application:app];
        self.dic =appdelegate.launchOptionDic;
        
    }
    
    
    
- (void)postDeviceToken{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        
        if (deviceToken) {
            self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceToken];
            //[pluginResult setKeepCallback:@(true)];
            
        } else {
            self.pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"isEmpty"];
        }
        [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.deviceCommand.callbackId];
        [[NSUserDefaults standardUserDefaults] setValue:@"pan" forKey:@"deviceToken"];
    });
}
    
- (void)receiveMessage:(CDVInvokedUrlCommand*)command{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:@"receiveUrlStr" object:nil];
    // 让command对象活下去，防止通知方法中self.myCommand为nil。
    self.myCommand = command;
    // 当点击推送消息启动app，拿到推送消息
    if(self.dic){
        // 解析从AppDelegate类中拿到的字典数据
        NSDictionary *dic1 = [self.dic objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //        NSString * receiveUrlStr =dic1[@"notifycontent"][@"url"];
        [[NSUserDefaults standardUserDefaults] setObject:dic1 forKey:@"pushUrl"];
        NSString * pushUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushUrl"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pushUrl"];
        dispatch_async(dispatch_get_main_queue(), ^{
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pushUrl];
            [pluginResult setKeepCallback:@(true)];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCommand.callbackId];
        });
    }
}
    
- (void)changeValue:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:noti.object];
        [pluginResult setKeepCallback:@(true)];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.myCommand.callbackId];
    });
}
    
# pragma KVO监听方法(监听推送传的url)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"deviceToken"]) {
        if (![change[@"new"] isEqualToString:@"pan"]) {
            //如果拿到deviceToken就执行下面的方法
            [self postDeviceToken];
        }
    }
}
    
    
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveUrlStr" object:nil];
    [self removeObserver:self forKeyPath:@"deviceToken"];
}


@end

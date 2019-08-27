//
//  AppDelegate+Push.h
//  PTS
//
//  Created by 潘远生 on 2018/6/25.
//  Copyright © 2018年 Wistron. All rights reserved.
//

#import "AppDelegate.h"
@class PushPlugin;
@interface AppDelegate (Push)

- (void)panPushLaunchOptions:(NSDictionary *)launchOptions application:(UIApplication *)applictaion;
@end

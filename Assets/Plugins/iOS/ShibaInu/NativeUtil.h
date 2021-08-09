//
// Unity 与 Native 通信相关工具类
// Created by LOLO on 2020/08/08.
//

#pragma once



#pragma mark -

// 传递 AppControllerProtocol 实体时，派发通知所使用的名称
extern NSString * const APP_CTR_PROT_NOTIF_NAME;
// 收到 Unity 发来的消息时，会用该名称在 NSNotificationCenter 派发通知
extern NSString * const UNITY_MSG_NOTIF_NAME;

// Unity 消息 action 字段使用的 key
extern NSString * const UNITY_MSG_KEY_ACT;
// Unity 消息 message 字段使用的 key
extern NSString * const UNITY_MSG_KEY_MSG;


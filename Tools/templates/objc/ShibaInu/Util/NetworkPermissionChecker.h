//
//  NetworkPermissionChecker.h
//  用于网络权限检查，在网络权限未授予时，弹窗引导用户去设置。
//  依赖 Network.framework
//  Created by LOLO on 2025/07/25.
//

//#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NetworkPermissionChecker : NSObject

/**
 * 检查网络权限，如果网络不通，则弹出默认的英文提示框。
 * @param completionBlock 网络权限确认通畅后执行的回调。
 */
+ (void)checkWithCompletion:(void (^)(void))completionBlock;


/**
 * 检查网络权限，如果网络不通，则弹出可完全自定义内容的提示框。
 * @param title 弹窗标题。
 * @param message 弹窗内容。
 * @param settingsButton “设置”按钮的文字。
 * @param retryButton “重试”按钮的文字。
 * @param completionBlock 网络权限确认通畅后执行的回调。
 */
+ (void)checkWithTitle:(NSString *)title
               message:(NSString *)message
        settingsButton:(NSString *)settingsButton
           retryButton:(NSString *)retryButton
            completion:(void (^)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END


#import <Foundation/Foundation.h>

/**  回调结果状态 */
typedef NS_ENUM(NSUInteger, BTORespResult) {
    BTORespResultCanceled = 0,       // 取消
    BTORespResultSuccess,            // 成功
    BTORespResultFailure,            // 失败
};


/*!
 * @brief 跳转回调
 */
@interface BTORespObj : NSObject

@property (nonatomic, assign) BTORespResult result; // 处理结果
@property (nonatomic, copy) NSString *message;     // 消息
@property (nonatomic, weak) id data;  // 携带数据

@end

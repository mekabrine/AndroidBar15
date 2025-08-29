#import <UIKit/UIKit.h>
@interface NavBarView : UIView
@property (nonatomic, copy) void (^onHome)(void);
@property (nonatomic, copy) void (^onBack)(void);
@property (nonatomic, copy) void (^onRecents)(void);
@end

#import "NavBarView.h"
@implementation NavBarView {
    UIVisualEffectView *_blur;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
        _blur = [[UIVisualEffectView alloc] initWithEffect:effect];
        _blur.frame = self.bounds;
        _blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blur.layer.cornerRadius = 16.0;
        _blur.layer.masksToBounds = YES;
        [self addSubview:_blur];
    }
    return self;
}
@end

#import "NavBarView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NavBarView {
    UIVisualEffectView *_blur;
    UIButton *_back, *_home, *_recents;
    UIImpactFeedbackGenerator *_haptics;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
        _blur = [[UIVisualEffectView alloc] initWithEffect:effect];
        _blur.frame = self.bounds;
        _blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blur.layer.cornerRadius = 16.0;
        _blur.layer.masksToBounds = YES;
        _blur.alpha = 0.90;
        [self addSubview:_blur];

        _back    = [self pill:@"\u25C1"]; // ◁
        _home    = [self pill:@"\u25CF"]; // ●
        _recents = [self pill:@"\u25A1"]; // □

        // Haptics on tap for all three
        [_back addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [_home addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [_recents addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_back];
        [self addSubview:_home];
        [self addSubview:_recents];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        if ([UIImpactFeedbackGenerator class]) {
            _haptics = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [_haptics prepare];
        }
    }
    return self;
}

- (UIButton *)pill:(NSString *)title {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.backgroundColor = [[UIColor labelColor] colorWithAlphaComponent:0.18];
    b.layer.cornerRadius = 18.0;
    b.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
    b.tintColor = UIColor.labelColor;
    return b;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _blur.frame = self.bounds;
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds);
    CGFloat btnW = 56.0, btnH = MIN(36.0, h - 8.0);
    CGFloat spacing = (w - (btnW * 3)) / 4.0;
    CGFloat y = (h - btnH) / 2.0;

    _back.frame    = CGRectMake(spacing, y, btnW, btnH);
    _home.frame    = CGRectMake(spacing*2 + btnW, y, btnW, btnH);
    _recents.frame = CGRectMake(spacing*3 + btnW*2, y, btnW, btnH);
}

- (void)tap:(UIButton *)sender {
    if (_haptics) {
        [_haptics impactOccurred];
        [_haptics prepare];
    }
}

@end

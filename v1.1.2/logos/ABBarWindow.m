#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <notify.h>

static CGFloat ABBarHeight(void) {
    CGFloat inset = 34.0; // sensible default (iPhone X family)
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            for (UIWindow *w in ws.windows) {
                if (!w.isHidden) { inset = w.safeAreaInsets.bottom; break; }
            }
        }
    } else {
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        inset = w ? w.safeAreaInsets.bottom : inset;
    }
    return 48.0 + inset;
}

@interface ABButton : UIControl
@property(nonatomic, strong) UIImageView *iv;
@end
@implementation ABButton
- (instancetype)initWithImage:(UIImage *)img {
    if ((self = [super initWithFrame:CGRectZero])) {
        self.iv = [[UIImageView alloc] initWithImage:img];
        self.iv.contentMode = UIViewContentModeScaleAspectFit;
        self.iv.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.iv];
        [NSLayoutConstraint activateConstraints:@[
            [self.iv.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.iv.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [self.iv.heightAnchor constraintEqualToConstant:22],
            [self.iv.widthAnchor constraintEqualToConstant:22],
        ]];
        self.backgroundColor = UIColor.clearColor;
        self.accessibilityTraits = UIAccessibilityTraitButton;
    }
    return self;
}
@end

@interface ABBarWindow : UIWindow
@property(nonatomic, strong) UIVisualEffectView *blur;
@property(nonatomic, strong) UIStackView *stack;
@property(nonatomic, strong) ABButton *backBtn;
@property(nonatomic, strong) ABButton *homeBtn;
@property(nonatomic, strong) ABButton *switchBtn;
@end

@implementation ABBarWindow

- (instancetype)initOverlay {
    UIScreen *main = UIScreen.mainScreen;
    if ((self = [super initWithFrame:main.bounds])) {
        self.windowLevel = UIWindowLevelStatusBar + 1000; // above everything
        self.hidden = NO;
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = YES;

        self.blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark]];
        self.blur.translatesAutoresizingMaskIntoConstraints = NO;
        self.blur.clipsToBounds = YES;
        self.blur.layer.cornerRadius = 16;
        [self addSubview:self.blur];

        self.stack = [[UIStackView alloc] initWithFrame:CGRectZero];
        self.stack.axis = UILayoutConstraintAxisHorizontal;
        self.stack.spacing = 32;
        self.stack.distribution = UIStackViewDistributionFillEqually;
        self.stack.alignment = UIStackViewAlignmentCenter;
        self.stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.blur.contentView addSubview:self.stack];

        UIImage *backImg = [self _symbol:@"chevron.left"];
        UIImage *homeImg = [self _symbol:@"circle.fill"];
        UIImage *switchImg = [self _symbol:@"square.on.square"];
        self.backBtn = [[ABButton alloc] initWithImage:backImg];
        self.homeBtn = [[ABButton alloc] initWithImage:homeImg];
        self.switchBtn = [[ABButton alloc] initWithImage:switchImg];

        [self.stack addArrangedSubview:self.backBtn];
        [self.stack addArrangedSubview:self.homeBtn];
        [self.stack addArrangedSubview:self.switchBtn];

        [self _wireActions];

        CGFloat h = ABBarHeight();
        UILayoutGuide *guide = self.safeAreaLayoutGuide;
        [NSLayoutConstraint activateConstraints:@[
            [self.blur.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
            [self.blur.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
            [self.blur.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:-8],
            [self.blur.heightAnchor constraintEqualToConstant:h - guide.layoutFrame.origin.y],

            [self.stack.leadingAnchor constraintEqualToAnchor:self.blur.contentView.leadingAnchor constant:24],
            [self.stack.trailingAnchor constraintEqualToAnchor:self.blur.contentView.trailingAnchor constant:-24],
            [self.stack.topAnchor constraintEqualToAnchor:self.blur.contentView.topAnchor constant:8],
            [self.stack.bottomAnchor constraintEqualToAnchor:self.blur.contentView.bottomAnchor constant:-8],
        ]];

        // protect touches from going to underlying app
        self.rootViewController = [UIViewController new];
        self.rootViewController.view.backgroundColor = UIColor.clearColor;
        self.accessibilityViewIsModal = NO;
    }
    return self;
}

- (UIImage *)_symbol:(NSString *)name {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightRegular];
        return [UIImage systemImageNamed:name withConfiguration:cfg] ?: [UIImage new];
    }
    return [UIImage new];
}

- (void)_wireActions {
    [self.backBtn addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
    [self.homeBtn addTarget:self action:@selector(didTapHome) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn addTarget:self action:@selector(didTapSwitch) forControlEvents:UIControlEventTouchUpInside];
}

static void ABPostDarwin(const char *name) {
    notify_post(name);
}

- (void)didTapBack {
    // Notify app processes to perform accessibility back
    ABPostDarwin("com.space.mekabrine.androidbar.back");
    // Haptic feedback (if available)
    if (@available(iOS 13.0, *)) {
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen impactOccurred];
    }
}

extern void SBSimulateHomeButtonPress();
- (void)didTapHome {
    // Simulate single home press via SpringBoard private method
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:NSSelectorFromString(@"_simulateHomeButtonPress")]) {
        ((void(*)(id, SEL))objc_msgSend)(app, NSSelectorFromString(@"_simulateHomeButtonPress"));
    } else {
        // fallback double-press then switcher dismiss -> to go Home
        if ([app respondsToSelector:NSSelectorFromString(@"_simulateHomeButtonDoublePress")]) {
            ((void(*)(id, SEL))objc_msgSend)(app, NSSelectorFromString(@"_simulateHomeButtonDoublePress"));
        }
    }
}

- (void)didTapSwitch {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:NSSelectorFromString(@"_simulateHomeButtonDoublePress")]) {
        ((void(*)(id, SEL))objc_msgSend)(app, NSSelectorFromString(@"_simulateHomeButtonDoublePress"));
    }
}

@end
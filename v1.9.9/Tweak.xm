\
#import <UIKit/UIKit.h>
#import <rootless.h> // Theos rootless helper

%hook SBIconController // Example hook; replace with your actual targets

- (void)viewDidLoad {
    %orig;

    // Example reading a resource from the old /Library path in a rootless-safe way
    NSString *themesDir = ROOT_PATH_NS(@"/Library/Application Support/AndroBar/Themes");
    // Do something with themesDir, e.g., load config/images

    // Example simple toast to prove the tweak loaded
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, win.bounds.size.width-20, 28)];
    label.text = @"AndroBar (rootless) loaded";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    label.textColor = [UIColor whiteColor];
    label.layer.cornerRadius = 8.0;
    label.clipsToBounds = YES;
    [win addSubview:label];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}

%end

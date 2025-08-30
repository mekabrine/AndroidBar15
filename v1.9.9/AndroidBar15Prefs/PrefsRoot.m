#import <Preferences/PSListController.h>

@interface AndroidBar15RootListController : PSListController
@end

@implementation AndroidBar15RootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
@end

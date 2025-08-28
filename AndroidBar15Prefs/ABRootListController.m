#import "ABRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <notify.h>
#include <spawn.h>

static NSString * const kDomain = @"space.mekabrine.androidbar15";
static const char *kReloadNote = "space.mekabrine.androidbar15/ReloadPrefs";

@implementation ABRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *prefs = [([NSDictionary dictionaryWithContentsOfFile:[self prefsPath]] ?: @{}) mutableCopy];
    if (!prefs) prefs = [NSMutableDictionary new];
    prefs[specifier.properties[@"key"]] = value;
    [prefs writeToFile:[self prefsPath] atomically:YES];
    notify_post(kReloadNote);
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[self prefsPath]] ?: @{};
    id v = prefs[specifier.properties[@"key"]];
    if (!v) v = specifier.properties[@"default"];
    return v;
}

- (NSString *)prefsPath {
    return [@"/var/mobile/Library/Preferences" stringByAppendingPathComponent:[kDomain stringByAppendingString:@".plist"]];
}

- (void)respring:(id)sender {
    pid_t pid;
    const char* args[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

@end

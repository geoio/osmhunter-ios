//
//  SettingsManager.m
//  osm_hunter
//
//  Created by Andrew Tarasenko on 6/19/13.
//  Copyright (c) 2013 happy bits. All rights reserved.
//

#import "SettingsManager.h"
#import "SSKeychain.h"

@implementation SettingsManager

+ (id)sharedInstance {
    static SettingsManager *__instance;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        __instance = [[SettingsManager alloc] init];
    });
    
    return __instance;
}

- (NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kSettingsSessionId];
}

- (void)setSessionId:(NSString *)sessionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:sessionId forKey:kSettingsSessionId];
    [defaults synchronize];
}

- (NSString *)apiKey {
    if (self.sessionId) {
        return [SSKeychain passwordForService:kKeychainServiceName account:self.sessionId];
    } else {
        return nil;
    }
}

- (void)setApiKey:(NSString *)apiKey {
    if (self.sessionId) {
        [SSKeychain setPassword:apiKey forService:kKeychainServiceName account:self.sessionId];
    }
}

@end

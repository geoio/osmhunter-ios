//
//  SettingsManager.m
//  osm_hunter
//
//  Created by Andrew Tarasenko on 6/19/13.
//  Copyright (c) 2013 happy bits. All rights reserved.
//

#import "SettingsManager.h"
#import "SSKeychain.h"
#import "APIClient.h"
#import "UIImage+Resize.h"

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

- (NSString *)userName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kSettingsUserName];
}

- (void)setUserName:(NSString *)userName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:kSettingsUserName];
    [defaults synchronize];
}

- (NSString *)userPoints {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kSettingsUserPoints];
}

- (void)setUserPoints:(NSString *)userPoints {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userPoints forKey:kSettingsUserPoints];
    [defaults synchronize];
}

- (UIImage *)userImage {
    return [UIImage imageWithContentsOfFile:[self userImagePath]];
}

- (void)updateUserInfoWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    [[APIClient sharedClient] getUserInfoWithCompletion:^(NSDictionary *data, NSError *error) {
        if (data) {
            NSURL *imageUrl = [NSURL URLWithString:data[@"result"][@"image"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
            UIImage *img = [UIImage imageWithData:imageData];
            UIImage *userImage = [img thumbnailImage:120 transparentBorder:0 cornerRadius:15 interpolationQuality:kCGInterpolationDefault];

            imageData = UIImagePNGRepresentation(userImage);
            
            
            if (![imageData writeToFile:[self userImagePath] atomically:NO]) {
                NSLog((@"Failed to save image data to disk"));
            } else {
                NSLog(@"User image saved.");
            }
            
            self.userName = data[@"result"][@"display_name"];
            self.userPoints = [NSString stringWithFormat:@"%@ points", [data[@"result"][@"points"] stringValue]];
            if (completion) {
                completion(YES, nil);
            }
            
        } else {
            NSLog(@"Error: %@", error);
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

- (NSString *)userImagePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:@"userAvatar.png"];
    return imagePath;
}

@end

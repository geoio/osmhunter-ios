//
//  SettingsManager.h
//  osm_hunter
//
//  Created by Andrew Tarasenko on 6/19/13.
//  Copyright (c) 2013 happy bits. All rights reserved.
//


@interface SettingsManager : NSObject

+ (SettingsManager *) sharedInstance;

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *apiKey;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPoints;
@property (nonatomic, readonly) UIImage *userImage;

- (void)updateUserInfoWithCompletion:(void (^)(BOOL success, NSError *error))completion;

- (void)showAuthView;

@end

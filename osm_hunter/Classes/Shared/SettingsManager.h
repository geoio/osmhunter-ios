//
//  SettingsManager.h
//  osm_hunter
//
//  Created by Andrew Tarasenko on 6/19/13.
//  Copyright (c) 2013 happy bits. All rights reserved.
//


@interface SettingsManager : NSObject

+ (SettingsManager *) sharedInstance;

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *apiKey;

@end

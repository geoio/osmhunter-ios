//
//  APIClient.m
//  GeoBuddy
//
//  Created by Andrew Tarasenko on 24/01/14.
//  Copyright (c) 2014 estivo. All rights reserved.
//

#import "APIClient.h"


@implementation APIClient

+ (APIClient *)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:kAPIBaseUrl];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"Buddy-Agent" : @"GeoBuddy iOS client"}];
        _sharedClient = [[APIClient alloc] initWithBaseURL:baseUrl sessionConfiguration:config];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sharedClient;
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password {
    [[[APIClient sharedClient] requestSerializer] setAuthorizationHeaderFieldWithUsername:username password:password];
}

#pragma mark Buildings API

- (NSURLSessionDataTask *)getBuildingsNearby:(CLLocationCoordinate2D)coordinates limit:(int)limit offset:(int)offset completion:(void (^)(NSDictionary *responseData, NSError *error))completion {
    NSDictionary *params = @{
                             @"lat": [NSNumber numberWithDouble:coordinates.latitude],
                             @"lon": [NSNumber numberWithDouble:coordinates.longitude],
                             @"limit": [NSNumber numberWithInt:limit],
                             @"offset": [NSNumber numberWithInt:offset]
                             };
    NSURLSessionDataTask *dataTask = [self GET:@"/buildings/nearby/"
                                    parameters:params
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) task.response;
                                           if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(responseObject, nil);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, nil);
                                               });
                                               NSLog(@"Received: %@", responseObject);
                                               NSLog(@"Received HTTP %ld", (long) httpResponse.statusCode);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }];
    return dataTask;
}

- (NSURLSessionDataTask *)getBuilding:(NSUInteger)buildingId completion:(void (^)(NSDictionary *responseData, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"/buildings/%@", [NSNumber numberWithInteger:buildingId]];
    NSURLSessionDataTask *dataTask = [self GET:urlString
                                    parameters:nil
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) task.response;
                                           if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(responseObject, nil);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, nil);
                                               });
                                               NSLog(@"Received: %@", responseObject);
                                               NSLog(@"Received HTTP %ld", (long) httpResponse.statusCode);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }];
    return dataTask;
}

- (NSURLSessionDataTask *)getBuildingAttributes:(NSUInteger)buildingId completion:(void (^)(NSDictionary *responseData, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"/buildings/%@/edit-form/", [NSNumber numberWithInteger:buildingId]];
    NSURLSessionDataTask *dataTask = [self GET:urlString
                                    parameters:nil
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) task.response;
                                           if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(responseObject, nil);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, nil);
                                               });
                                               NSLog(@"Received: %@", responseObject);
                                               NSLog(@"Received HTTP %ld", (long) httpResponse.statusCode);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }];
    return dataTask;
}

- (NSURLSessionDataTask *)updateBuildingAttributes:(NSUInteger)buildingId attributes:(NSDictionary *)attributes completion:(void (^)(NSDictionary *responseData, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"/buildings/%@", [NSNumber numberWithInteger:buildingId]];
    NSURLSessionDataTask *dataTask = [self PUT:urlString
                                    parameters:attributes
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) task.response;
                                           if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(responseObject, nil);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, nil);
                                               });
                                               NSLog(@"Received: %@", responseObject);
                                               NSLog(@"Received HTTP %ld", (long) httpResponse.statusCode);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }];
    return dataTask;
}

@end

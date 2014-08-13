//
//  APIClient.h
//  osm_hunter
//
//  Created by Andrew Tarasenko on 24/01/14.
//

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>


@interface APIClient : AFHTTPSessionManager

+ (APIClient *)sharedClient;

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;


// Users API

- (NSURLSessionDataTask *)getAuthDataWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;
- (NSURLSessionDataTask *)getApiKeyForSessionId:(NSString *)sessionId oauthToken:(NSString *)oauthToken completion:(void (^)(NSDictionary *data, NSError *error))completion;
- (NSURLSessionDataTask *)getUserInfoWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;
- (NSURLSessionDataTask *)getLeaderBoardWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;



// Buildings API

- (NSURLSessionDataTask *)getBuildingsNearby:(CLLocationCoordinate2D)coordinates limit:(int)limit offset:(int)offset completion:(void (^)(NSDictionary *responseData, NSError *error))completion;
- (NSURLSessionDataTask *)getBuildingsNearby:(CLLocationCoordinate2D)northEast southWest:(CLLocationCoordinate2D)southWest completion:(void (^)(NSDictionary *responseData, NSError *error))completion;
- (NSURLSessionDataTask *)getBuilding:(NSUInteger)buildingId completion:(void (^)(NSDictionary *responseData, NSError *error))completion;
- (NSURLSessionDataTask *)getBuildingAttributes:(NSUInteger)buildingId completion:(void (^)(NSDictionary *responseData, NSError *error))completion;
- (NSURLSessionDataTask *)updateBuildingAttributes:(NSUInteger)buildingId attributes:(NSDictionary *)attributes completion:(void (^)(NSDictionary *responseData, NSError *error))completion;

@end
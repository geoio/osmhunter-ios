//
//  APIClient.h
//  osm_hunter
//
//  Created by Andrew Tarasenko on 24/01/14.
//
//  Low level API Client that makes http calls to the service endpoint

#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>


@interface APIClient : AFHTTPSessionManager

/**
 * Singleton shared object
 */
+ (APIClient *)sharedClient;

/**
 * Sets authorization header
 */
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;


// Users API

/**
 * Returns data for authentication
 *
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getAuthDataWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;

/**
 * Returns api key for all subsequent requests
 *
 * @param sessionId String returned from getAuthDataWithCompletion
 * @param oauthToken String returned from getAuthDataWithCompletion
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getApiKeyForSessionId:(NSString *)sessionId oauthToken:(NSString *)oauthToken completion:(void (^)(NSDictionary *data, NSError *error))completion;

/**
 * Returns user profile details
 *
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getUserInfoWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;

/**
 * Returns lederboard information
 *
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getLeaderBoardWithCompletion:(void (^)(NSDictionary *data, NSError *error))completion;



// Buildings API

/**
 * Returns buildings for defined coordinates
 *
 * @param coordinates The coordinates to search in
 * @param limit A limit of results
 * @param offset An offset of results
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getBuildingsNearby:(CLLocationCoordinate2D)coordinates limit:(int)limit offset:(int)offset completion:(void (^)(NSDictionary *responseData, NSError *error))completion;

/**
 * Returns buildings for defined bounding box
 *
 * @param northEast A northEast point of bounding box
 * @param southWest A southWest point of bounding box
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getBuildingsNearby:(CLLocationCoordinate2D)northEast southWest:(CLLocationCoordinate2D)southWest completion:(void (^)(NSDictionary *responseData, NSError *error))completion;

/**
 * Returns the building details for specified buildingId
 *
 * @param buildingId The OSM building id
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)getBuildingAttributes:(NSUInteger)buildingId completion:(void (^)(NSDictionary *responseData, NSError *error))completion;

/**
 * Updates building information
 *
 * @param buildingId The OSM building id
 * @param attributes A dictionary with new attributes
 * @param completion A block to be run on API call success or failure
 */
- (NSURLSessionDataTask *)updateBuildingAttributes:(NSUInteger)buildingId attributes:(NSDictionary *)attributes completion:(void (^)(NSDictionary *responseData, NSError *error))completion;

@end
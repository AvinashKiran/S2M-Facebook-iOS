/*
 Copyright 2012 SinnerSchrader Mobile GmbH.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>

#import "FBConnector.h"
#import "FBInternalRequest.h"
#import "FBURLConnection.h"
#import "Facebook.h"
#import "SBJSON.h"
#import <objc/runtime.h>
#import <objc/message.h>

void Swizzle(Class c, SEL orig, SEL new);

void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

static FBConnector *fbConnectorInstance = nil;

@interface FBConnector () <FBSessionDelegate, FBInternalRequestDelegate>
{
@private
    Facebook                    *_facebook;
    FBLoginDialog                    *_loginDialog;
    NSString                    *_appId;
    NSArray                     *_permissions;
    NSMutableDictionary         *_userPermissions;
    NSUInteger                  _requestId;
    NSMutableDictionary         *_requestDictionary;
    NSMutableDictionary         *_requestSuccessMethods;
    NSMutableDictionary         *_requestFailMethods;
}
@property (nonatomic, retain) Facebook              *facebook;
@property (nonatomic, retain) FBLoginDialog              *loginDialog;
@property (nonatomic, retain) NSString              *appId;
@property (nonatomic, retain) NSMutableDictionary   *userPermissions;
@property (nonatomic, retain) NSMutableDictionary   *requestDictionary;
@property (nonatomic, retain) NSMutableDictionary   *requestSuccessMethods;
@property (nonatomic, retain) NSMutableDictionary   *requestFailMethods;
@property (nonatomic, assign) BOOL                  loginWithDialog;

+ (NSString *)generateURL:(NSString*)baseURL params:(NSMutableDictionary*)params;

- (NSString *)nextRequestId;
- (FBInternalRequest *)newIntenalRequest:(id<FBConnectorDelegate>)delegate;
- (void)addInternalRequestToDictionaries:(FBInternalRequest *)request method1:(NSString *)m1 method2:(NSString *)m2;
- (void)clearSession;
@end


@interface FBConnector (RequestResults)
- (void)didLogin:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotLogin:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didLogout:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotLogout:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetUserPermissions:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetUserPermissions:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetUserInfo:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetUserInfo:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetFriends:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetFriends:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didGetFriendsUsingApplication:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetFriendsUsingApplication:(FBInternalRequest *)request withError:(NSError *)error;


- (void)didGetFeed:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetFeed:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didPost:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotPost:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didDeletePost:(FBInternalRequest *)request withResult:(id)result;
- (void)didDeleteNotPost:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetLikes:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetLikes:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didAddLike:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotAddLike:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didRemoveLike:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotRemoveLike:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetComments:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetComments:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didPostComment:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotPostComment:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didDeleteComment:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotDeleteComment:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didGetAlbums:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetAlbums:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didGetPhotosOfAlbum:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotGetPhotosOfAlbum:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didUploadPhoto:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotUploadPhoto:(FBInternalRequest *)request withError:(NSError *)error;
- (void)didDownloadImage:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotDownloadImage:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didVideoUpload:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotVideoUpload:(FBInternalRequest *)request withError:(NSError *)error;

- (void)didRequestApplication:(FBInternalRequest *)request withResult:(id)result;
- (void)didNotRequestApplication:(FBInternalRequest *)request withError:(NSError *)error;

@end

@implementation FBConnector
@synthesize facebook = _facebook;
@synthesize loginDialog = _loginDialog;
@synthesize appId = _appId;
@synthesize permissions = _permissions;
@synthesize userPermissions = _userPermissions;
@synthesize requestDictionary = _requestDictionary;
@synthesize requestSuccessMethods = _requestSuccessMethods;
@synthesize requestFailMethods = _requestFailMethods;
@synthesize loginWithDialog = _loginWithDialog;

#pragma mark - Memory Management Methods

+ (void)setUp
{
    static BOOL didSetup = NO;
    
    if (didSetup)
    {
        return;
    }
    
//    Swizzle([FBDialog class], @selector(webView:shouldStartLoadWithRequest:navigationType:), @selector(ticWebView:shouldStartLoadWithRequest:navigationType:));
    Swizzle([FBSession class], @selector(openWithCompletionHandler:), @selector(ticOpenWithCompletionHandler:));
//    Swizzle([FBDialog class], @selector(webViewDidFinishLoad:), @selector(ticWebViewDidFinishLoad:));
    
    didSetup = YES;
}

+ (NSString *)generateURL:(NSString *)baseURL params:(NSMutableDictionary *)params {
    if (params) {
        [params setObject:[FBConnector fbConnectorInstance].facebook.session.accessToken forKey:@"access_token"];
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator) {
            NSString* value = [params objectForKey:key];
            NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          kCFAllocatorDefault,
                                                                                          (CFStringRef)value,
                                                                                          NULL, // characters to leave unescaped
                                                                                          (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                                          kCFStringEncodingUTF8);
            [escaped_value autorelease];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        baseURL = [NSString stringWithFormat:@"%@?%@", baseURL, query];
    }
    
    return baseURL;
}


+ (FBConnector *)fbConnectorInstance
{
    return fbConnectorInstance;
}

- (id)initWithAppId:(NSString *)appId andDelegate:(id<FBConnectorDelegate>)delegate
{
    self = [self initWithAppId:appId urlSchemeSuffix:nil andDelegate:delegate];
        
    return self;
}

- (id)initWithAppId:(NSString *)appId 
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<FBConnectorDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        // Initialization code here.
        fbConnectorInstance = self;
        
        [FBConnector setUp];
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self
                          selector:@selector(applicationDidBecomActive:)
                              name:UIApplicationDidBecomeActiveNotification
                            object:[UIApplication sharedApplication]];
        
        _permissions = [[NSArray alloc] initWithObjects:@"offline_access", nil];
        _userPermissions = [[NSMutableDictionary alloc] initWithCapacity:1];        
        _requestDictionary = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
        _requestId = 0;
        self.appId = appId;
        
        _requestSuccessMethods = [[NSMutableDictionary alloc] init];
        _requestFailMethods = [[NSMutableDictionary alloc] init];
        
        _facebook = [[Facebook alloc] initWithAppId:appId urlSchemeSuffix:urlSchemeSuffix andDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    fbConnectorInstance = nil;
    [_facebook release];
    [_appId release];
    [_permissions release];
    [_userPermissions release];
    [_requestDictionary release];
    [_requestSuccessMethods release];
    [_requestFailMethods release];
    
    [super dealloc];
}

#pragma mark - Application Lifecycle Methods

- (void)applicationDidBecomActive:(NSNotification *)notification {
    [_facebook extendAccessTokenIfNeeded];
}

#pragma mark - Request Id Methods
- (NSString *)nextRequestId
{
    _requestId++;
    NSNumber *requestNumber = [NSNumber numberWithInt:_requestId];
    
    return [requestNumber stringValue];
}

- (FBInternalRequest *)newIntenalRequest:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[FBInternalRequest alloc] init];
    internReq.internalDelegate = self;
    internReq.requestId = [self nextRequestId];
    
    if (delegate)
        internReq.delegate = delegate;
    else
        internReq.delegate = _delegate;
    
    return internReq;
}

- (void)addInternalRequestToDictionaries:(FBInternalRequest *)request method1:(NSString *)m1 method2:(NSString *)m2
{
    [_requestDictionary setObject:request forKey:request.requestId];
    [_requestSuccessMethods setObject:m1 forKey:request.requestId];
    [_requestFailMethods setObject:m2 forKey:request.requestId];
}

- (void)clearSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self.facebook.session closeAndClearTokenInformation];
}


#pragma mark - Handle URL

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [_facebook handleOpenURL:url];
}

- (void)removeDeletegate:(id<FBConnectorDelegate>)delegate withRequestId:(id)requestId
{
    FBInternalRequest *internalRequest = [_requestDictionary objectForKey:requestId];
    if (internalRequest)
        internalRequest.delegate = nil;
}

#pragma mark - FBSessionDelegate Methods

// just dummy to remove warnings.

- (void)fbDidLogin
{
    NSLog(@"fbDidLogin: something wrong. this method should be not called.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    [self clearSession];
    NSLog(@"fbDidNotLogin: something wrong. this method should be not called.");
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    NSLog(@"fbDidExtendToken: something wrong. this method should be not called.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(accessToken ? accessToken : [self.facebook accessToken])
                 forKey:@"FBAccessTokenKey"];
    
    [defaults setObject:(expiresAt ? expiresAt :[self.facebook expirationDate])
                 forKey:@"FBExpirationDateKey"];
    
    [defaults synchronize];

}

- (void)fbDidLogout
{
    [self clearSession];
    NSLog(@"fbDidExtendToken: something wrong. this method should be not called.");
}

- (void)fbSessionInvalidated
{
    [self clearSession];
    
    NSLog(@"fbDidExtendToken: something wrong. this method should be not called.");
    if ([_delegate respondsToSelector:@selector(didSessionInvalidate:)])
        [_delegate didSessionInvalidate:nil];
}

#pragma mark - FBInternalRequestDelegate Methods

- (void)didSessionUpdate:(FBInternalRequest *)request tocken:(NSString*)token expirationDate:(NSDate*)expirationDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(token ? token : [self.facebook accessToken])
                 forKey:@"FBAccessTokenKey"];
    
    [defaults setObject:(expirationDate ? expirationDate :[self.facebook expirationDate])
                 forKey:@"FBExpirationDateKey"];
    
    [defaults synchronize];
    
    if ([request.delegate respondsToSelector:@selector(didSessionUpdate:)])
        [request.delegate didSessionUpdate:request.requestId];
    
    [_requestFailMethods removeObjectForKey:request.requestId];
    [_requestSuccessMethods removeObjectForKey:request.requestId];
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didSessionInvalidate:(FBInternalRequest *)request
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];    
    [defaults synchronize];
    
    if ([request.delegate respondsToSelector:@selector(didSessionInvalidate:)])
        [request.delegate didSessionInvalidate:request.requestId];
    
    [_requestFailMethods removeObjectForKey:request.requestId];
    [_requestSuccessMethods removeObjectForKey:request.requestId];
    [_requestDictionary removeObjectForKey:request.requestId];

}

- (void)didRequestSuccess:(FBInternalRequest *)request withResult:(id)result
{
    NSString *selectorString = [_requestSuccessMethods objectForKey:request.requestId];
    
    if (selectorString && [self respondsToSelector:NSSelectorFromString(selectorString)])
    {
        [self performSelector:NSSelectorFromString(selectorString) withObject:request withObject:result];
    }
    else if (selectorString)
    {
        NSLog(@"ooooops!! unrecognized selector - %@, result : %@", selectorString, result);
        [_requestDictionary removeObjectForKey:request.requestId];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
        [_requestDictionary removeObjectForKey:request.requestId];
    }

    [_requestFailMethods removeObjectForKey:request.requestId];
    [_requestSuccessMethods removeObjectForKey:request.requestId];
}

- (void)didRequestFail:(FBInternalRequest *)request withError:(NSError *)error
{
    NSString *selectorString = [_requestFailMethods objectForKey:request.requestId];

    if (selectorString && [self respondsToSelector:NSSelectorFromString(selectorString)])
    {
        [self performSelector:NSSelectorFromString(selectorString) withObject:request withObject:error];
    }
    else if (selectorString)
    {
        NSLog(@"ooooops!! unrecognized selector - %@, error : %@", selectorString, error);
        [_requestDictionary removeObjectForKey:request.requestId];
    }
    else
    {
        [request.delegate didRequestFail:request.requestId userCancelled:request.isCancelled withError:error];
        [_requestDictionary removeObjectForKey:request.requestId];
    }
    
    
    [_requestFailMethods removeObjectForKey:request.requestId];
    [_requestSuccessMethods removeObjectForKey:request.requestId];
}

#pragma mark - FaceBookSessionControll Methods

- (id)loginWithDelegate:(id<FBConnectorDelegate>)delegate useDialog:(BOOL)useDialog
{
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    self.loginWithDialog = useDialog;
    
    if (![self isSessionValid]) {
        _facebook.sessionDelegate = (id<FBSessionDelegate>)internReq;
        [_facebook authorize:_permissions];
    } else {
        internReq.fbRequest = [self.facebook requestWithGraphPath:@"me/permissions"
                                                      andDelegate:(id<FBRequestDelegate>)internReq];
    }
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods setObject:@"didLogin:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotLogin:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)logoutWithDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    _facebook.sessionDelegate = (id<FBSessionDelegate>)internReq;

    [_facebook logout:(id<FBSessionDelegate>)internReq];
    [self clearSession];
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods setObject:@"didLogout:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotLogout:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (BOOL)isSessionValid
{
    return [_facebook isSessionValid];
}

#pragma mark -  UserData Methods

- (id)currentUserInfoWithDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
        
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    
//    SELECT * FROM place WHERE page_id=110506962309835
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic FROM user WHERE uid=me()", @"query",
                                   nil];
    
/*
 !! FIXME : if app has "about_me" permission, we can get all of following informations.
 
    @"SELECT uid, name, pic, email, first_name, last_name, middle_name, profile_update_time, timezone, religion, birthday, birthday_date, sex, hometown_location, relationship_status, significant_other_id, activities, notes_count, wall_count, status, online_presence, locale, proxied_email, profile_url, allowed_restrictions, verified, profile_blurb, family, website, is_blocked, contact_email, third_party_id, name_format, work, education, sports, favorite_athletes, favorite_teams, inspirational_people, languages, likes_count, friend_count, mutual_friend_count, can_post FROM user WHERE uid=me()", @"query",
    nil];
 */
    
    internReq.fbRequest = [self.facebook requestWithMethodName:@"fql.query"
                                                     andParams:params
                                                 andHttpMethod:@"POST" 
                                                   andDelegate:(id<FBRequestDelegate>)internReq];
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetUserInfo:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetUserInfo:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

#pragma mark -  UserAction Methods

- (id)friendsOfUser:(FBBaseUser *)user
             offset:(NSUInteger)offset 
              limit:(NSUInteger)limit 
       withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    NSString *graphPath = [NSString stringWithFormat:@"%@/friends", user.uid];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  offsetString, @"offset",
                                  limit ? limitString : nil, @"limit",
                                  nil];
    
    internReq.fbRequest = [_facebook requestWithGraphPath:graphPath
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId]; 
    [_requestSuccessMethods setObject:@"didGetFriends:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetFriends:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)friendsUsingApplication:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"friends.getAppUsers", @"method",
                                   nil];
    internReq.fbRequest = [self.facebook requestWithParams:params
                                               andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetFriendsUsingApplication:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetFriendsUsingApplication:withError:" forKey:internReq.requestId];
    
    return internReq.requestId;
}


- (id)feedsOfUser:(FBBaseUser *)user
           offset:(NSUInteger)offset
            limit:(NSUInteger)limit
     withDelegate:(id<FBConnectorDelegate>)delegate
{    
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"until",
                                  nil];
    
    NSString *feedURL = [NSString stringWithFormat:@"%@/feed", user ? user.uid : @"me"];
    NSLog(@"session token = %@", self.facebook.session.accessToken);
    internReq.fbRequest = [_facebook requestWithGraphPath:feedURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];

    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetFeed:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetFeed:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}

- (id)postToWallOfUser:(FBBaseUser *)user
              withPost:(FBPost *)post
             useDialog:(BOOL)use
          withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];   
    // let's make post.
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    if (post.link)
        [params setObject:post.link forKey:@"link"];
    
    if (post.name)
        [params setObject:post.name forKey:@"name"];
    if (post.caption)
        [params setObject:post.caption forKey:@"caption"];
    if (post.message)
        [params setObject:post.message forKey:@"message"];
    if (post.link)
        [params setObject:post.link forKey:@"link"];
    if (post.picture)
        [params setObject:post.picture forKey:@"picture"];

    NSString *toId = @"me";
    if (user != nil)
    {
        [params setObject:user.uid forKey:@"to"];
    }
    
    if (use)
    {
        [_facebook dialog:@"feed" andParams:params andDelegate:(id<FBDialogDelegate>)internReq];
    }
    else
    {
        NSString *toIdInPost = [params objectForKey:@"to"];
        NSString *feedURL = [NSString stringWithFormat:@"%@/feed", toIdInPost ? toIdInPost : toId];
        internReq.fbRequest = [_facebook requestWithGraphPath:feedURL
                                                    andParams:params
                                                andHttpMethod:@"POST"
                                                  andDelegate:(id<FBRequestDelegate>)internReq];
    }
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didPost:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotPost:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)deletePost:(FBPost *)post withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@", post.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"DELETE"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didDeletePost:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotDeletePost:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}

- (id)likesOfUser:(FBBaseUser *)user 
           offset:(NSUInteger)offset
            limit:(NSUInteger)limit
     withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"until",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/likes", user.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetLikes:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetLikes:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)likesOfObject:(FBBaseObject *)obj
               offset:(NSUInteger)offset
                limit:(NSUInteger)limit
         withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"until",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/likes", obj.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetLikes:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetLikes:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}
- (id)addLikeTo:(FBBaseObject *)obj withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/likes", obj.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"POST"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didLike:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotLike:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}
- (id)removeLike:(FBBaseObject *)obj withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/likes", obj.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"DELETE"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didRemoveLike:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotRemoveLike:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}


- (id)commentsOfObject:(FBBaseObject *)obj
                offset:(NSUInteger)offset
                 limit:(NSUInteger)limit
          withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"offset",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/comments", obj.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];  
    [_requestSuccessMethods setObject:@"didGetComments:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetComments:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}
- (id)postComment:(FBComment *)comment to:(FBBaseObject *)obj withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    if (comment.message)
    {
        [params setObject:comment.message forKey:@"message"];
    }
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/comments", obj.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"POST"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId]; 
    [_requestSuccessMethods setObject:@"didPostComment:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotPostComment:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}
- (id)deleteComment:(FBComment *)comment withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@", comment.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"DELETE"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId]; 
    [_requestSuccessMethods setObject:@"didDeleteComments:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotDeleteComments:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}

- (id)albumsOfUser:(FBBaseUser *)user
            offset:(NSUInteger)offset
             limit:(NSUInteger)limit
       pagingToken:(NSString *)token
      withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"until",
                                  token ? token : nil, @"__paging_token",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/albums", user.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didGetAlbums:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetAlbums:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}
- (id)photosOfAlbum:(FBAlbum *)album
               offset:(NSUInteger)offset
                limit:(NSUInteger)limit
         withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"offset",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/photos", album.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didGetPhotosOfAlbum:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetPhotosOfAlbum:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)photosOfUser:(FBBaseUser *)user
            offset:(NSUInteger)offset
             limit:(NSUInteger)limit
      withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    NSString *offsetString = [NSString stringWithFormat:@"%d",offset];
    NSString *limitString = [NSString stringWithFormat:@"%d",limit];
    NSMutableDictionary *params= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  limitString, @"limit",
                                  offset ? offsetString : nil, @"until",
                                  nil];
    
    NSString *graphURL = [NSString stringWithFormat:@"%@/photos", user.uid];
    internReq.fbRequest = [_facebook requestWithGraphPath:graphURL
                                                andParams:params
                                            andHttpMethod:@"GET"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];   
    [_requestSuccessMethods setObject:@"didGetPhotosOfUser:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotGetPhotosOfUser:withError:" forKey:internReq.requestId];
    return internReq.requestId;

}

- (id)uploadPhoto:(UIImage *)image withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:image, @"picture", nil];
    
    internReq.fbRequest = [_facebook requestWithGraphPath:@"me/photos"
                                                andParams:params
                                            andHttpMethod:@"POST"
                                              andDelegate:(id<FBRequestDelegate>)internReq];
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods setObject:@"didUploadPhoto:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotUploadPhoto:withError:" forKey:internReq.requestId];
    return internReq.requestId;
}
- (id)downloadImage:(FBObject *)object imageType:(FBImageType)type withDelegate:(id<FBConnectorDelegate>)delegate
{
    __block FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    NSString *imageTypeString = nil;
    switch (type) {
        case FBImageType_album:
            imageTypeString = @"album";
            break;
        case FBImageType_square:
            imageTypeString = @"square";
            break;
        case FBImageType_normal:
            imageTypeString = @"normal";
            break;
        case FBImageType_small:
            imageTypeString = @"small";
            break;
        case FBImageType_thumbnail:
            imageTypeString = @"thumbnail";
            break;
        default:
            imageTypeString = @"thumbnail";
            break;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:imageTypeString, @"type", nil];
    NSString *baseURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", object.uid];
    NSString *graphURL = [FBConnector generateURL:baseURL params:params];
    NSURL* url = [NSURL URLWithString:graphURL];
    
    NSLog(@"Image request URL : %@", url);
    FBURLConnection *connection = [[[FBURLConnection alloc]
                                    initWithURL:url
                                    completionHandler:^(FBURLConnection* connection, NSError* error, NSURLResponse* response, NSData* data)
                                    {
                                        if (!error)
                                        {
                                            [self didDownloadImage:internReq withResult:data];
                                        }
                                        else
                                        {
                                            [self didNotDownloadImage:internReq withError:error];
                                        }
                                    }] autorelease];
    
    NSLog(@"current image request connection : %@", connection);
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods setObject:@"didDownloadImage:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotDownloadImage:withError:" forKey:internReq.requestId];

    return internReq.requestId;
}

- (id)requestApplicationToUsers:(NSArray *)users
                         message:(NSString *)message
                    notification:(NSString *)text
                    withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    NSString *selectIDsStr = [users componentsJoinedByString:@","];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   message ? message : @"",  @"message",
                                   text ? text : @"", @"notification_text",
                                   selectIDsStr ? selectIDsStr : @"", @"suggestions",
                                   nil];
    
    [self.facebook dialog:@"apprequests"
                      andParams:params
                    andDelegate:(id<FBDialogDelegate>)internReq];
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods setObject:@"didRequestApplication:withResult:" forKey:internReq.requestId];
    [_requestFailMethods setObject:@"didNotRequestApplication:withError:" forKey:internReq.requestId];
    
    return internReq.requestId;
}



#pragma mark -  FBNative Methods

- (id)requestWithParams:(NSMutableDictionary *)params
            andDelegate:(id <FBConnectorDelegate>)delegate
{
    
    if ([params objectForKey:@"method"] == nil) {
        NSLog(@"API Method must be specified");
        return nil;
    }
    
    NSString * methodName = [params objectForKey:@"method"];
    [params removeObjectForKey:@"method"];
    
    return [self requestWithMethodName:methodName
                             andParams:params
                         andHttpMethod:@"GET"
                           andDelegate:delegate];
}

- (id)requestWithMethodName:(NSString *)methodName
                  andParams:(NSMutableDictionary *)params
              andHttpMethod:(NSString *)httpMethod
                andDelegate:(id <FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    FBRequest *fbRequest = [self.facebook requestWithMethodName:methodName
                                                      andParams:params
                                                  andHttpMethod:httpMethod
                                                    andDelegate:(id<FBRequestDelegate>)internReq];
    if (fbRequest == nil)
        return nil;
    
    internReq.fbRequest = fbRequest;
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    return internReq.requestId;
}

- (id)requestWithGraphPath:(NSString *)graphPath
                 andParams:(NSMutableDictionary *)params
             andHttpMethod:(NSString *)httpMethod
               andDelegate:(id <FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    FBRequest *fbRequest = [self.facebook requestWithGraphPath:graphPath
                                                     andParams:params
                                                 andHttpMethod:httpMethod
                                                   andDelegate:(id<FBRequestDelegate>)internReq];
    if (fbRequest == nil)
        return nil;
    
    internReq.fbRequest = fbRequest;
    
    
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    return internReq.requestId;    

}

- (id)dialog:(NSString *)action
   andDelegate:(id<FBConnectorDelegate>)delegate
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    return [self dialog:action andParams:param andDelegate:delegate];
}

- (id)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    if ([action isEqualToString:@"oauth"])
    {
        self.loginWithDialog = YES;
        [_facebook dialog:action andParams:params andDelegate:(id<FBDialogDelegate>)internReq];
    }
    else
    {
        [_facebook dialog:action andParams:params andDelegate:(id<FBDialogDelegate>)internReq];
    }
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    return internReq.requestId;
}



#pragma mark -  UserPermissions Methods
- (id)extendUserPermission:(NSString *)permission withDelegate:(id<FBConnectorDelegate>)delegate
{
    
    NSArray *checkinPermissions = [[[NSArray alloc] initWithObjects:permission, nil] autorelease];    
    return [self extendUserPermissions:checkinPermissions withDelegate:delegate];
}

- (id)extendUserPermissions:(NSArray *)permissions withDelegate:(id<FBConnectorDelegate>)delegate
{
    FBInternalRequest *internReq = [[self newIntenalRequest:delegate] autorelease];
    
    _facebook.sessionDelegate = (id<FBSessionDelegate>)internReq;
    
    [_facebook authorize:permissions];
    
    [_requestDictionary setObject:internReq forKey:internReq.requestId];
    [_requestSuccessMethods
     setObject:@"didGetUserPermissions:withResult:"
     forKey:internReq.requestId];
    
    [_requestFailMethods
     setObject:@"didNotGetUserPermissions:withError:"
     forKey:internReq.requestId];
    
    return internReq.requestId;
}



#pragma mark -  RequestResults Methods

- (void)didLogin:(FBInternalRequest *)request withResult:(id)result
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if ([request.delegate respondsToSelector:@selector(didLogin:)])
        [request.delegate didLogin:request.requestId];
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotLogin:(FBInternalRequest *)request withError:(NSError *)error
{
    [self clearSession];
    
    if ([request.delegate respondsToSelector:@selector(didNotLogin:cancelled:)])
        [request.delegate didNotLogin:request.requestId cancelled:[request isCancelled]];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didLogout:(FBInternalRequest *)request withResult:(id)result
{
    [self clearSession];
    
    if ([request.delegate respondsToSelector:@selector(didLogout:)])
        [request.delegate didLogout:request.requestId];
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotLogout:(FBInternalRequest *)request withError:(NSError *)error
{
    //
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetUserInfo:(FBInternalRequest *)request withResult:(id)result
{
    NSDictionary *resultDic = nil;
    
    if ([result isKindOfClass:[NSArray class]]) {
        resultDic = [result objectAtIndex:0];
    }
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([resultDic objectForKey:@"name"]) {
        
        if ([request.delegate respondsToSelector:@selector(didGetUserInfo:withUser:)])
        {
            // If basic information callback, set the UI objects to
            // display this.
            FBUser *newUser = [[FBUser alloc] initWithDictionary:resultDic];
            [request.delegate didGetUserInfo:request.requestId withUser:newUser];
            [newUser release];
        }
        else
        {
            [request.delegate didRequestSuccess:request.requestId withResult:result];
        }
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didNotGetUserInfo:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotCurrentUserInfoRecieve:withError:)])
        [request.delegate didNotCurrentUserInfoRecieve:request.requestId withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetFriends:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetFriends:withList:)])
    {
        FBFriendList *friendList = [[FBFriendList alloc] initWidthDictionary:result];
        [request.delegate didGetFriends:request.requestId withList:friendList];
        [friendList release];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didNotGetFriends:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetFriends:withError:)])
        [request.delegate didNotGetFriends:request.requestId withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didGetFriendsUsingApplication:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetFriendsUsingApplication:withArray:)])
    {
        NSArray *newArray = [NSArray arrayWithArray:(NSArray *)result];
        [request.delegate didGetFriendsUsingApplication:request.requestId withArray:newArray];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didNotGetFriendsUsingApplication:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetFriendsUsingApplication:withError:)])
        [request.delegate didNotGetFriendsUsingApplication:request.requestId withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetUserPermissions:(FBInternalRequest *)request withResult:(id)result
{
    NSArray *resultArray = nil;
    NSDictionary *resultDic = nil;
    
    if ([result isKindOfClass:[NSArray class]]) {
        resultDic = [result objectAtIndex:0];
    }
    
    resultArray = [resultDic objectForKey:@"data"];
    
    if (resultArray)
        [self setUserPermissions:[resultArray objectAtIndex:0]];
    
    if ([request.delegate respondsToSelector:@selector(didUserPermissionUpdated:)])
        [request.delegate didUserPermissionUpdated:request.requestId];
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didNotGetUserPermissions:(FBInternalRequest *)request withError:(NSError *)error
{
    //
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetFeed:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetFeeds:withList:)])
    {
        FBFeedList *newFeeds = [[FBFeedList alloc] initWidthDictionary:result];
        [request.delegate didGetFeeds:request.requestId withList:newFeeds];
        [newFeeds release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didNotGetFeed:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetFeed:withError:)])
    {
        [request.delegate didNotGetFeeds:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didPost:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didPost:withId:)])
    {
        NSString *newId = ([result isKindOfClass:[NSString class]]) ? (NSString*)result : [result stringValue];
        [request.delegate didPost:request.requestId withId:newId];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotPost:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotPost:cancelled:withError:)])
        [request.delegate didNotPost:request.requestId cancelled:[request isCancelled] withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didDeletePost:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didDeletePost:success:)])
    {
        [request.delegate didDeletePost:request.requestId success:(BOOL)result];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotDeletePost:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotDeletePost:cancelled:withError:)])
        [request.delegate didNotDeletePost:request.requestId cancelled:[request isCancelled] withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetLikes:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetLikes:withList:)])
    {
        FBLikeList *likes = [[FBLikeList alloc] initWidthDictionary:result];
        [request.delegate didGetLikes:request.requestId withList:likes];
        [likes release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotGetLikes:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetLikes:withError:)])
    {
        [request.delegate didNotGetLikes:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];

}
- (void)didAddLike:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didAddLike:success:)])
    {
        [request.delegate didAddLike:request.requestId success:(BOOL)result];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotAddLike:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didAddLike:withError:)])
    {
        [request.delegate didNotAddLike:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didRemoveLike:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didRemoveLike:success:)])
    {
        [request.delegate didRemoveLike:request.requestId success:(BOOL)result];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotRemoveLike:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotRemoveLike:withError:)])
    {
        [request.delegate didNotRemoveLike:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didGetComments:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetComments:withList:)])
    {
        FBCommentList *comments = [[FBCommentList alloc] initWidthDictionary:result];
        [request.delegate didGetComments:request.requestId withList:comments];
        [comments release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];

}
- (void)didNotGetComments:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetComments:withError:)])
    {
        [request.delegate didNotGetComments:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didPostComment:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didPostComment:withId:)])
    {
        NSString *newId = ([result isKindOfClass:[NSString class]]) ? (NSString*)result : [result stringValue];
        [request.delegate didPostComment:request.requestId withId:newId];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];

}
- (void)didNotPostComment:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotPostComment:withError:)])
    {
        [request.delegate didNotPostComment:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];

}
- (void)didDeleteComment:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didDeleteComment:success:)])
    {
        [request.delegate didDeleteComment:request.requestId success:(BOOL)result];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];

}
- (void)didNotDeleteComment:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotDeleteComment:withError:)])
    {
        [request.delegate didNotDeleteComment:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}


- (void)didGetAlbums:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetAlbums:withList:)])
    {
        FBAlbumList *albums = [[FBAlbumList alloc] initWidthDictionary:result];
        
        [request.delegate didGetAlbums:request.requestId withList:albums];
        [albums release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}
- (void)didNotGetAlbums:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotGetAlbums:withError:)])
    {
        [request.delegate didNotGetAlbums:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didGetPhotosOfAlbum:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetPhotosOfAlbum:withList:)])
    {
        FBAlbumPhotoList *photos = [[FBAlbumPhotoList alloc] initWidthDictionary:result];
        [request.delegate didGetPhotosOfAlbum:request.requestId withList:photos];
        [photos release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}
- (void)didNotGetPhotosOfAlbum:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotPhotos:withError:)])
    {
        [request.delegate didNotGetPhotosOfAlbum:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}

- (void)didGetPhotosOfUser:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didGetPhotosOfUser:withList:)])
    {
        FBUserPhotoList *photos = [[FBUserPhotoList alloc] initWidthDictionary:result];
        [request.delegate didGetPhotosOfUser:request.requestId withList:photos];
        [photos release];
    }
    else
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}
- (void)didNotGetPhotosOfUser:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotPhotos:withError:)])
    {
        [request.delegate didNotGetPhotosOfUser:request.requestId withError:error];
    }
    else
        [request.delegate didRequestFail:request.requestId userCancelled:request.cancelled withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}

- (void)didUploadPhoto:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didUploadPhoto:withPhtoId:)])
    {   
        NSString *newId = ([result isKindOfClass:[NSString class]]) ? (NSString*)result : [result stringValue];
        [request.delegate didUploadPhoto:request.requestId withPhtoId:newId];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotUploadPhoto:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotUploadPhoto:cancelled:withError:)])
        [request.delegate didNotUploadPhoto:request.requestId cancelled:[request isCancelled] withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didDownloadImage:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didDownloadImage:withImageData:)])
    {
        UIImage *newImage = nil;
        if ([result isKindOfClass:[NSData class]])
            newImage = [UIImage imageWithData:result];
        [request.delegate didDownloadImage:request.requestId withImageData:newImage];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }

    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotDownloadImage:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotDownloadImage:withError:)])
        [request.delegate didNotDownloadImage:request.requestId withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    

    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didVideoUpload:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didVideoUpload:withVideoId:)])
    {
        NSString *newId = ([result isKindOfClass:[NSString class]]) ? (NSString*)result : [result stringValue];
        [request.delegate didVideoUpload:request.requestId withVideoId:newId];
    }
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
    
}
- (void)didNotVideoUpload:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotVideoUpload:cancelled:withError:)])
        [request.delegate didNotVideoUpload:request.requestId cancelled:[request isCancelled] withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

- (void)didRequestApplication:(FBInternalRequest *)request withResult:(id)result
{
    if ([request.delegate respondsToSelector:@selector(didRequestApplication:)])
        [request.delegate didRequestApplication:request.requestId];
    else
    {
        [request.delegate didRequestSuccess:request.requestId withResult:result];
    }
    
    [_requestDictionary removeObjectForKey:request.requestId];
}
- (void)didNotRequestApplication:(FBInternalRequest *)request withError:(NSError *)error
{
    if ([request.delegate respondsToSelector:@selector(didNotRequestApplication:cancelled:withError:)])
        [request.delegate didNotRequestApplication:request.requestId cancelled:[request isCancelled] withError:error];
    else
        [request.delegate didRequestFail:request.requestId userCancelled:[request isCancelled] withError:error];
    
    [_requestDictionary removeObjectForKey:request.requestId];
}

@end

@interface FBSession (TICSession)
- (void)ticOpenWithCompletionHandler:(FBSessionStateHandler)handler;
@end

@implementation FBSession (TICSession)
- (void)ticOpenWithCompletionHandler:(FBSessionStateHandler)handler {
    if ([[FBConnector fbConnectorInstance] loginWithDialog])
    {
        [self openWithBehavior:FBSessionLoginBehaviorSuppressSSO completionHandler:handler];
    }
    else
    {
        [self ticOpenWithCompletionHandler:handler];
    }
}
@end

@interface FBDialog (TICDialog)

- (BOOL)ticWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType;
- (void)ticWebViewDidFinishLoad:(UIWebView *)webView;
@end

@implementation FBDialog (TICDialog)

- (BOOL)ticWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType {
    NSURL* url = request.URL;
    NSLog(@"start to load URL: %@", url);
    // inside server error
    NSString *authenticatedError = @"http://m.facebook.com/developers/login_error.php?app_id=";
    NSString *currentURLString = [url absoluteString];
    
    if ([currentURLString hasPrefix:authenticatedError])
    {
        NSLog(@"show waiting message");
    }
    
    // get App ID
    NSString *appScheme = nil;
    NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
        ([aBundleURLTypes count] > 0)) {
        NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
        if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                ([aBundleURLSchemes count] > 0)) {
                appScheme = [aBundleURLSchemes objectAtIndex:0];
            }
        }
    }
    
    if ([url.scheme isEqualToString:appScheme]) {
        NSString *fullURL = [url absoluteString];
        fullURL = [fullURL stringByReplacingOccurrencesOfString:appScheme withString:@"fbconnect"];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    }
    
    return [self ticWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)ticWebViewDidFinishLoad:(UIWebView *)webView
{
    NSURL* url = webView.request.URL;
    NSLog(@"finished to load URL: %@", url);
    
    // inside server error
    NSString *authenticatedError = @"http://m.facebook.com/developers/login_error.php?app_id=";
    NSString *currentURLString = [url absoluteString];
    
    if ([currentURLString hasPrefix:authenticatedError])
    {
        // get App ID
        NSString *appScheme = nil;
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    appScheme = [aBundleURLSchemes objectAtIndex:0];
                }
            }
        }
        
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
        NSString *redirect_uri = [NSString stringWithFormat:@"%@://authorize", appScheme];
        [params setObject:redirect_uri forKey:@"redirect_uri"];
        // define permission scope.
        NSString *scope = [[FBConnector fbConnectorInstance].permissions componentsJoinedByString:@","];
        [params setObject:scope forKey:@"scope"];
        [params setObject:@"ios" forKey:@"sdk"];
        [params setObject:@"user_agent" forKey:@"type"];
        [params setObject:@"touch" forKey:@"display"];
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString *fbAppID = [bundle objectForInfoDictionaryKey:@"FacebookAppID"];
        
        [params setObject:fbAppID forKey:@"client_id"];
        NSString *urlString = [FBConnector generateURL:@"https://m.facebook.com/dialog/oauth" params:params];
        NSLog(@"%@", urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    [self ticWebViewDidFinishLoad:webView];
}
@end

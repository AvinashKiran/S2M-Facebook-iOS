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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FBConnectorDelegate.h"
#import "FBUser.h"
#import "FBFriend.h"
#import "FBFriendList.h"
#import "FBTag.h"
#import "FBTagList.h"
#import "FBPost.h"
#import "FBPlace.h"
#import "FBLocation.h"
#import "FBFeedList.h"
#import "FBComment.h"
#import "FBCommentList.h"
#import "FBLikeList.h"
#import "FBPhoto.h"
#import "FBAlbum.h"
#import "FBAlbumList.h"
#import "FBAlbumPhotoList.h"
#import "FBUserPhotoList.h"

enum {
    FBImageType_normal = 0,
    FBImageType_square,
    FBImageType_album,
    FBImageType_small,
    FBImageType_thumbnail
};

typedef NSUInteger FBImageType;

@class FBDialog;

@interface FBConnector : NSObject
{
@private
    id<FBConnectorDelegate>    _delegate;
}

@property (nonatomic, retain) NSArray               *permissions;

+ (FBConnector *)fbConnectorInstance;

- (id)initWithAppId:(NSString *)appId
        andDelegate:(id<FBConnectorDelegate>)delegate;
- (id)initWithAppId:(NSString *)appId 
    urlSchemeSuffix:(NSString *)urlSchemeSuffix
        andDelegate:(id<FBConnectorDelegate>)delegate;
//delegate have to be alived until this FBConnector object is alive.

- (BOOL)handleOpenURL:(NSURL *)url;
- (void)removeDeletegate:(id<FBConnectorDelegate>)delegate withRequestId:(id)requestId;
@end

@interface FBConnector (userPermissions)
// if 'delegate' is nil, delegate will be the stored delegete, which is used to initialize the FBConnector object.

- (id)extendUserPermission:(NSString *)permission withDelegate:(id<FBConnectorDelegate>)delegate;
- (id)extendUserPermissions:(NSArray *)permissions withDelegate:(id<FBConnectorDelegate>)delegate;

@end

@interface FBConnector (FaceBookSessionControll)
// if 'delegate' is nil, delegate will be the stored delegete, which is used to initialize the FBConnector object.

- (id)loginWithDelegate:(id<FBConnectorDelegate>)delegate useDialog:(BOOL)use;
- (id)logoutWithDelegate:(id<FBConnectorDelegate>)delegate;

- (BOOL)isSessionValid;
@end

@interface FBConnector (UserData)
// if 'delegate' is nil, delegate will be the stored delegete, which is used to initialize the FBConnector object.

- (id)currentUserInfoWithDelegate:(id<FBConnectorDelegate>)delegate;
@end

@interface FBConnector (UserAction)
// if 'delegate' is nil, delegate will be the stored delegete, which is used to initialize the FBConnector object.

- (id)friendsOfUser:(FBBaseUser *)user
             offset:(NSUInteger)offset 
              limit:(NSUInteger)limit 
       withDelegate:(id<FBConnectorDelegate>)delegate;
// the app can just get the friends list from current user and current user's friend who using this app
- (id)friendsUsingApplication:(id<FBConnectorDelegate>)delegate;

- (id)feedsOfUser:(FBBaseUser *)user
           offset:(NSUInteger)offset
            limit:(NSUInteger)limit
     withDelegate:(id<FBConnectorDelegate>)delegate;

- (id)postToWallOfUser:(FBBaseUser *)user
              withPost:(FBPost *)post
             useDialog:(BOOL)use
          withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.
- (id)deletePost:(FBPost *)post 
    withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.

- (id)likesOfUser:(FBBaseUser *)user
           offset:(NSUInteger)offset
            limit:(NSUInteger)limit
     withDelegate:(id<FBConnectorDelegate>)delegate;
- (id)likesOfObject:(FBBaseObject *)obj
               offset:(NSUInteger)offset
                limit:(NSUInteger)limit
         withDelegate:(id<FBConnectorDelegate>)delegate;
- (id)addLikeTo:(FBBaseObject *)obj withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.
- (id)removeLike:(FBBaseObject *)obj withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.

- (id)commentsOfObject:(FBBaseObject *)obj
                offset:(NSUInteger)offset
                 limit:(NSUInteger)limit
          withDelegate:(id<FBConnectorDelegate>)delegate;
- (id)postComment:(FBComment *)comment
               to:(FBBaseObject *)obj
     withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.
- (id)deleteComment:(FBComment *)comment withDelegate:(id<FBConnectorDelegate>)delegate;
// publish_stream permission.

- (id)albumsOfUser:(FBBaseUser *)user
            offset:(NSUInteger)offset
             limit:(NSUInteger)limit
       pagingToken:(NSString *)token
      withDelegate:(id<FBConnectorDelegate>)delegate;
// request album list of user
// user_photos permissions
// friend_photos permissions if it is not public and belongs to a user's friend

- (id)photosOfAlbum:(FBAlbum *)album
               offset:(NSUInteger)offset
                limit:(NSUInteger)limit
         withDelegate:(id<FBConnectorDelegate>)delegate;
// request photos in album
// user_photos permission to access photos and albums uploaded by the user, and photos in which the user has been tagged
// friends_photos permission to access friends' photos and photos in which the user's friends have been tagged

- (id)photosOfUser:(FBBaseUser *)user
            offset:(NSUInteger)offset
             limit:(NSUInteger)limit
      withDelegate:(id<FBConnectorDelegate>)delegate;
// request photos which have tags of user.
- (id)uploadPhoto:(UIImage *)image withDelegate:(id<FBConnectorDelegate>)delegate;
// upload image to application's album. if there is no album for the application, it will be made automatically.
// photo_upload permissions is required
- (id)downloadImage:(FBObject *)object
          imageType:(FBImageType)type
       withDelegate:(id<FBConnectorDelegate>)delegate;

- (id)requestApplicationToUsers:(NSArray *)users
                        message:(NSString *)message
                   notification:(NSString *)text
                   withDelegate:(id<FBConnectorDelegate>)delegate;

@end


@interface FBConnector (FBNative)
// if 'delegate' is nil, delegate will be the stored delegete, which is used to initialize the FBConnector object.
// response protocol
// success - idRequestSuccess:withResult:
// fail - didRequestFail:userCancelled:withError:

- (id)requestWithParams:(NSMutableDictionary *)params
                    andDelegate:(id <FBConnectorDelegate>)delegate;

- (id)requestWithMethodName:(NSString *)methodName
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id <FBConnectorDelegate>)delegate;

- (id)requestWithGraphPath:(NSString *)graphPath
                         andParams:(NSMutableDictionary *)params
                     andHttpMethod:(NSString *)httpMethod
                       andDelegate:(id <FBConnectorDelegate>)delegate;

- (id)dialog:(NSString *)action
   andDelegate:(id<FBConnectorDelegate>)delegate;

- (id)dialog:(NSString *)action
     andParams:(NSMutableDictionary *)params
   andDelegate:(id <FBConnectorDelegate>)delegate;


@end




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
@class FBUser;
@class FBFriendList;
@class FBFeedList;
@class FBLikeList;
@class FBCommentList;
@class FBAlbumList;
@class FBAlbumPhotoList;
@class FBUserPhotoList;

@protocol FBConnectorDelegate <NSObject>
@required
- (void)didRequestSuccess:(id)requestId withResult:(id)result;
- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error;

@optional
- (void)didLogin:(id)requestId;
- (void)didNotLogin:(id)requestId cancelled:(BOOL)cancelled;

- (void)didLogout:(id)requestId;

- (void)didSessionUpdate:(id)requestId;
- (void)didSessionInvalidate:(id)requestId;

- (void)didUserPermissionUpdated:(id)requestId;

- (void)didGetUserInfo:(id)requestId withUser:(FBUser *)user;
- (void)didNotCurrentUserInfoRecieve:(id)requestId withError:(NSError *)error;

- (void)didGetFriends:(id)requestId withList:(FBFriendList *)friendsList;
- (void)didNotGetFriends:(id)requestId withError:(NSError *)error;
- (void)didGetFriendsUsingApplication:(id)requestId withArray:(NSArray *)userIds;
- (void)didNotGetFriendsUsingApplication:(id)requestId withError:(NSError *)error;

- (void)didGetFeeds:(id)requestId withList:(FBFeedList *)feeds;
- (void)didNotGetFeeds:(id)requestId withError:(NSError *)error;
- (void)didPost:(id)requestId withId:(NSString *)postId;
- (void)didNotPost:(id)requestId cancelled:(BOOL)cancelled withError:(NSError *)error;
- (void)didDeletePost:(id)requestId success:(BOOL)result;
- (void)didNotDeletePost:(id)requestId cancelled:(BOOL)cancelled withError:(NSError *)error;

- (void)didGetLikes:(id)requestId withList:(FBLikeList *)likes;
- (void)didNotGetLikes:(id)requestId withError:(NSError *)error;
- (void)didAddLike:(id)requestId success:(BOOL)result;
- (void)didNotAddLike:(id)requestId withError:(NSError *)error;
- (void)didRemoveLike:(id)requestId success:(BOOL)result;
- (void)didNotRemoveLike:(id)requestId withError:(NSError *)error;

- (void)didGetComments:(id)requestId withList:(FBCommentList *)comments;
- (void)didNotGetComments:(id)requestId withError:(NSError *)error;
- (void)didPostComment:(id)requestId withId:(NSString *)commentId;
- (void)didNotPostComment:(id)requestId withError:(NSError *)error;
- (void)didDeleteComment:(id)requestId success:(BOOL)result;
- (void)didNotDeleteComment:(id)requestId withError:(NSError *)error;

- (void)didGetAlbums:(id)requestId withList:(FBAlbumList *)albums;
- (void)didNotGetAlbums:(id)requestId withError:(NSError *)error;
- (void)didGetPhotosOfAlbum:(id)requestId withList:(FBAlbumPhotoList *)photos;
- (void)didNotGetPhotosOfAlbum:(id)requestId withError:(NSError *)error;
- (void)didGetPhotosOfUser:(id)requestId withList:(FBUserPhotoList *)photos;
- (void)didNotGetPhotosOfUser:(id)requestId withError:(NSError *)error;
- (void)didUploadPhoto:(id)requestId withPhtoId:(NSString *)photoId;
- (void)didNotUploadPhoto:(id)requestId cancelled:(BOOL)cancelled withError:(NSError *)error;
- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image;
- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error;

- (void)didVideoUpload:(id)requestId withVideoId:(NSString *)videoId;
- (void)didNotVideoUpload:(id)requestId cancelled:(BOOL)cancelled withError:(NSError *)error;

- (void)didRequestApplication:(id)requestId;
- (void)didNotRequestApplication:(id)requestId cancelled:(BOOL)cancelled withError:(NSError *)error;

@end

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
#import "FBObject.h"

@class FBBaseUser;
@class FBCommentList;
@class FBLikeList;
@class FBComment;
@class FBPlace;

@interface FBBaseObject : FBObject
@property (nonatomic, retain, readonly) FBBaseUser                  *owner;
@property (nonatomic, assign, readonly, getter = canComment) BOOL   commentable;
@property (nonatomic, assign, readonly, getter = canLike) BOOL      likable;
//@property (nonatomic, assign, readonly, getter = canDelete) BOOL    deletable;
@property (nonatomic, assign, readonly, getter = canModify) BOOL    modifiable;
@property (nonatomic, retain, readonly) FBCommentList               *comments;
@property (nonatomic, retain, readonly) FBLikeList                  *likes;
@property (nonatomic, copy, readonly) FBPlace                    *place;
@property (nonatomic, retain, readonly) NSDate                      *created_time;
@property (nonatomic, retain, readonly) NSDate                      *updated_time;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)properties;
@end

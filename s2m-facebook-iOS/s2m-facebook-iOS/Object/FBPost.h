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
#import "FBBaseObject.h"

@class FBTag;
@class FBTagList;
//@class FBApplcation;

@interface FBPost : FBBaseObject

@property (nonatomic, retain, readonly)   NSMutableArray          *targetUsers;
@property (nonatomic, retain)   NSString            *caption;
@property (nonatomic, retain)   NSString            *message;
@property (nonatomic, retain)   FBTagList             *message_tags;
@property (nonatomic, readonly)   NSString            *icon;
@property (nonatomic, retain)   NSString            *postDescription;
@property (nonatomic, retain)   NSString            *link;
@property (nonatomic, retain)   NSString            *picture;
@property (nonatomic, retain)   NSString            *source;
@property (nonatomic, retain, readonly) NSDictionary    *postProperties;
@property (nonatomic, retain) FBTagList             *with_tags;
@property (nonatomic, retain, readonly) NSString            *objId;
@property (nonatomic, copy, readonly) NSString            *story;
@property (nonatomic, retain, readonly) FBTagList             *stroy_tags;
//@property (nonatomic, retain, readonly) FBApplcation             *application;
@property (nonatomic, assign, readonly, getter = isPublisched) BOOL publish;

@end

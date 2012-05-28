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

@interface FBTag : NSObject

@property (nonatomic, retain) NSString          *uid;
@property (nonatomic, retain) NSString          *name;
@property (nonatomic, retain) NSString          *type;
@property (nonatomic, assign) NSInteger         offset;
@property (nonatomic, assign) NSInteger         length;
@property (nonatomic, assign) NSInteger         x;
@property (nonatomic, assign) NSInteger         y;
@property (nonatomic, retain, readonly) NSDate  *created_time;

- (id)initWidthDictionary:(NSDictionary *)data;
@end

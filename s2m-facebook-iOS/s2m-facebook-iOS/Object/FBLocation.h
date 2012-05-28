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

@interface FBLocation : NSObject
{
    NSString *_street;
    NSString *_city;
    NSString *_state;
    NSString *_country;
    NSString *_zip;
}
@property (nonatomic, retain) NSString  *street;
@property (nonatomic, retain) NSString  *city;
@property (nonatomic, retain) NSString  *state;
@property (nonatomic, retain) NSString  *country;
@property (nonatomic, retain) NSString  *zip;
@property (nonatomic, retain) NSString  *latitude;
@property (nonatomic, retain) NSString  *longitute;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
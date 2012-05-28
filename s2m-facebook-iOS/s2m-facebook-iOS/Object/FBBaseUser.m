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


#import "FBBaseUser.h"
#import "FBLocation.h"

@implementation FBBaseUser
@synthesize pic = _pic;
@synthesize address = _address;

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self)
    {
        self.pic = [dic objectForKey:@"pic"];
    }
    
    return  self;
}
- (void)dealloc
{
    [_pic release];
    [_address release];
    
    [super dealloc];
}
@end
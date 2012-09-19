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


#import "FBUser.h"

static FBUser *staticInstance = nil;

@implementation FBUser

@synthesize firstName;
@synthesize middleName;
@synthesize lastName;
@synthesize contactEmail;
@synthesize email;
@synthesize locale;
@synthesize nameFormat;
@synthesize gender;
@synthesize website;

+ (FBUser *)currentUser
{
    return staticInstance;
}

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self)
    {
        self.firstName = [dic objectForKey:@"first_name"];
        self.middleName = [dic objectForKey:@"middle_name"];
        self.lastName = [dic objectForKey:@"last_name"];
        self.contactEmail = [dic objectForKey:@"contact_email"];
        self.email = [dic objectForKey:@"email"];
        self.locale = [dic objectForKey:@"locale"];
        self.gender = [dic objectForKey:@"sex"];
        self.nameFormat = [dic objectForKey:@"name_format"];
        self.website = [dic objectForKey:@"website"];
        staticInstance = self;
    }
    
    return  self;
}

- (void)dealloc
{
    if (staticInstance == self)
    {
        staticInstance = nil;
    }
    self.firstName = nil;
    self.middleName = nil;
    self.contactEmail = nil;
    self.lastName = nil;
    self.email = nil;
    self.locale = nil;
    self.gender = nil;
    self.nameFormat = nil;
    
    [super dealloc];
}

@end

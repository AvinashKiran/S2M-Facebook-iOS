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


#import "FBLocation.h"

@implementation FBLocation
@synthesize street = _street;
@synthesize city = _city;
@synthesize state = _state;
@synthesize country = _country;
@synthesize zip = _zip;
@synthesize latitude = _latitude;
@synthesize longitute = _longitute;

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        self.street = [dic objectForKey:@"street"];
        self.city = [dic objectForKey:@"city"];
        self.state = [dic objectForKey:@"state"];
        self.country = [dic objectForKey:@"country"];
        self.zip = [dic objectForKey:@"zip"];
        self.latitude = [dic objectForKey:@"latitude"];
        self.longitute = [dic objectForKey:@"longitude"];
    }
    
    return  self;
}

- (void)dealloc
{
    [_state release];
    [_street release];
    [_city release];
    [_country release];
    [_zip release];
    [_latitude release];
    [_longitute release];
    [super dealloc];
}


@end
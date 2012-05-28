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


#import "FBObject.h"

@implementation FBObject
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize type = _type;

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        self.name = [dic objectForKey:@"name"];
        self.uid = [dic objectForKey:@"id"];
        if (!_uid)
            self.uid = [dic objectForKey:@"uid"];
        
        if ([self.uid isKindOfClass:[NSNumber class]])
            self.uid = [(NSNumber *)self.uid stringValue];
        
        self.type = [dic objectForKey:@"type"];
    }
    
    return self;
}

- (void)dealloc
{
    [_uid release];
    [_name release];
    [_type release];
    [super dealloc];
}
@end

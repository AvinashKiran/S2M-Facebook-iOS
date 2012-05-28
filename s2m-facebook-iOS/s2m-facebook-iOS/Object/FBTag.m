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


#import "FBTag.h"

@implementation FBTag

@synthesize uid = _uid;
@synthesize name = _name;
@synthesize type = _type;
@synthesize offset = _offset;
@synthesize length = _length;
@synthesize x = _x;
@synthesize y = _y;
@synthesize created_time = _created_time;

- (id)initWidthDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        _name = [[data objectForKey:@"name"] retain];
        _uid = [[data objectForKey:@"id"] retain];
        if ([self.uid isKindOfClass:[NSNumber class]])
            self.uid = [(NSNumber *)self.uid stringValue];
        
        _type = [[data objectForKey:@"type"] retain];
        _offset = ([data objectForKey:@"offset"]) ? [[data objectForKey:@"offset"] integerValue] : -1;
        _length = ([data objectForKey:@"length"]) ? [[data objectForKey:@"length"] integerValue] : -1;
        
        _y = ([data objectForKey:@"x"]) ? [[data objectForKey:@"x"] integerValue] : -100;
        _length = ([data objectForKey:@"y"]) ? [[data objectForKey:@"y"] integerValue] : -100;
        
        NSString *creationTime = [data objectForKey:@"created_time"];
        if (creationTime)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeStyle:NSDateFormatterFullStyle];
            [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
            _created_time = [formatter dateFromString:(NSString *)creationTime];
            [_created_time retain];
            [formatter release];
        }

    }
    return self;
}

- (void)dealloc
{
    [_uid release];
    [_name release];
    [_type release];
    [_created_time release];
    
    [super dealloc];
}

@end

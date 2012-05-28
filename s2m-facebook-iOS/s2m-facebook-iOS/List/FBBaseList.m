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


#import "FBBaseList.h"

@implementation FBBaseList
@synthesize limit = _limit;
@synthesize offset = _offset;
@synthesize hasMore = _hasMore;
@synthesize objects = _objects;
@synthesize count = _count;
@synthesize token = _token;
- (id)init
{
    self = [super init];
    if (self)
        _hasMore = NO;
    
    return self;
}

- (id)initWidthDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        // do something
        _hasMore = NO;
        NSDictionary *paging = [data objectForKey:@"paging"];
        if (!paging)
        {
            _hasMore = NO;
            return self;
        }
        
        NSString *nextURL = [paging objectForKey:@"next"];
        if (!nextURL)
        {
            _hasMore = NO;
            return self;
        }
        
        //let's find 
        
        NSArray *removeURL = [nextURL componentsSeparatedByString:@"?"];
        if ([removeURL count] < 2)
            return self;
        NSString *parameters = [removeURL objectAtIndex:1];
        NSArray *components = [parameters componentsSeparatedByString:@"&"];
        NSString *keyUntil = @"until=";
        NSString *keyOffset = @"offset=";
        NSString *keyLimit = @"limit=";
        NSString *keyPaging = @"__paging_token=";
        for (NSString *comp in components)
        {
            if ([comp hasPrefix:keyUntil])
            {
                NSString *offsetString = [comp substringFromIndex:[keyUntil length]];
                _offset = [offsetString integerValue];

            }
            else if ([comp hasPrefix:keyOffset])
            {
                NSString *offsetString = [comp substringFromIndex:[keyOffset length]];
                _offset = [offsetString integerValue]; 
                
            }
            else if ([comp hasPrefix:keyLimit])
            {
                NSString *limitString = [comp substringFromIndex:[keyLimit length]];
                _limit = [limitString integerValue];                 
            }
            else if ([comp hasPrefix:keyPaging])
            {
                _token = [comp substringFromIndex:[keyPaging length]];
                [_token retain];
            }
        }

    }
    
    return self;
}

- (void)dealloc
{
    [_objects release];
    [_token release];
    [super dealloc];
}

- (BOOL)hasMore
{
    return _hasMore;
}

- (NSUInteger)count
{
    return [_objects count];
}

@end

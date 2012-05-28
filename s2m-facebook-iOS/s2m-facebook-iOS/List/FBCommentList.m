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


#import "FBCommentList.h"
#import "FBComment.h"
@implementation FBCommentList
@synthesize totalCount = _totalCount;
- (id)initWidthDictionary:(NSDictionary *)data
{
    self = [super initWidthDictionary:data];
    if (self)
    {
        // do something
        _totalCount = 0;
        NSArray *resultData = [data objectForKey:@"data"];
        
        if (resultData)
        {
            NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:1];
            
            for (NSDictionary *data in resultData)
            {
                FBComment *newComment = [[FBComment alloc] initWithDictionary:data];
                [comments addObject:newComment];
                [newComment release];
            }
            
            _objects = comments;
        }
        
        if ([data objectForKey:@"count"])
        {
            NSNumber *countObj = [data objectForKey:@"count"];
            _totalCount = [countObj unsignedIntValue];
        }
    }
    
    return self;
}

- (BOOL)hasMore
{
    if (_totalCount > 0 && [_objects count] + _offset < _totalCount)
        return NO;
    
    if (_totalCount == 0 && [_objects count] > 0)
    {
        if ([_objects count] < _limit)
            return NO;
        
        else
            return YES;
    }
    
    return YES;
}


@end

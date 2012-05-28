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


#import "FBTagList.h"
#import "FBTag.h"

@implementation FBTagList

- (id)initWidthDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self)
    {
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        
        if ([data objectForKey:@"data"])
        {
            NSArray *tagArray = [data objectForKey:@"data"];
            for (NSDictionary *tagDic in tagArray)
            {
                FBTag *newTag = [[FBTag alloc] initWidthDictionary:tagDic];
                [tags addObject:newTag];
                [newTag release];
            }
        }
        else
        {
            for (NSString *key in data)
            {
                NSArray *tagArray = [data objectForKey:key];
                for (NSDictionary *tagDic in tagArray)
                {
                    FBTag *newTag = [[FBTag alloc] initWidthDictionary:tagDic];
                    [tags addObject:newTag];
                    [newTag release];
                }
            }
        }
        
        _objects = tags;
        
    }
    return self;
}

@end

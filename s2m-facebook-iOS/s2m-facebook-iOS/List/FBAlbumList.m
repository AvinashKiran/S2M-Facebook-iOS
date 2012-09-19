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


#import "FBAlbumList.h"
#import "FBAlbum.h"

@implementation FBAlbumList

- (id)initWidthDictionary:(NSDictionary *)data
{
    self = [super initWidthDictionary:data];
    if (self)
    {
        // do something
        NSArray *resultData = [data objectForKey:@"data"];
        if (resultData)
        {       
            NSMutableArray *albums = [[NSMutableArray alloc] initWithCapacity:1];

            for (NSDictionary *data in resultData)
            {
                FBAlbum *newAlbum = [[FBAlbum alloc] initWithDictionary:data];
                [albums addObject:newAlbum];
                [newAlbum release];
            }
            
            _objects = albums;
        }
    }
    
    return self;
}

@end

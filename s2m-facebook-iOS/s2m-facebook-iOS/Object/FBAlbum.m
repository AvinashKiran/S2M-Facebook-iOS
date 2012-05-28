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


#import "FBAlbum.h"

@implementation FBAlbum
@synthesize albumDescription = _albumDescription;
@synthesize location = _location;
@synthesize link = _link;
@synthesize cover_photo = _cover_photo;
//@synthesize privacy = _privacy;
@synthesize count = _count;
@synthesize type = _type;
@synthesize uploadable = _uploadable;

- (id)initWithDictionary:(NSDictionary *)dic;
{
    self = [super initWithDictionary:dic];
    
    if (self)
    {
        self.albumDescription = [dic objectForKey:@"description"];
        self.link = [dic objectForKey:@"link"];
        self.cover_photo = [dic objectForKey:@"cover_photo"];
        if ([self.cover_photo isKindOfClass:[NSNumber class]])
            self.cover_photo = [(NSNumber *)self.cover_photo stringValue];
        self.location = [dic objectForKey:@"location"];
//        self.privacy = [dic objectForKey:@"privacy"];
        _count = ([dic objectForKey:@"count"]) ? [[dic objectForKey:@"count"] integerValue] : 0;
        self.type = [dic objectForKey:@"type"];
        _uploadable = ([dic objectForKey:@"can_upload"]) ? (BOOL)[dic objectForKey:@"can_upload"] : NO;
        
    }
    
    return self;
}

- (void)dealloc
{
    [_albumDescription release];
    [_link release];
    [_cover_photo release];
    [_type release];
//    [_privacy release];
    [_location release];

    [super dealloc];
}


@end

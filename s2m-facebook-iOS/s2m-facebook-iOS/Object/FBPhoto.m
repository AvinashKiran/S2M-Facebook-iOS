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


#import "FBPhoto.h"
#import "FBTagList.h"
#import "FBImage.h"
@implementation FBPhoto
@synthesize icon = _icon;
@synthesize link = _link;
@synthesize source = _source;
@synthesize picture = _picture;
@synthesize width = _width;
@synthesize height = _height;
@synthesize position = _position;
@synthesize tags = _tags;
@synthesize images = _images;

#pragma mark - Memory Management Methods
- (id)initWithDictionary:(NSDictionary *)dic;
{
    self = [super initWithDictionary:dic];
    
    if (self)
    {
        self.picture = [dic objectForKey:@"picture"];
        self.source = [dic objectForKey:@"source"];
        self.link = [dic objectForKey:@"link"];
        self.icon = [dic objectForKey:@"icon"];
        _width = [dic objectForKey:@"width"] ? [[dic objectForKey:@"width"] integerValue] : -1;
        _height = [dic objectForKey:@"height"] ? [[dic objectForKey:@"height"] integerValue] : -1;        
        _position = [dic objectForKey:@"position"] ? [[dic objectForKey:@"position"] integerValue] : -1;        
        
        NSDictionary *tagDic = [dic objectForKey:@"tags"];
        _tags = [[FBTagList alloc] initWidthDictionary:tagDic];
        
        if ([dic objectForKey:@"images"])
        {
            _images = [[NSMutableArray alloc] init];
            NSArray *imageArray = [dic objectForKey:@"images"];
            
            for (NSDictionary *imageDic in imageArray)
            {
                FBImage *newImage = [[FBImage alloc] init];
                newImage.source = [imageDic objectForKey:@"source"];
                newImage.width = [imageDic objectForKey:@"width"] ? [[imageDic objectForKey:@"width"] integerValue] : -1;
                newImage.height = [imageDic objectForKey:@"height"] ? [[imageDic objectForKey:@"height"] integerValue] : -1;
                [_images addObject:newImage]; 
                [newImage release];
            }
        }        
    }
    
    return self;
}

- (void)dealloc
{
    [_icon release];
    [_link release];
    [_source release];
    [_picture release];
    [_tags release];
    [_images release];

    [super dealloc];
}


@end

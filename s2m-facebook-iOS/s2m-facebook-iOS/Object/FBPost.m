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


#import "FBPost.h"
#import "FBBaseUser.h"
#import "FBTagList.h"

@interface FBPost()
{
@private
    BOOL _isPublished;
}

@end

@implementation FBPost
@synthesize targetUsers = _targetUsers;
@synthesize caption = _caption;
@synthesize message = _message;
@synthesize message_tags = _message_tags;
@synthesize icon = _icon;
@synthesize postDescription = _postDescription;
@synthesize link = _link;
@synthesize source = _source;
@synthesize picture = _picture;
@synthesize postProperties = _postProperties;
@synthesize with_tags = _with_tags;
@synthesize objId = _objId;
@synthesize story = _story;
@synthesize stroy_tags = _story_tags;
//@synthesize application = _application;
@synthesize publish = _isPublished;


#pragma mark - Memory Management Methods
- (id)init
{
    self = [super init];
    _isPublished = NO;
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dic;
{
    self = [super initWithDictionary:dic];
    
    if (self)
    {
        
        NSDictionary *to = [dic objectForKey:@"to"];
        if (to)
        {
            _targetUsers = [[NSMutableArray alloc] init];
            NSArray *userArray = [to objectForKey:@"data"];
            for (NSDictionary *userDic in userArray)
            {
                FBBaseUser *user = [[FBBaseUser alloc] initWithDictionary:userDic];
                [_targetUsers addObject:user];
                [user release];
            }
        }
        
        self.picture = [dic objectForKey:@"picture"];
        self.link = [dic objectForKey:@"link"];
        self.caption = [dic objectForKey:@"caption"];
        self.postDescription = [dic objectForKey:@"description"];
        _icon = [[dic objectForKey:@"icon"] retain];
        self.message = [dic objectForKey:@"message"];
        
        NSDictionary *messageTags = [dic objectForKey:@"message_tags"];
        if (messageTags)
        {
            _message_tags = [[FBTagList alloc] initWidthDictionary:messageTags];
        }
        
        _objId = [[dic objectForKey:@"object_id"] retain];
        if ([self.objId isKindOfClass:[NSNumber class]])
            _objId = [[(NSNumber *)self.objId stringValue] retain];
        
        _isPublished = (BOOL)[dic objectForKey:@"is_published"];
        NSString *newStroy = [dic objectForKey:@"story"];
        _story = [newStroy retain];
        NSDictionary *storyTagsDic = [dic objectForKey:@"story_tags"];
        if (storyTagsDic)
        {
            _story_tags = [[FBTagList alloc] initWidthDictionary:storyTagsDic];
        }
        
        NSDictionary *withTags = [dic objectForKey:@"with_tags"];
        if (withTags)
        {
            _with_tags = [[FBTagList alloc] initWidthDictionary:withTags];
        }
        
        _postProperties = [[dic objectForKey:@"properties"] retain];

    }
    
    return self;
}

- (void)dealloc
{
    [_targetUsers release];
    [_caption release];
    [_message release];
    [_message_tags release];
    [_icon release];
    [_postDescription release];
    [_link release];
    [_source release];
    [_picture release];
    [_postProperties release];
    [_with_tags release];
    [_objId release];
    [_story release];
    [_story_tags release];
//    [_application release];
    
    [super dealloc];
}


@end

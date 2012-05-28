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


#import "FBBaseObject.h"
#import "FBBaseUser.h"
#import "FBLikeList.h"
#import "FBCommentList.h"
#import "FBPlace.h"

@interface FBBaseObject ()
{
    
}
@end

@implementation FBBaseObject
@synthesize owner = _owner;
@synthesize commentable = _commentable;
@synthesize likable = _likable;
//@synthesize deletable = _deletable;
@synthesize modifiable = _modifiable;
@synthesize comments = _comments;
@synthesize likes = _likes;
@synthesize place = _place;
@synthesize created_time = _created_time;
@synthesize updated_time = _updated_time;

#pragma mark - Memory Management

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _commentable = NO;
        _likable = NO;
    }
    
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dic;
{
    self = [super initWithDictionary:dic];
    
    if (self && dic)
    {
        _commentable = NO;
        _likable = NO;
        // do something
        // let's parse basic.
        
        NSDictionary *from = [dic objectForKey:@"from"];
        if (from)
        {
            FBBaseUser *user = [[FBBaseUser alloc] initWithDictionary:from];
            _owner = user;
        }
        
        NSDictionary *likeDic = [dic objectForKey:@"likes"];
        if (likeDic && [likeDic isKindOfClass:[NSDictionary class]])
        {
            FBLikeList *likeList = [[FBLikeList alloc] initWidthDictionary:likeDic];
            _likes = likeList;
        }
        
        NSDictionary *commentDic = [dic objectForKey:@"comments"];
        if (commentDic)
        {
            FBCommentList *commentList = [[FBCommentList alloc] initWidthDictionary:commentDic];
            _comments = commentList;
        }
        
        NSString *creationTime = [dic objectForKey:@"created_time"];
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
        NSString *modificationTime = [dic objectForKey:@"updated_time"];
        if (modificationTime)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeStyle:NSDateFormatterFullStyle];
            [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
            _updated_time = [formatter dateFromString:(NSString *)creationTime];
            [_updated_time retain];
            [formatter release];
        }
        
        NSArray *actions = [dic objectForKey:@"actions"];
        if (actions)
        {
            for (NSDictionary *action in actions)
            {
                NSString *detailAction = [action objectForKey:@"name"];
                if (!detailAction)
                    continue;
                if ([detailAction isEqualToString:@"Like"])
                    _likable = YES;
                else if ([detailAction isEqualToString:@"Comment"])
                    _commentable = YES;
                else
                {
                    NSLog(@"unkown action : %@", detailAction);
                }
            }
        }
        
        NSDictionary *placeDic = [dic objectForKey:@"place"];
        if (placeDic)
        {
            _place = [[FBPlace alloc] initWithDictionary:placeDic];
        }
    }
    
    return self;
}
- (void)dealloc
{
    [_place release];
    [_updated_time release];
    [_created_time release];
    [_owner release];
    [_comments release];
    [_likes release];
    [super dealloc];
}


- (NSMutableDictionary *)properties
{
    return nil;
}

@end

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

#import "PostViewController.h"
#import "AppDelegate.h"
#import "CommentListViewController.h"

// tag 0 from, 1 to, 2 like, 3 unlike, 4 comment, view likes 5, view comments 6
@interface ItemWrapper : NSObject

@property (nonatomic, retain) NSString      *text;
@property (nonatomic, retain) NSString      *subText;
@property (nonatomic, retain) UIImage       *image;
@property (nonatomic, assign) NSInteger     tag;
@end

@implementation ItemWrapper
@synthesize text = _text;
@synthesize subText = _subText;
@synthesize image = _image;
@synthesize tag = _tag;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.tag = -1;
        _image = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_text release];
    [_subText release];
    [_image release];
    [super dealloc];
}

@end

@interface PostViewController() <FBConnectorDelegate>{
    FBPost          *_currentPost;
    BOOL            _userLiked;
    NSMutableArray  *_postItems;
    id              _fromImageRequestId;
    id              _toImageRequestId;
}


@end

@implementation PostViewController
@synthesize currentPost = _currentPost;
@synthesize currentUser = _currentUser;
@synthesize postItems = _postItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    if (_fromImageRequestId)
        [[FBConnector fbConnectorInstance] removeDeletegate:self withRequestId:_fromImageRequestId];
    if (_toImageRequestId)
        [[FBConnector fbConnectorInstance] removeDeletegate:self withRequestId:_toImageRequestId];
    
    [_currentUser release];
    [_currentPost release];
    [_postItems release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _postItems = [[NSMutableArray alloc] init];
    
    self.currentUser = (FBUser *)[FBUser currentUser];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.currentPost.message;
    
    if (self.currentPost.owner)
    {
        ItemWrapper *ownerItem = [[ItemWrapper alloc] init];
        ownerItem.text = self.currentPost.owner.name;
        ownerItem.subText = @"from";
        ownerItem.tag = 0;
        [_postItems addObject:ownerItem];
        [ownerItem release];
        
        _fromImageRequestId = [[FBConnector fbConnectorInstance] 
                               downloadImage:self.currentPost.owner
                               imageType:FBImageType_square
                               withDelegate:self];
    }
    
    if (self.currentPost.targetUsers)
    {
        BOOL isFirst = YES;
        for (FBBaseUser *targetUser in self.currentPost.targetUsers)
        {
            ItemWrapper *newItem = [[ItemWrapper alloc] init];
            newItem.text = targetUser.name;
            newItem.subText = @"to";
            if (isFirst)
                _toImageRequestId = [[FBConnector fbConnectorInstance]
                                       downloadImage:targetUser
                                       imageType:FBImageType_square
                                       withDelegate:self];
            newItem.tag = isFirst ? 1 : -1;
            isFirst = NO;
            [_postItems addObject:newItem];
            [newItem release];
        }
    }
    
    if (self.currentPost.message)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = self.currentPost.message;
        newItem.subText = @"message";
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.link)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = self.currentPost.name;
        newItem.subText = self.currentPost.link;
        if (self.currentPost.picture)
            newItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentPost.picture]]];
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.postDescription)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = self.currentPost.postDescription;
        newItem.subText = @"description";
        if (self.currentPost.picture)
            newItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentPost.source]]];
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.caption)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = self.currentPost.caption;
        newItem.subText = @"caption";
        [_postItems addObject:newItem];
        [newItem release];
    }

    if (self.currentPost.story)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = [self.currentPost.story stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"-"];
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.place)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.subText = [NSString stringWithFormat:@"at %@", self.currentPost.place.name];
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.with_tags && [self.currentPost.with_tags count] > 0)
    {
        NSMutableString *withString = [[NSMutableString alloc] init];
        for (FBTag *tag in self.currentPost.with_tags.objects)
        {
            [withString appendFormat:@"%@, ",tag.name];
        }
        if ([withString hasSuffix:@", "])
        {
            [withString deleteCharactersInRange:NSMakeRange([withString length] - 3,2)];
        }
        
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = withString;
        newItem.subText = @"with";
        [_postItems addObject:newItem];
        [newItem release];
        [withString release];
    }
    
    NSMutableString *likers = [[NSMutableString alloc] init];
    for (FBBaseUser *likeObj in self.currentPost.likes.objects)
    {
        if ([likeObj.uid isEqualToString:self.currentUser.uid])
        {
            _userLiked = YES;
        }
        [likers appendFormat:@", %@", likeObj.name];
    }
    
    if (self.currentPost.likes.totalCount > 0)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = [NSString stringWithFormat:@"likes : %d",
                        self.currentPost.likes.totalCount > 0 ? self.currentPost.likes.totalCount : 0];
        if ([likers length] > 0)
        {
            newItem.subText = likers;
        }
        newItem.tag = 5;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.comments.totalCount > 0)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = [NSString stringWithFormat:@"comments : %d",
                        self.currentPost.comments.totalCount > 0 ? self.currentPost.comments.totalCount : 0];
        newItem.tag = 6;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.likable)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = _userLiked ? @"unlike" : @"like";
        newItem.tag = _userLiked ? 3 : 2;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if (self.currentPost.commentable)
    {
        ItemWrapper *newItem = [[ItemWrapper alloc] init];
        newItem.text = @"leave comment";
        newItem.tag = 4;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    [likers release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_postItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    ItemWrapper *item = [_postItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.text;
    cell.detailTextLabel.text = item.subText;
    cell.imageView.image = item.image;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */    
    
    ItemWrapper *item = [_postItems objectAtIndex:indexPath.row];
    
    switch (item.tag) {
        case 2:
            [[FBConnector fbConnectorInstance] addLikeTo:self.currentPost withDelegate:self];
            break;
        case 3:
            if (_userLiked)
                [[FBConnector fbConnectorInstance] removeLike:self.currentPost withDelegate:self];
            break;
        case 4:
        {
            FBComment *newComment = [[FBComment alloc] init];
            newComment.message = @"TestComment";
            [[FBConnector fbConnectorInstance] postComment:newComment to:self.currentPost withDelegate:self];
            [newComment release];
        }
            break;
        case 5:
            
            break;
        case 6:
        {
            
            CommentListViewController *commentView = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
            commentView.currentObj = self.currentPost;
            [self.navigationController pushViewController:commentView animated:YES];
            [commentView release];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - IBActions

-(IBAction)showLikes:(id)sender
{
    
}

-(IBAction)showComments:(id)sender
{
    
}

-(IBAction)doLike:(id)sender
{
    
}

-(IBAction)leaveComment:(id)sender
{
    
}

#pragma mark - TICFBConnectorDelegate Methods

- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    NSLog(@"error : %@", error);
}

- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{
    if (requestId ==_fromImageRequestId)
    {
        _fromImageRequestId= nil;
        for (ItemWrapper *item in _postItems)
        {
            if (item.tag == 0)
            {
                item.image = image;
                [self.tableView reloadData];
                return;
            }
        }
    }
    
    if (requestId ==_toImageRequestId)
    {
        _toImageRequestId= nil;
        for (ItemWrapper *item in _postItems)
        {
            if (item.tag == 1)
            {
                item.image = image;
                [self.tableView reloadData];
                return;
            }
        }
    }
}

- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
    UIImage *dummyImage = [[[UIImage alloc] init] autorelease];
    [self didDownloadImage:requestId withImageData:dummyImage];
}


@end

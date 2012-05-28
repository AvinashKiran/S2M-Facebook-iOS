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

#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "CommentListViewController.h"

// tag 0 from, 1 normalImage, 2 like, 3 unlike, 4 comment, view likes 5, view comments 6
@interface PhotoItemWrapper : NSObject

@property (nonatomic, retain) NSString      *text;
@property (nonatomic, retain) NSString      *subText;
@property (nonatomic, retain) UIImage       *image;
@property (nonatomic, assign) NSInteger     tag;
@end

@implementation PhotoItemWrapper
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

@interface PhotoViewController() <FBConnectorDelegate>{
    FBPhoto          *_currentPhoto;
    BOOL            _userLiked;
    NSMutableArray  *_postItems;
    id              _fromImageRequestId;
    id              _toImageRequestId;
}

@end

@implementation PhotoViewController
@synthesize currentPhoto = _currentPhoto;
@synthesize currentUser = _currentUser;
@synthesize postItems = _postItems;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    [_currentPhoto release];
    [_postItems release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _postItems = [[NSMutableArray alloc] init];
    
    self.currentUser = (FBBaseUser *)[AppDelegate currenUserInstance];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = self.currentPhoto.name;

    if (self.currentPhoto.source)
    {
        PhotoItemWrapper *newItem = [[PhotoItemWrapper alloc] init];
//        newItem.text = self.currentPhoto.source;
//        newItem.subText = @"source image";
        newItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentPhoto.source]]];
        [_postItems addObject:newItem];
        newItem.tag = 1;
        [newItem release];
    }

    
    if (self.currentPhoto.owner)
    {
        PhotoItemWrapper *ownerItem = [[PhotoItemWrapper alloc] init];
        ownerItem.text = self.currentPhoto.owner.name;
        ownerItem.subText = @"from";
        ownerItem.tag = 0;
        [_postItems addObject:ownerItem];
        [ownerItem release];
        
        _fromImageRequestId = [[FBConnector fbConnectorInstance] 
                               downloadImage:self.currentPhoto.owner
                               imageType:FBImageType_square
                               withDelegate:self];
    }

    if (self.currentPhoto.tags && [self.currentPhoto.tags count] > 0)
    {
        NSMutableString *withString = [[NSMutableString alloc] init];
        for (FBTag *tag in self.currentPhoto.tags.objects)
        {
            [withString appendFormat:@"%@, ",tag.name];
        }
        if ([withString hasSuffix:@", "])
        {
            [withString deleteCharactersInRange:NSMakeRange([withString length] - 3,2)];
        }
        
        PhotoItemWrapper *newItem = [[PhotoItemWrapper alloc] init];
        newItem.text = withString;
        newItem.subText = @"with";
        [_postItems addObject:newItem];
        [newItem release];
        [withString release];
    }
    
    if (self.currentPhoto.place)
    {
        PhotoItemWrapper *newItem = [[PhotoItemWrapper alloc] init];
        newItem.subText = [NSString stringWithFormat:@"at %@", self.currentPhoto.place.name];
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    NSMutableString *likers = [[NSMutableString alloc] init];
    for (FBBaseUser *likeObj in self.currentPhoto.likes.objects)
    {
        if ([likeObj.uid isEqualToString:self.currentUser.uid])
        {
            _userLiked = YES;
        }
        [likers appendFormat:@", %@", likeObj.name];
    }
    
    if ([self.currentPhoto.likes count] > 0)
    {
        PhotoItemWrapper *newItem = [[PhotoItemWrapper alloc] init];
        newItem.text = [NSString stringWithFormat:@"likes : %d",
                        self.currentPhoto.likes.totalCount > 0 ? self.currentPhoto.likes.totalCount : [self.currentPhoto.likes.objects count]];
        
        if ([likers length] > 0)
        {
            newItem.subText = likers;
        }

        newItem.tag = 5;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    if ([self.currentPhoto.comments count] > 0)
    {
        PhotoItemWrapper *newItem = [[PhotoItemWrapper alloc] init];
        newItem.text = [NSString stringWithFormat:@"comments : %d",
                        self.currentPhoto.comments.totalCount > 0 ? self.currentPhoto.comments.totalCount : [self.currentPhoto.comments.objects count]];
        newItem.tag = 6;
        [_postItems addObject:newItem];
        [newItem release];
    }
    
    PhotoItemWrapper *likeItem = [[PhotoItemWrapper alloc] init];
    likeItem.text = _userLiked ? @"unlike" : @"like";
    likeItem.tag = _userLiked ? 3 : 2;
    [_postItems addObject:likeItem];
    [likeItem release];

    PhotoItemWrapper *commentItem = [[PhotoItemWrapper alloc] init];
    commentItem.text = @"leave comment";
    commentItem.tag = 4;
    [_postItems addObject:commentItem];
    [commentItem release];
    [likers release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoItemWrapper *item = [_postItems objectAtIndex:indexPath.row];
    if (item.tag == 1)
        return 300;
    return 40;
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
    PhotoItemWrapper *item = [_postItems objectAtIndex:indexPath.row];
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
    
    PhotoItemWrapper *item = [_postItems objectAtIndex:indexPath.row];
    
    switch (item.tag) {
        case 2:
            [[FBConnector fbConnectorInstance] addLikeTo:self.currentPhoto withDelegate:self];
            break;
        case 3:
            if (_userLiked)
                [[FBConnector fbConnectorInstance] removeLike:self.currentPhoto withDelegate:self];
            break;
        case 4:
        {
            FBComment *newComment = [[FBComment alloc] init];
            newComment.message = @"TestComment";
            [[FBConnector fbConnectorInstance] postComment:newComment to:self.currentPhoto withDelegate:self];
            [newComment release];
        }
            break;
        case 5:
            
            break;
        case 6:
        {
            
            CommentListViewController *commentView = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
            commentView.currentObj = self.currentPhoto;
            [self.navigationController pushViewController:commentView animated:YES];
            [commentView release];
        }
            break;
            
        default:
            break;
    }
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
        for (PhotoItemWrapper *item in _postItems)
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
        for (PhotoItemWrapper *item in _postItems)
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

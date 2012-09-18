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

#import "ViewController.h"
#import "AppDelegate.h"
#import "FriendListViewController.h"
#import "FeedListViewController.h"


#import "AlbumListViewController.h"


static NSInteger currentFriendIndex = 0;

@implementation ViewController
@synthesize friends = _friends;
@synthesize feeds = _feeds;
@synthesize comments = _comments;
@synthesize likes = _likes;
@synthesize photosInAlbum = _photosInAlbum;
@synthesize photos = _photos;
@synthesize useDelegate;
@synthesize imageView;
@synthesize currentUser = _currentUser;

- (void)dealloc
{
    [_friends release];
    [_feeds release];
    [_comments release];
    [_likes release];
    [_photos release];
    [_photosInAlbum release];
    [_currentUser release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _friends = [[NSMutableArray alloc] init];
    _feeds = [[NSMutableArray alloc] init];
    _comments = [[NSMutableArray alloc] init];
    _likes = [[NSMutableArray alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _photosInAlbum = [[NSMutableArray alloc] init];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - IBAction Methods


- (IBAction)tryLogout:(id)sender
{
    [[FBConnector fbConnectorInstance] logoutWithDelegate:([self.useDelegate isOn] ? nil : self)];
}

- (IBAction)tryGetFriends:(id)sender
{   
    FriendListViewController *newFriendListViewController = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
    newFriendListViewController.currentUser = self.currentUser;
    UINavigationController *naviController= self.navigationController;
    [naviController pushViewController:newFriendListViewController animated:YES];
    [newFriendListViewController release];
}

- (IBAction)tryPost:(id)sender
{
    FBPost *newPost = [[FBPost alloc] init];
    newPost.message = @"이제 곳 봄이 오는구나. - sinnerschrader mobile";
    [[FBConnector fbConnectorInstance] postToWallOfUser:nil withPost:newPost useDialog:YES withDelegate:([self.useDelegate isOn] ? nil : self)];
    
    [newPost release];
}

- (IBAction)getFeed:(id)sender
{
    FeedListViewController *newFeedListViewController = [[FeedListViewController alloc] initWithNibName:@"FeedListViewController" bundle:nil];
    newFeedListViewController.currentUser = self.currentUser;
    UINavigationController *naviController= self.navigationController;
    [naviController pushViewController:newFeedListViewController animated:YES];
    [newFeedListViewController release];
    //    [_fbConnector feedsOfUser:self.currentUser offset:0 limit:25 withDelegate:self];
}
- (IBAction)getAlbums:(id)sender
{
    AlbumListViewController *newAlbumListView = [[AlbumListViewController alloc] initWithNibName:@"AlbumListViewController" bundle:nil];
    newAlbumListView.currentUser = self.currentUser;
    UINavigationController *naviController= self.navigationController;
    [naviController pushViewController:newAlbumListView animated:YES];
    [newAlbumListView release];
}

- (IBAction)appUsers:(id)sender
{
    [[FBConnector fbConnectorInstance] friendsUsingApplication:self];
}

- (IBAction)getPhotos:(id)sender
{
    [[FBConnector fbConnectorInstance] photosOfUser:self.currentUser offset:0 limit:25 withDelegate:self];
}

- (IBAction)getLikes:(id)sender
{
    [[FBConnector fbConnectorInstance] likesOfUser:self.currentUser offset:0 limit:25 withDelegate:self];
}

- (IBAction)tryPostToFriend:(id)sender
{
    FBPost *newPost = [[FBPost alloc] init];
    newPost.message = @"이제 곳 봄이 오는구나. - sinnerschrader mobile";
    newPost.link = @"https://lh4.googleusercontent.com/-ZSDbzBBYFaY/S9kmvV_lQdI/AAAAAAAABz0/AgvcYstSFU4/s512/DSC_0385.JPG";
    newPost.name = @"봄이다....";
    newPost.caption = @"I Luv Her.";
    
    [[FBConnector fbConnectorInstance] postToWallOfUser:self.currentUser withPost:newPost useDialog:YES withDelegate:([self.useDelegate isOn] ? nil : self)];
    [newPost release];
}

- (IBAction)uploadPhoto:(id)sender
{
    // Download a sample photo
    NSURL *url = [NSURL URLWithString:@"https://lh4.googleusercontent.com/-ZSDbzBBYFaY/S9kmvV_lQdI/AAAAAAAABz0/AgvcYstSFU4/s512/DSC_0385.JPG"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img  = [[[UIImage alloc] initWithData:data] autorelease];
    [[FBConnector fbConnectorInstance] uploadPhoto:img withDelegate:([self.useDelegate isOn] ? nil : self)];
}

- (IBAction)getImageOfFriends:(id)sender
{
    currentFriendIndex = 0;
    [[FBConnector fbConnectorInstance] downloadImage:[_friends objectAtIndex:currentFriendIndex] imageType:FBImageType_square withDelegate:self];
}


#pragma mark - TICFBSessionDelegate Methods

- (void)didLogin:(id)requestId
{
    
}

- (void)didLogout:(id)requestId
{
    
}

- (void)userPermissionUpdated:(id)requestId
{
    
}

- (void)didGetFriendsUsingApplication:(id)requestId withArray:(NSArray *)userIds
{
    NSLog(@"friends using app : %@", userIds);
}

- (void)didGetPhotosOfUser:(id)requestId withList:(FBUserPhotoList *)photos
{
    [_photos addObjectsFromArray:photos.objects];
    
    if ([photos hasMore])
    {
        [[FBConnector fbConnectorInstance] photosOfUser:self.currentUser offset:photos.offset limit:photos.limit withDelegate:self];
        return;
    }
    
    for (FBPhoto *photo in _photos)
    {
        NSLog(@"name : %@, from : %@, description : %@, creation time: %@,  ", photo.name, photo.owner.name, photo.description, photo.created_time);
    }
}

- (void)didGetComments:(id)requestId withList:(FBCommentList *)comments
{
    [_comments addObjectsFromArray:comments.objects];
    
    if ([comments hasMore])
    {
        [[FBConnector fbConnectorInstance] commentsOfObject:[_feeds objectAtIndex:15] offset:comments.offset limit:comments.limit withDelegate:self];
        return;
    }
    
    for (FBComment *commt in _comments)
    {
        NSLog(@"name : %@, from : %@, message : %@, creation time: %@,  ", commt.name, commt.owner.name, commt.message, commt.created_time);
    }
}

- (void)didGetLikes:(id)requestId withList:(FBLikeList *)likes
{
    [_likes addObjectsFromArray:likes.objects];
    
    if ([likes hasMore])
    {
        [[FBConnector fbConnectorInstance] likesOfUser:self.currentUser offset:likes.offset limit:likes.limit withDelegate:self];
        return;
    }
    
    for (FBBaseUser *like in _likes)
    {
        NSLog(@"name : %@, id : %@ ", like.name, like.uid);
    }
    
}

- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{
    [self.imageView setImage:image];
    currentFriendIndex++;
    if (currentFriendIndex >= [_friends count])
        return;
    [[FBConnector fbConnectorInstance] downloadImage:[_friends objectAtIndex:currentFriendIndex] imageType:FBImageType_square withDelegate:self];
}

- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    NSLog(@"request success");
    NSLog(@"resutl : %@", result);    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    NSLog(@"request failed : %@", error);
}

@end

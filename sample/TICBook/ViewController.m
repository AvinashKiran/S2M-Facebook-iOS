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
@synthesize logInButton;
@synthesize currentUser = _currentUser;
@synthesize fbConnector = _fbConnector;

- (void)dealloc
{
    [_friends release];
    [_feeds release];
    [_comments release];
    [_likes release];
    [_photos release];
    [_photosInAlbum release];
    [_currentUser release];
    [_fbConnector release];
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
    
    _fbConnector = [[FBConnector alloc] initWithAppId:kAppId andDelegate:self];
    _fbConnector.permissions = [NSArray arrayWithObjects:@"offline_access", @"user_about_me", @"user_photos", @"user_status", @"publish_actions", @"publish_stream", @"read_stream", nil];
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
    if ([_fbConnector isSessionValid])
    {
        [_fbConnector logoutWithDelegate:nil];
        [self.logInButton setTitle:@"login" forState:UIControlStateNormal];
        self.imageView.image = nil;
    }
    else
    {
        [_fbConnector loginWithDelegate:self useDialog:YES];
    }
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
    newPost.message = @"Hi there!!";
    newPost.name = @"The Best Mobile";
    newPost.caption = @"Sinnerschrader Mobile GmbH";
    newPost.link = @"http://www.sinnerschrader-mobile.com";
    [[FBConnector fbConnectorInstance] postToWallOfUser:nil withPost:newPost useDialog:NO withDelegate:self];
    
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
    newPost.link = @"http://www.sinnerschrader-mobile.com";
    newPost.name = @"SinnerSchrader Mobile GmbH";
    newPost.caption = @"The Best experience.";
    
    [[FBConnector fbConnectorInstance] postToWallOfUser:self.currentUser withPost:newPost useDialog:YES withDelegate:self];
    [newPost release];
}

- (IBAction)uploadPhoto:(id)sender
{
    // Download a sample photo
    NSURL *url = [NSURL URLWithString:@"https://lh4.googleusercontent.com/-ZSDbzBBYFaY/S9kmvV_lQdI/AAAAAAAABz0/AgvcYstSFU4/s512/DSC_0385.JPG"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img  = [[[UIImage alloc] initWithData:data] autorelease];
    [[FBConnector fbConnectorInstance] uploadPhoto:img withDelegate:self];
}

- (IBAction)getImageOfFriends:(id)sender
{
    currentFriendIndex = 0;
    [[FBConnector fbConnectorInstance] downloadImage:[_friends objectAtIndex:currentFriendIndex] imageType:FBImageType_square withDelegate:self];
}


#pragma mark - TICFBSessionDelegate Methods

#pragma mark - TICFBSessionDelegate Methods

- (void)didLogin:(id)requestId
{
    NSLog(@"did Login");
    [[FBConnector fbConnectorInstance] currentUserInfoWithDelegate:self];
    [self.logInButton setTitle:@"logout" forState:UIControlStateNormal];
}

- (void)didLogout:(id)requestId
{
    [self.logInButton setTitle:@"login" forState:UIControlStateNormal];
    self.imageView.image = nil;
}

- (void)didGetUserInfo:(id)requestId withUser:(FBUser *)user
{
    NSLog(@"did get user  success");
    self.currentUser = user;
    [[FBConnector fbConnectorInstance] downloadImage:user imageType:FBImageType_normal withDelegate:self];
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

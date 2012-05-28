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
#import <UIKit/UIKit.h>

#import <S2M-Facebook/FBConnector.h>

@interface ViewController : UIViewController <FBConnectorDelegate>

@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) NSMutableArray *feeds;
@property (nonatomic, retain) NSMutableArray *likes;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) NSMutableArray *photosInAlbum;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, assign) IBOutlet UISwitch *useDelegate;
@property (nonatomic, assign) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) FBUser    *currentUser;


- (IBAction)tryLogout:(id)sender;
- (IBAction)tryGetFriends:(id)sender;
- (IBAction)tryPost:(id)sender;
- (IBAction)getFeed:(id)sender;
- (IBAction)tryPostToFriend:(id)sender;
- (IBAction)uploadPhoto:(id)sender;
- (IBAction)getPhotos:(id)sender;
- (IBAction)getAlbums:(id)sender;
- (IBAction)appUsers:(id)sender;
- (IBAction)getLikes:(id)sender;

@end

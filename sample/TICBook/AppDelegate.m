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

#import "AppDelegate.h"

#import "ViewController.h"
#import <S2M-Facebook/FBConnector.h>

static NSString* kAppId = @"210849718975311";

static FBUser *userInfoInstance = nil;

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize fbConnector = _fbConnector;
@synthesize currentUser = _currentUser;


- (void)dealloc
{
    [_fbConnector release];
    [_viewController release];
    [_window release];
    [super dealloc];
}

+ (FBUser *)currenUserInstance
{
    return userInfoInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    _fbConnector = [[FBConnector alloc] initWithAppId:kAppId andDelegate:self.viewController];
    
    self.window.rootViewController = naviController;
    [self.window makeKeyAndVisible];
    [naviController release];
    
    // Check App ID:
    // This is really a warning for the developer, this should not
    // happen in a completed app
    if (!kAppId) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"Setup Error" 
                                  message:@"Missing app ID. You cannot run the app until you provide this in the code." 
                                  delegate:self 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil, 
                                  nil];
        [alertView show];
        [alertView release];
        return YES;
    } else {
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kAppId];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] && 
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] && 
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:@"Setup Error" 
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist." 
                                      delegate:self 
                                      cancelButtonTitle:@"OK" 
                                      otherButtonTitles:nil, 
                                      nil];
            [alertView show];
            [alertView release];
            return YES;
        }
    }
    
    [_fbConnector loginWithDelegate:self useDialog:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.fbConnector handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.fbConnector handleOpenURL:url];
}

#pragma mark - TICFBSessionDelegate Methods

- (void)didLogin:(id)requestId
{
    NSLog(@"did Login");
    [[FBConnector fbConnectorInstance] currentUserInfoWithDelegate:self];
}


- (void)didGetUserInfo:(id)requestId withUser:(FBUser *)user
{
    NSLog(@"did get user  success");
    self.currentUser = user;
    userInfoInstance = user;
    self.viewController.currentUser = user;
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

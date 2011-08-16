# The SoundCloud UI for Cocoa

So you want to share your tracks in your iOS Application to SoundCloud? With this project you only need a few lines of code for doing that.

This guide assumes a few things:

* You are using Xcode 4
* You are using Git.

## Setup

We're taking a fresh new iOS Project as an example. Integration into an existing project and/or a Desktop project should be similar.

### In the Terminal

1. Go to your project directory.

2. Add SoundCloudAPI, SoundCloudUI and JSONKit as a Git Submodules

		git submodule add git://github.com/soundcloud/CocoaSoundCloudAPI.git SoundCloudAPI
		git submodule add git://github.com/soundcloud/CocoaSoundCloudUI.git SoundCloudUI
		git submodule add https://github.com/johnezang/JSONKit.git JSONKit
		
3. Update the Submodules

		git submodule update --init --recursive

### In Xcode

1. Drag the `SoundCloudAPI.xcodeproj` and `SoundCloudUI.xcodeproj` files below your project file. If it asks you to save this as a Workspace, say yes. For projects in the _root_ hierarchy of a workspace, Xcode ensures "implicit dependencies" between them. That's a good thing.

2. Add references to the files `JSONKit.h` and `JSONKit.m` from the folder `JSONKit` to your project.

3. To be able to find the Headers, you still need to add `SoundCloudAPI/**` and `SoundCloudUI/**` to the `Header Search Path` of the main project.

4. Now the Target needs to know about the new libraries it should link against. So in the _Project_, select the _Target_, and in _Build Phases_ go to the _Link Binary with Libraries_ section. Add the following:

    * `libSoundCloudAPI.a`
    * `libSoundCloudUI.a`
    * `libOAuth2Client.a`
    * `QuartzCore.framework`
    * `AddressBook.framework`
    * `AddressBookUI.framework`
    * `CoreLocation.framework`
    * `Security.framework`
    * `CoreGraphics.framework`

5. Next step is to make sure that the Linker finds everything it needs: So go to the Build settings of the project and add the following to *Other Linker Flags*
    
        -all_load -ObjC

6. We need a few graphics for the Login Screen: Please move the SoundCloud.bundle from the SoundCloudUI directory to your Resources.

Yay, done! Congrats! Everything is set up, and you can start using it.

## Usage

### The Basics

You only need to `#import "SCUI.h"` to include the UI headers. The objects you should be most interested in are `SCSoundCloud` for configuration and `SCShareViewController` for sharing a track to SoundCloud.


### Configure your App

To configure you App you have to set your App's _Client ID_, it's _Client Secret_ and it's _Redirect URL_. The best way to do this is in the `initialize` class method in your app delegate.

    + (void)initialize;
    {
        [SCSoundCloud  setClientID:@"<Client ID>"
                            secret:@"<Client Secret>"
                       redirectURL:[NSURL URLWithString:@"<Redirect URL>"]];
    }

You will get your App's _Client ID_, it's _Client Secret_ from [the SoundCloud page where you registered your App](http://soundcloud.com/you/apps). There you should register your App with it's name and a _Redirect URL_. That _Redirect URL_ should comply to a protocol that is handled by your app. See [this page](http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html) on how to set up the protocol in your App. For the curious: in the wrapper we're using _Redirect URL_ instead of _Redirect URI_ because the underlying type is of `NSURL`.


### Sharing a track

To share a track you just have to create a `SCShareViewController` with the URL to the file you want to share and present it on the current view controller. After a successful upload, the track info can be accessed in the completion handler. 

    - (void)upload;
    {
        NSURL *trackURL = // ... an URL to the audio file
        
        SCShareViewController *shareViewController = [SCShareViewController shareViewControllerWithFileURL:trackURL
                                                                                         completionHandler:^(BOOL canceled, NSDictionary *trackInfo){
                                                                                             if (canceled) {
                                                                                                 NSLog(@"Sharing sound with Soundcloud canceled.");
                                                                                             } else {
                                                                                                 NSLog(@"Uploaded track: %@", trackInfo);
                                                                                             }
                                                                                         }];
        
        // If your app is a registered foursquare app, you can set the client id and secret.
        // The user will then see a place picker where a location can be selected.
        // If you don't set them, the location is set via a plain text filed.
        
        [shareViewController setFoursquareClientID:@"<>"
                                      clientSecret:@"<>"];
        
        [self presentModalViewController:shareViewController animated:YES];
    }

Optionally you can preset set the *title*, a *cover image*, a *creation date* and a flag indicating if the track should be public or private. Look at `SCShareViewController.h` for details.


## Thats it!

If the only thing you want to do is uploading a track to SoundCLoud, you are done. But you can also access the SoundCloud API via this project. The details are explained in the documentation of the subproject [SoundCloudAPI]().

## Using the SCLoginViewController

If you don't want to share a track to SoundCloud, but want to take advantage of the SoundCloud UI you can use `SCLoginViewController`.

Assuming your app isn't authenticated (`[SCSoundCloud account] == nil`) or you want to relogin you can use the following example to present a login screen.

    @implementation YourViewController
    
    // ...
    
    - (void)login;
    {
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            SCLoginViewController *loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                                                 completionHandler:^(BOOL canceled, NSError *error){
                                                                                                     
                                                                                                     }];
            [self presentModalViewController:loginViewController animated:YES];
        }];
    }
    
    @end



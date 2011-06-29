//
//  main.m
//  vitunes
//
//  Created by Daniel Choi on 6/29/11.
//  Copyright 2011 Software by Daniel Choi. All rights reserved.
//
#import "iTunes.h"
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    
    NSString *query;
    
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    if ([args count] > 1) 
        query = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
    else
        query = @"Bach";
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesSource *library = [[iTunes sources] objectWithName:@"Library"];
    iTunesPlaylist *music = [[library playlists] objectWithName:@"Music"];
    SBElementArray *tracks = [music searchFor:query only:iTunesESrAAll];
    NSLog(@"%@", [tracks class]);    
    NSArray *trackNames = [tracks arrayByApplyingSelector:@selector(name)];
    
    NSLog(@"%@", trackNames);


    [pool drain];
    return 0;
}


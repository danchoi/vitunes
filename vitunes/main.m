//
//  main.m
//  vitunes
//
//  Created by Daniel Choi on 6/29/11.
//  Copyright 2011 Software by Daniel Choi. All rights reserved.
//
#import "iTunes.h"
#import <Foundation/Foundation.h>


// functions
NSString *format(iTunesTrack *track) {
  return [NSString stringWithFormat: @"%@ %@ %@ %@ %@ %@", 
          track.databaseID,
          track.name,
          track.album,
          track.artist,
          track.year,
          track.genre];
          
}

static iTunesPlaylist *music;

void search(NSString *query) {
    SBElementArray *tracks = [music searchFor:query only:iTunesESrAAll];
    NSLog(@"%@", [tracks class]);    
    NSMutableArray *container = [NSMutableArray array];
    for (iTunesTrack *track in tracks) {
      //printf("%s\n", [format(track) cStringUsingEncoding: NSUTF8StringEncoding]);

      /*
        NSString *r =  [NSString stringWithFormat: @"%@ %@ %@ %@ %@ %@", 
                track.databaseID,
                track.name,
                track.album,
                track.artist,
                track.year,
                track.genre];
                */
      printf("%s\n", [[track name] cStringUsingEncoding: NSUTF8StringEncoding]);
[container addObject:[track genre]];
    }
    NSLog(@"%@", container);

}

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
    music = [[library playlists] objectWithName:@"Music"];
    search(query);


    [pool drain];
    return 0;
}


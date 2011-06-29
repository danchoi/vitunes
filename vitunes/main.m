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
  NSString *name = track.name;
  NSString *album = track.album;
  NSInteger databaseID = track.databaseID;
  NSString *artist = track.artist;
  NSInteger year = track.year;
  NSString *genre = track.genre;
  return [NSString stringWithFormat: @"%d %@ %@ %@ (%d) %@ \n", 
          databaseID,
          name,
          album,
          artist,
          year,
          genre];
          
}

static iTunesPlaylist *music;

void search(NSString *query) {
    SBElementArray *tracks = [music searchFor:query only:iTunesESrAAll];
    NSLog(@"%@", [tracks class]);    
    for (iTunesTrack *track in tracks) {
      printf("%s\n", [format(track) cStringUsingEncoding: NSUTF8StringEncoding]);
    }
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


//
//  main.m
//  vitunes
//
//  Created by Daniel Choi on 6/29/11.
//  Copyright 2011 Software by Daniel Choi. All rights reserved.
//
#import "iTunes.h"
#import <Foundation/Foundation.h>

// because Cocoa won't let me put a category directly on iTunesTrack.
@interface SBObject (ViTunes) 
- (NSString *)test;
@end
@implementation SBObject (ViTunes) 
- (NSString *)test {
  NSString *name = [self valueForKey:@"name"];
  NSString *album = [self valueForKey:@"album"];
  id databaseID = [self valueForKey:@"databaseID"];
  NSString *artist = [self valueForKey:@"artist"];
  id year = [self valueForKey:@"year"];
  NSString *genre = [self valueForKey:@"genre"];
  return [NSString stringWithFormat: @"%@ %@ %@ %@ (%@) %@ \n", 
          databaseID,
          name,
          album,
          artist,
          year,
          genre];

};
@end

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

    //NSArray *strings = [tracks arrayByApplyingSelector:@selector(test)];
    //NSLog(@"result %@", strings);
    //return;
    for (iTunesTrack *track in tracks) {
      //printf("%s\n", [format(track) cStringUsingEncoding: NSUTF8StringEncoding]);
      //printf("%s\n", [[track test] cStringUsingEncoding: NSUTF8StringEncoding]);
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


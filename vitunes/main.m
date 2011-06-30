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
  return [NSString stringWithFormat: @"%d %@ %@ %@ (%d) %@", 
          databaseID,
          name,
          album,
          artist,
          year,
          genre];
          
}

static iTunesPlaylist *music;
static iTunesSource *library;

NSArray *search(NSString *query) {
    SBElementArray *tracks = [music searchFor:query only:iTunesESrAAll];
    NSLog(@"%@", [tracks class]);    
    return tracks;
}


void playID(NSNumber *databaseId) {
     NSArray *matchingTracks = [[music tracks] 
       filteredArrayUsingPredicate:
         [NSPredicate predicateWithFormat:@"databaseID == %@", databaseId]];
     iTunesTrack* t = [matchingTracks objectAtIndex:0];
     NSLog(@"found track %@", [t name]);
     [t playOnce:false];
}
    

// 
void play(NSString *query, NSString *index) {
    printf("play %s %s\n", 
        [query cStringUsingEncoding: NSUTF8StringEncoding],
        [index cStringUsingEncoding: NSUTF8StringEncoding]);
    int idx = [index intValue];
    NSArray *tracks = search(query);
    iTunesTrack *t = [tracks objectAtIndex:idx];
    NSLog(@"%@", [t name]);
    [t playOnce:true];
}

int main (int argc, const char * argv[])
{


    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    
    NSString *query;
    NSString *action; 
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    if ([args count] > 2) {
        action = [args objectAtIndex:1];
        query = [args objectAtIndex:2];
    } else {
        action = @"search";
        query = @"Bach";
    };
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    library = [[iTunes sources] objectWithName:@"Library"];
    music = [[library playlists] objectWithName:@"Music"];
    if ([action isEqual: @"search"]) {
      NSArray *tracks = search(query);
      for (iTunesTrack *track in tracks) {
        printf("%s\n", [format(track) cStringUsingEncoding: NSUTF8StringEncoding]);
      }
    } else if ([action isEqual: @"playID"]) { /* play by databaseId 
                                                no need for search term
    */
      NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
      [f setNumberStyle:NSNumberFormatterDecimalStyle];
      NSNumber *databaseId = [f numberFromString:[args objectAtIndex: 2]];
      [f release];
      NSLog(@"looking for track %@", databaseId);
      playID(databaseId);


    } else  { /* play by index */
      NSString *index = [args objectAtIndex: 3];
      play(query, index);
    }


    [pool drain];
    return 0;
}


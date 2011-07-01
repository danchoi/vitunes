//
//  main.m
//  vitunes
//
//  Created by Daniel Choi on 6/29/11.
//  Copyright 2011 by Daniel Choi. All rights reserved.
//
#import "iTunes.h"
#import <Foundation/Foundation.h>

static iTunesApplication *iTunes;
static iTunesPlaylist *libraryPlaylist; 
static iTunesSource *library;

NSString *formatTrackForDisplay(iTunesTrack *track) {
  NSString *artist = [track.artist stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
  NSString *name = [track.name stringByPaddingToLength:30 withString:@" " startingAtIndex:0];
  NSString *genre = [track.genre stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
  NSString *time = [track.time stringByPaddingToLength:7 withString:@" " startingAtIndex:0];
  NSString *kind = [track.kind stringByPaddingToLength:29 withString:@" " startingAtIndex:0];
  NSString *year;
  if (track.year != 0) {
    year = [NSString stringWithFormat:@"%d", track.year];
  } else {
    year = @"    ";
  }
  NSString *album = [track.album stringByPaddingToLength:30 withString:@" " startingAtIndex:0];
  return [NSString stringWithFormat: @"%@ | %@ | %@ | %@ | %@ | %@ | %@ | %d", 
          artist,
          name,
          album,
          year,
          genre,
          time,
          kind,
          track.databaseID
            ];
}

SBElementArray *search(NSArray *args)  {
  NSString *query = [args componentsJoinedByString:@" "];
  return [libraryPlaylist searchFor:query only:iTunesESrAAll];
}

void playTrackID(NSString *trackID) {
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *databaseId = [f numberFromString:trackID];
  [f release];
  NSArray *xs = [[libraryPlaylist tracks] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"databaseID == %@", databaseId]];
  iTunesTrack* t = [xs objectAtIndex:0];
  NSLog(@"Playing track: %@", [t name]);
  // TODO report a missing track?
  [t playOnce:true]; // false would play next song on list after this one finishes
}

void groupTracksBy(NSString *property) {
  // gets list of all e.g. artists, genres
  // NOTE year won't work yet
  // NOTE pipe the output through uniq 
  NSArray *results = [[[libraryPlaylist tracks] arrayByApplyingSelector:NSSelectorFromString(property)]
    filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"%@ != ''", property]];
  NSArray *sortedResults = [results sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  for (NSString *s in sortedResults) {
    printf("%s\n", [s cStringUsingEncoding: NSUTF8StringEncoding]);
  }
}

void printTracks(NSArray *tracks) {
  for (iTunesTrack *track in tracks) {
    printf("%s\n", [formatTrackForDisplay(track) cStringUsingEncoding: NSUTF8StringEncoding]);
  }
}

void playlists() {
  for (iTunesPlaylist *p in [library playlists]) {
    printf("%s\n", [p.name cStringUsingEncoding: NSUTF8StringEncoding]);
  }
}

void playlistTracks(NSString *playlistName) {
  iTunesPlaylist *playlist = [[library playlists] objectWithName:playlistName];
  printTracks([playlist tracks]);
}

void playPlaylist(NSString *playlistName) {
  iTunesPlaylist *playlist = [[library playlists] objectWithName:playlistName];
  [playlist playOnce:true];
}

void tracksMatchingPredicate(NSString *predString) {
  // predicate can be something like "artist == 'U2'"
  NSArray *tracks = [[libraryPlaylist tracks] 
    filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:predString]];
  printTracks(tracks);
}

// This dispatches to any methods on iTunesApplication with no parameters.
// If method returns an iTunesItem, its 'name' property will be called and
// displayed.
void itunes(NSString *command) {
  SEL selector = NSSelectorFromString(command);
  id result = [iTunes performSelector:selector];
  if (result) {
    if ([result respondsToSelector:@selector(name)]) {
      NSString *s;
      // Note that the real classname is ITunesTrack, not iTunesTrack;
      if ([[result className] isEqual:@"ITunesTrack"])
        s = formatTrackForDisplay((iTunesTrack *)result);
      else
        s = ((iTunesItem *)result).name;
      printf("%s\n", [s cStringUsingEncoding: NSUTF8StringEncoding]);
    }
  }
}



int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  NSArray *rawArgs = [[NSProcessInfo processInfo] arguments];
  NSString *action;
  NSArray *args;
  if ([rawArgs count] < 2) {
    action = @"search";
    args = [NSArray arrayWithObject:@"bach"];
  } else {
    action = [rawArgs objectAtIndex:1];
    NSRange aRange;
    aRange.location = 2;
    aRange.length = [rawArgs count] - 2;
    args = [rawArgs subarrayWithRange:aRange];
  }
  iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  library = [[iTunes sources] objectWithName:@"Library"];
  libraryPlaylist = [[library playlists] objectWithName:@"Library"];

  if ([action isEqual: @"search"]) {
    printTracks(search(args));
  } else if ([action isEqual: @"playTrackID"]) { 
    playTrackID([args objectAtIndex:0]);
  } else if ([action isEqual: @"group"]) {
    groupTracksBy([args objectAtIndex:0]);
  } else if ([action isEqual: @"predicate"]) {
    tracksMatchingPredicate([args objectAtIndex:0]);
  } else if ([action isEqual: @"playlists"]) {
    playlists();
  } else if ([action isEqual: @"playlistTracks"]) {
    playlistTracks([args objectAtIndex:0]);
  } else if ([action isEqual: @"playPlaylist"]) {
    playPlaylist([args objectAtIndex:0]);
  } else if ([action isEqual: @"itunes"]) {
    // argument is an action for iTunesApplication to perform
    itunes([args objectAtIndex:0]);
  }
  [pool drain];
  return 0;
}


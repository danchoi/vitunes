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
int const ARTIST_COL = 26;
int const TRACK_NAME_COL = 33;
int const GENRE_COL = 15;
int const KIND_COL = 29;
int const TIME_COL = 7;
int const YEAR_COL = 4;
int const ALBUM_COL = 30;

NSString *trackListHeader() {
  NSString *artist = [@"Artist" stringByPaddingToLength:ARTIST_COL withString:@" " startingAtIndex:0];
  NSString *name = [@"Track" stringByPaddingToLength:TRACK_NAME_COL withString:@" " startingAtIndex:0];
  NSString *genre = [@"Genre" stringByPaddingToLength:GENRE_COL withString:@" " startingAtIndex:0];
  NSString *time = [@"Time" stringByPaddingToLength:TIME_COL withString:@" " startingAtIndex:0];
  NSString *kind = [@"Kind" stringByPaddingToLength:KIND_COL withString:@" " startingAtIndex:0];
  NSString *year = [@"Year" stringByPaddingToLength:YEAR_COL withString:@" " startingAtIndex:0];
  NSString *album = [@"Album" stringByPaddingToLength:ALBUM_COL withString:@" " startingAtIndex:0];

  NSString *artistSpacer = [@"-" stringByPaddingToLength:ARTIST_COL withString:@"-" startingAtIndex:0];
  NSString *nameSpacer = [@"-" stringByPaddingToLength:TRACK_NAME_COL withString:@"-" startingAtIndex:0];
  NSString *genreSpacer = [@"-" stringByPaddingToLength:GENRE_COL withString:@"-" startingAtIndex:0];
  NSString *timeSpacer = [@"-" stringByPaddingToLength:TIME_COL withString:@"-" startingAtIndex:0];
  NSString *kindSpacer = [@"-" stringByPaddingToLength:KIND_COL withString:@"-" startingAtIndex:0];
  NSString *yearSpacer = [@"-" stringByPaddingToLength:YEAR_COL withString:@"-" startingAtIndex:0];
  NSString *albumSpacer = [@"-" stringByPaddingToLength:ALBUM_COL withString:@"-" startingAtIndex:0];

  NSString *headers = [NSString stringWithFormat: @"%@ | %@ | %@ | %@ | %@ | %@ | %@ | DatabaseID", artist, name, album, year, genre, time, kind ];
  NSString *divider = [NSString stringWithFormat: @"%@-|-%@-|-%@-|-%@-|-%@-|-%@-|-%@-|-----------", 
           artistSpacer, nameSpacer, albumSpacer, yearSpacer, genreSpacer, timeSpacer, kindSpacer ];
  return [NSString stringWithFormat:@"%@\n%@", headers, divider];
};

NSString *formatTrackForDisplay(iTunesTrack *track) {
  NSString *artist = [track.artist stringByPaddingToLength:ARTIST_COL withString:@" " startingAtIndex:0];
  NSString *name = [track.name stringByPaddingToLength:TRACK_NAME_COL withString:@" " startingAtIndex:0];
  NSString *genre = [track.genre stringByPaddingToLength:GENRE_COL withString:@" " startingAtIndex:0];
  NSString *time = [track.time stringByPaddingToLength:TIME_COL withString:@" " startingAtIndex:0];
  NSString *kind = [track.kind stringByPaddingToLength:KIND_COL withString:@" " startingAtIndex:0];
  NSString *year;
  if (track.year != 0) {
    year = [NSString stringWithFormat:@"%d", track.year];
  } else {
    year = @"    ";
  }
  NSString *album = [track.album stringByPaddingToLength:ALBUM_COL withString:@" " startingAtIndex:0];
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

NSNumber *convertNSStringToNumber(NSString *s) {
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *result = [f numberFromString:s];
  [f release];
  return result;
}

iTunesTrack *findTrackID(NSString *trackID) {
  NSNumber *databaseId = convertNSStringToNumber(trackID);
  NSArray *xs = [[libraryPlaylist tracks] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"databaseID == %@", databaseId]];
  iTunesTrack* t = [xs objectAtIndex:0];
  return t;
}

void playTrackID(NSString *trackID) {
  iTunesTrack* t = findTrackID(trackID);
  NSLog(@"Playing track: %@", [t name]);
  // TODO report a missing track
  [t playOnce:true]; // false would play next song on list after this one finishes
}

void playTrackIDFromPlaylist(NSString *trackID, NSString *playlistName) {
  NSNumber *databaseId = convertNSStringToNumber(trackID);
  iTunesPlaylist *playlist =  [[library playlists] objectWithName:playlistName];
  NSArray *xs = [[playlist tracks] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"databaseID == %@", databaseId]];
  if ([xs count] == 0) {
    NSLog(@"Could not find trackID: %@ in playlist: %@. Playing from Library.", trackID, playlistName);
    playTrackID(trackID);
    return;
  } else {
    iTunesTrack* t = [xs objectAtIndex:0];
    NSLog(@"Playing track: %@ from playlist: %@", [t name], playlistName);
    [t playOnce:false]; // play playlist continuously
  }
}

void addTracksToPlaylistName(NSString *trackIds, NSString *playlistName) {
  iTunesPlaylist *playlist =  [[library playlists] objectWithName:playlistName];
  for (NSString *trackID in [trackIds componentsSeparatedByString:@","]) {
    iTunesTrack* t = findTrackID(trackID);
    NSLog(@"Adding track: %@ to playlist: %@", [t name], [playlist name]);
    [t duplicateTo:playlist];
  }
}

// TODO This doesn't seem to work
void rmTracksFromPlaylistName(NSString *trackIds, NSString *playlistName) {
  iTunesPlaylist *playlist =  [[library playlists] objectWithName:playlistName];

  for (NSString *trackID in [trackIds componentsSeparatedByString:@","]) {
    iTunesTrack* t = findTrackID(trackID);
    NSLog(@"Removing track: %@ from playlist: %@", [t name], [playlist name]);
    [[playlist tracks] removeObject:t];
  }

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
  printf("%s\n", [trackListHeader() cStringUsingEncoding: NSUTF8StringEncoding]);
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
  if (playlist == nil) {
    NSLog(@"No playlist found: %@", playlistName);
  }
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
      // For current Track
      if ([[result className] isEqual:@"ITunesTrack"]) {
        if ([result name ] == nil) {
          printf("No current track");
          return;
        }
        s = [NSString stringWithFormat:@"\"%@\" by %@",
           [((iTunesTrack *)result) name],
           [((iTunesTrack *)result) artist]
        ];
        printf("%s", [s cStringUsingEncoding: NSUTF8StringEncoding]);
      } else if ([[result className] isEqual:@"ITunesPlaylist"]) {
        if ([result name ] == nil) {
          printf("No current playlist");
          return;
        }
        s = [NSString stringWithFormat:@"%@", [((iTunesPlaylist *)result) name]];
        printf("%s", [s cStringUsingEncoding: NSUTF8StringEncoding]);
      } else {
        s = ((iTunesItem *)result).name;
        printf("%s\n", [s cStringUsingEncoding: NSUTF8StringEncoding]);
      }
    }
  }
}

void turnVolume(NSString *direction) {
  NSInteger currentVolume = iTunes.soundVolume;
  NSInteger increment = 8;
  if (currentVolume < 100 && [direction isEqual:@"up"]) {
    iTunes.soundVolume += increment;
  } else if (currentVolume > 0 && [direction isEqual:@"down"]) {
    iTunes.soundVolume -= increment;
  }
  printf("Changing volume %d -> %d", (int)currentVolume, (int)iTunes.soundVolume);
}

void newPlaylist(NSString *name) {
  // note that we have to force realize it with get to check for missing
  iTunesPlaylist *existingPlaylist = [[[library playlists] objectWithName:name] get];
  if (existingPlaylist != nil) {
    printf("%s already exists", [[existingPlaylist name] cStringUsingEncoding: NSUTF8StringEncoding]);
    return;
  }
  NSDictionary *props = [NSDictionary dictionaryWithObject:name forKey:@"name"];
  iTunesPlaylist *playlist = [[[iTunes classForScriptingClass:@"playlist"] alloc] initWithProperties:props];
  [[library playlists] addObject:playlist]; 
  printf("Created new playlist: %s", [name cStringUsingEncoding:NSUTF8StringEncoding]);
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
  } else if ([action isEqual: @"playTrackIDFromPlaylist"]) { 
    playTrackIDFromPlaylist([args objectAtIndex:0], [args objectAtIndex:1]);
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
  } else if ([action isEqual: @"addTracksToPlaylist"]) { 
    // make sure to quote args
    addTracksToPlaylistName([args objectAtIndex:0], [args objectAtIndex:1]);
  } else if ([action isEqual: @"volumeUp"]) {
    turnVolume(@"up");
  } else if ([action isEqual: @"volumeDown"]) {
    turnVolume(@"down");
  } else if ([action isEqual: @"newPlaylist"]) {
    newPlaylist([args objectAtIndex:0]); 
  } else if ([action isEqual: @"itunes"]) {
    // argument is an action for iTunesApplication to perform
    itunes([args objectAtIndex:0]);
  }
  [pool drain];
  return 0;
}


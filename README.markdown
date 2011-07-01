# ViTunes

ViTunes lets you control and navigate iTunes from the comfort of Vim.

[screenshots]

Benefits:

* control iTunes without leaving Vim, where the work happens
* avoid using the mouse or trackpad; keystrokes get you there faster
* control iTunes running on a remote computer 
* let multiple people control one instance of iTunes over ssh

## Prerequisites

* Ruby 1.8.6 or higher (developed on Ruby 1.9.2)
* OS X (tested on Snow Leopard 10.6)
* Vim 7.2 or higher (tested on Vim 7.3)

## Install

    gem install vitunes

Then

    vitunes-install

`vitunes-install` installs a Vim plugin into your ~/.vim/plugin
directory. 

## How to use it 

### General commands

* `,i` invoke or dismiss ViTunes (if not, it might be `\i` on your system)
* `?` show help and commands

### Navigation

* `,s` search iTunes library by search query
* `,p` select playlist
* `,a` select artist
* `,g` select genre
* `,A` select album
* `ENTER` start playing a track under cursor

The selection drop-downs make use of Vim autocompletion. Start typing
the first few letters of what you want. For example, if you want to jump to all
artists that start with the letter 'P', type 'P' and you'll see the drop-down
items update. This autocompletion is case-sensitive.

`CTRL-p` and `CTRL-n` let you navigate the drop-down matches. Press `ENTER` to select
one.

Press `ENTER` or `ESC` to exit either search query or drop-down selection mode.

### Volume Control

* `+` louder
* `-` softer
* `=` louder

### Playhead

* `SPACEBAR` play/pause
* `>` next track
* `<` previous track
* `.` show current track and playlist, if any

### Copying tracks

* `,c` copy track(s) to a playlist

To copy tracks, put the cursor on a track or select a range of tracks,
and then hit `,c` to select a playlist to copy them to. The tracks will be
added to the end of the playlist.

## How to contact the developer

My name is Daniel Choi. I specialize in Ruby, Rails, MySQL, PostgreSQL, and
iOS development. I am based in Cambridge, Massachusetts, USA, and my little
software company is called Kaja Software. 

* Company Email: info@kajasoftware.com
* Twitter: [@danchoi][twitter] 
* Personal Email: dhchoi@gmail.com  
* My Homepage: <http://danielchoi.com/software>

[twitter]:http://twitter.com/#!/danchoi



" Vim script that add ability to search and play iTunes tracks from Vim
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi
"
" uncomment for production
" let s:vitunes_tool = 'vitunes'
" development build of command line tool
let s:vitunes_tool = '/Users/choi/projects/vitunes/build/Release/vitunes '

let s:searchPrompt = "Search iTunes Music Library: "
let s:getPlaylistsCommand = s:vitunes_tool . "playlists"
let s:selectPlaylistPrompt = "Select playlist: "
let s:getArtistsCommand = s:vitunes_tool . "group artist | uniq "
let s:selectArtistPrompt = "Select artist: "
let s:getGenresCommand = s:vitunes_tool . "group genre | uniq "
let s:selectGenrePrompt = "Select genre: "
let s:getAlbumsCommand = s:vitunes_tool . "group album | uniq "
let s:selectAlbumPrompt = "Select album: "

func! s:trimString(string)
  let string = substitute(a:string, '\s\+$', '', '')
  return substitute(string, '^\s\+', '', '')
endfunc


" the main window
function! ViTunes()
  leftabove split ViTunesBuffer
  setlocal textwidth=0
  setlocal buftype=nofile
  noremap <buffer> ,s :call <SID>openQueryWindow()<cr>
  noremap <buffer> ,p :call <SID>openPlaylistDropdown()<cr>
  noremap <buffer> ,a :call <SID>openArtistDropdown()<cr>
  noremap <buffer> ,g :call <SID>openGenreDropdown()<cr>
  noremap <buffer> ,A :call <SID>openAlbumDropdown()<cr>
  "noremap <buffer> <cr> <Esc>:call <SID>playTrack()<cr>
  noremap <buffer> <cr> :call <SID>playTrack()<cr>
  setlocal nomodifiable
endfunction

function! s:playTrack()
  let trackID = matchstr(getline(line('.')), '\d\+$')
  call system(s:vitunes_tool . "playTrackID " . trackID)
endfunc

function! s:openQueryWindow()
  leftabove split SearchTracks
  setlocal textwidth=0
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('search')<cr>
  noremap <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('search')<cr>
  noremap <buffer> q <Esc>:close
  inoremap <buffer> <Esc> <Esc>:close<CR>
  noremap <buffer> <Esc> <Esc>:close<CR>
  let s:selectionPrompt = s:searchPrompt " this makes sure we parse the query correctly
  call setline(1, s:searchPrompt)
  normal $
  call feedkeys("a", "t")
endfunction

function! GenericCompletion(findstart, base)
  if a:findstart
    let prompt = s:selectionPrompt
    let start = len(prompt) 
    return start
  else
    if (a:base == '')
      return s:selectionList
    else
      let res = []
      " find tracks matching a:base
      for m in s:selectionList
        " why doesn't case insensitive flag work?
        if m =~ '\c' . a:base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

function! s:commonDropDownConfig()
  setlocal textwidth=0
  setlocal completefunc=GenericCompletion
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  normal $
endfunction


" Drop downs

function! s:openPlaylistDropdown()
  leftabove split ChoosePlaylist
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('playlistTracks')<CR> 
  call setline(1, s:selectPlaylistPrompt)
  call <SID>commonDropDownConfig()
  let s:selectionList = split(system(s:getPlaylistsCommand), '\n')
  let s:selectionPrompt = s:selectPlaylistPrompt
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

function! s:openArtistDropdown()
  leftabove split ChoosePlaylist
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('artist')<CR> 
  call setline(1, s:selectArtistPrompt)
  call <SID>commonDropDownConfig()
  let s:selectionList = split(system(s:getArtistsCommand), '\n')
  let s:selectionPrompt = s:selectArtistPrompt
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

function! s:openGenreDropdown()
  leftabove split ChoosePlaylist
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('genre')<CR> 
  call setline(1, s:selectGenrePrompt)
  call <SID>commonDropDownConfig()
  let s:selectionList = split(system(s:getGenresCommand), '\n')
  let s:selectionPrompt = s:selectGenrePrompt
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

function! s:openAlbumDropdown()
  leftabove split ChoosePlaylist
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('album')<CR> 
  call setline(1, s:selectAlbumPrompt)
  call <SID>commonDropDownConfig()
  let s:selectionList = split(system(s:getAlbumsCommand), '\n')
  let s:selectionPrompt = s:selectAlbumPrompt
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction



" selection window pick or search window query
function! s:submitQueryOrSelection(command)
  if (getline('.') =~ '^\s*$')
    close
    return
  endif

  let query = getline('.')[len(s:selectionPrompt):] " get(split(getline('.'), ':\s*'), 1)
  close
  " echom query
  if (len(query) == 0 || query =~ '^\s*$')
    return
  endif
  if a:command == 'artist'
    let bcommand = s:vitunes_tool."predicate ".shellescape("artist == '".query."'")
  elseif a:command == 'genre'
    let bcommand = s:vitunes_tool."predicate ".shellescape("genre == '".query."'") 
  elseif a:command == 'album'
    let bcommand = s:vitunes_tool."predicate ".shellescape("album == '".query."'") 
  else
    let bcommand = s:vitunes_tool . a:command . ' ' . shellescape(query)
  end
  echom bcommand
  let res = split(system(bcommand), '\n')
  setlocal modifiable
  silent! 1,$delete
  silent! put =res
  silent! 1delete
  setlocal nomodifiable
endfunction

nnoremap <silent> <leader>it :call ViTunes()<cr>

let g:ViTunesLoaded = 1


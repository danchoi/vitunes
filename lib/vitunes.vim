" Vim script that add ability to search and play iTunes tracks from Vim
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

let mapleader = ','

" uncomment for production
" let s:vitunes_tool = 'vitunes'
" development build of command line tool
let s:vitunes_tool = '/Users/choi/projects/vitunes/build/Release/vitunes '

let s:searchPrompt = "Search iTunes Music Library: "
let s:getPlaylistsCommand = s:vitunes_tool . "playlists"
let s:selectPlaylistPrompt = "Select playlist: "

func! s:trimString(string)
  let string = substitute(a:string, '\s\+$', '', '')
  return substitute(string, '^\s\+', '', '')
endfunc


" the search match window
function! ViTunes()
  leftabove split ViTunesBuffer
  setlocal textwidth=0
  setlocal buftype=nofile
  noremap <buffer> <leader>s <Esc>:call <SID>openQueryWindow()<cr>
  noremap <buffer> <leader>p <Esc>:call <SID>openPlaylistDropdown()<cr>
  noremap <buffer> <cr> <Esc>:call <SID>playTrack()<cr>
endfunction



function! s:playTrack()
  let trackID = matchstr(getline(line('.')), '^\d\+')
  echo trackID
  call system(s:vitunes_tool . "playTrackID " . trackID)
endfunc

function! s:openQueryWindow()
  leftabove split SearchTracks
  setlocal textwidth=0
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('search')<CR> 
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  call setline(1, s:searchPrompt)
  normal $
  call feedkeys("a", "t")
endfunction

function! GenericCompletion(findstart, base)
  if a:findstart
    let prompt = s:selectionPrompt
    let start = len(prompt) + 1
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


" Navigation

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


"  By Playlists 
function! s:openPlaylistDropdown()
  leftabove split ChoosePlaylist
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQueryOrSelection('playlistTracks')<CR> 
  call setline(1, s:selectPlaylistPrompt)
  call <SID>commonDropDownConfig()
  let s:selectionList = split(system(s:getPlaylistsCommand), '\n')
  let s:selectionPrompt = s:selectPlaylistPrompt
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

"  By Artist 


"  By Genre 


"  Search query


" selection window pick or search window query
function! s:submitQueryOrSelection(command)
  let query = get(split(getline('.'), ': '), 1)
  close
  if (len(query) == 0)
    return
  endif
  let command = s:vitunes_tool . a:command . ' ' . query
  let res = split(system(command), '\n')
  1,$delete
  put =res
  1delete
endfunction

nnoremap <silent> <leader>it :call ViTunes()<cr>
"
let g:ViTunesLoaded = 1


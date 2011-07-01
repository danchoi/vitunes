" Vim script that add ability to search and play iTunes tracks from Vim
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

let mapleader = ','

" uncomment for production
" let s:vitunes_tool = 'vitunes'
" development build of command line tool
let s:vitunes_tool = '/Users/choi/projects/vitunes/build/Release/vitunes '

let s:search_prompt = "Search iTunes Music Library: "
let s:getPlaylistsCommand = s:vitunes_tool . "playlists"
let s:selectPlaylistPrompt = "Select playlist: "

" the search match window
function! ViTunes()
  leftabove split ViTunesBuffer
  setlocal textwidth=0
  setlocal buftype=nofile
  noremap <buffer> <leader>s <Esc>:call <SID>openQueryWindow()<cr>
  noremap <buffer> <leader>p <Esc>:call <SID>openPlaylistDropdown()<cr>
  noremap <buffer> <cr> <Esc>:call <SID>playTrack()<cr>
  call <SID>openQueryWindow()
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
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submitQuery()<CR> 
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  call setline(1, s:search_prompt)
  normal $
  call feedkeys("a", "t")
endfunction


" Navigation

"  By Playlists 

function! s:openPlaylistDropdown()
  leftabove split ChoosePlaylist
  setlocal textwidth=0
  setlocal completefunc=PlaylistCompletion
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>selectPlaylist()<CR> 
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  call setline(1, s:selectPlaylistPrompt)
  normal $
  call feedkeys("a", "t")
endfunction

function! PlaylistCompletion(findstart, base)
  if a:findstart
    let prompt = s:selectPlaylistPrompt
    let start = len(prompt) + 1
    return start
  else
    if (a:base == '')
      let playlists = system(s:getPlaylistsCommand . ' ' . a:base)
      return split(playlists, '\n')
    else
      let res = []
      " find tracks matching a:base
      let playlists = split(system(s:getPlaylistsCommand . ' ' . a:base), '\n')
      for m in s:playlists
        if m =~ '\c' . a:base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

" turn this into more general func
function! s:selectPlaylist()
  let playlistName = get(split(getline(line('.')), ': '), 1)
  close
  echom playlistName

endfunction

"  By Artist 


"  By Genre 


"  Search query


"
" selection window pick
function! s:submitQuery()
  let query = getline('.')[len(s:search_prompt) - 1:]
  close
  if (query == '') " no selection
    return
  end
  let res = split(system(s:vitunes_tool . ' search ' . query), '\n')
  echo res
  1,$delete
  put =res
  1delete
endfunction

nnoremap <silent> <leader>it :call ViTunes()<cr>
"
let g:ViTunesLoaded = 1


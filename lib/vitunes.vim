" Vim script that add ability to search and play iTunes tracks from Vim
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

let mapleader = ','

" uncomment for production
" let s:vitunes_tool = 'vitunes'
" development build of command line tool
let s:vitunes_tool = '/Users/choi/projects/vitunes/build/Release/vitunes '

let s:search_prompt = "Search iTunes Music Library:  "
let s:search_prompt_len = len(s:search_prompt)
let s:selectionList = []

" the search match window
function! ViTunes()
  leftabove split ViTunesBuffer
  setlocal textwidth=0
  noremap <buffer> <leader>s <Esc>:call <SID>openQueryWindow()<cr>
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
  " setlocal completefunc=ViTunesCompleteFunction
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  " TODO this should depend on the type of search
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submit_query()<CR> 
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  call setline(1, s:search_prompt)
  normal $
  call feedkeys("a", "t")
endfunction

function! ViTunesCompleteFunction(findstart, base)
  if a:findstart
    let start = s:search_prompt_len
    return start
  else
    " let base = s:trimString(a:base)
    if (a:base == '')
      return [] 
    else
      let res = []
      " find tracks matching a:base
      let s:selectionList = split(s:searchTracks(a:base), '\n')
      for m in s:selectionList
        if m =~ '\c' . a:base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

function! s:search_tracks(q)
  let res = split(system(s:vitunes_tool . ' search ' . a:q), '\n')
  put =res
endfunction

" selection window pick
function! s:submit_query()
  let query = getline('.')[len(s:search_prompt):]
  close
  if (query == '') " no selection
    return
  end
  " TODO
  call s:search_tracks(query)
  "
endfunction

" get a free DRB URI
let s:drb_uri = system("vitunes_client get_uri")
"
" start vitunes_server
let s:server_info = system("vitunes_server " . s:drb_uri . " &")
echo s:server_info
exec "!echo " . s:server_info
finish
let s:drb_uri = split(s:server_info, ',')[0]
let s:pid = split(s:server_info, ',')[1]

echo s:server_info
echo s:drb_uri

" TODO quit server on Vim quit
let g:ViTunesLoaded = 1


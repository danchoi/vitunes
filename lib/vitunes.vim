" Vim script that add ability to search and play iTunes tracks from Vim
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

let mapleader = ','
let s:search_command = 'vitunes search '
let s:search_prompt = "Search iTunes Music Library: "

function! ViTunes()
  exec "leftabove split "
  setlocal textwidth=0
  setlocal completefunc=ViTunesCompleteFunction
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>submit_query()<CR> 
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  call setline(1, s:search_prompt)
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

function! ViTunesCompleteFunction(findstart, base)
  if a:findstart
    let start = len(s:search_prompt) 
    return start
  else
    let base = s:trimString(a:base)
    if (base == '')
      " TODO call ViTunes search
      return s:selectionlist
    else
      let res = []
      for m in s:selectionlist
        if m =~ '\c' . base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

" selection window pick
function! s:submit_query()
  " let query = s:trimString(join(split(getline(line('.')), ":")[1:-1], ":"))
  let query = getline('.')[len(s:prompt):]
  close
  if (query == '') " no selection
    return
  end
  " TODO
  " call ViTunes with query
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


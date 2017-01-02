""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Make sure compatible mode is off (compatibility with vi)
:set nocompatible

"""" BACKUP AND UNDO
" Makes undo file
set undofile
" Keeps 50 lines of command line history
set history=75
" Makes backup file
set backup
set writebackup
" This puts all backup and undo files in a separate folder
set backupdir=~/.vimbackup
set directory=~/.vimbackup
set undodir=~/.vimbackup
" <C-G>u starts a new change to allow recovering text that is deleted with C-U
" and C-w.
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" Sets color scheme
set background=dark
colorscheme solarized

"""" UI CONFIG
" Shows cursor position
set ruler
" Shows line numbers
set number
" Shows commands at the bottom
set showcmd
" Highlights current line
set cursorline
" Graphical menu for autocomplete (with tab)
set wildmenu
" Faster macros by redrawing only when necessary
set lazyredraw
" Highlights the matching char for [], (), {}
set showmatch
" Use auto indent
set autoindent
" Turn on filetype detection, filetype-specific scripts, and
" filetype-specific indent scripts
filetype plugin indent on

"""" SEARCHING
" Search as characters are entered
set incsearch
" Highlight matches
set hlsearch
" Turn off search highlight with <leader> (\) and <space>
nnoremap <leader><space> :nohlsearch<CR>
" Used for syntax highlighting. Use 'syntax on' to override colors with with
" default colors
syntax enable

"""" MOVEMENT
" Remap line motion commands for real vs display lines
nnoremap k gk
nnoremap gk k 
nnoremap j gj
nnoremap gj j
" Allow mouse use
if has('mouse')
  set mouse=a
endif

"""" TEXT MANIP
" Allows for backspace of everything in insert mode
set backspace=indent,eol,start

"""" MISC
" To not accidentally enter Ex mode
nnoremap Q <nop>
" Use F8 to compile and run C++ code
map <F8> :w <CR> :!g++ -std=c++11 % -o %< && ./%< <CR>

"""" PLUGINS AND PACKAGES

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''
" Example

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
\ if line("'\"") >= 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

augroup END


" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif


" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
packadd matchit

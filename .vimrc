""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Make sure compatible mode is off (compatibility with vi)
:set nocompatible

""""""""""""""""""""""""""
"""" VUNDLE (PLUGIN MANAGER)
""""""""""""""""""""""""""
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Status/tabline
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

""""""""""""""""""""""""""
"""" AIRLINE
""""""""""""""""""""""""""
set laststatus=2
set ttimeoutlen=50
" Theme
let g:airline_theme='solarized'

""""""""""""""""""""""""""
"""" BACKUP AND UNDO
""""""""""""""""""""""""""
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

""""""""""""""""""""""""""
"""" UI CONFIG
""""""""""""""""""""""""""
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
" Show title
set title
" Shows status line
set laststatus=2



""""""""""""""""""""""""""
"""" SEARCHING
""""""""""""""""""""""""""
" Search as characters are entered
set incsearch
" Highlight matches
set hlsearch
" Turn off search highlight with <leader> (\) and <space>
nnoremap <leader><space> :nohlsearch<CR>
" Used for syntax highlighting. Use 'syntax on' to override colors with with
" default colors
syntax enable

""""""""""""""""""""""""""
"""" MOVEMENT
""""""""""""""""""""""""""
" Remap line motion commands for real vs display lines
nnoremap k gk
nnoremap gk k 
nnoremap j gj
nnoremap gj j
" Allow mouse use
if has('mouse')
  set mouse=a
endif

""""""""""""""""""""""""""
"""" TEXT MANIP
""""""""""""""""""""""""""
" Allows for backspace of everything in insert mode
set backspace=indent,eol,start

""""""""""""""""""""""""""
"""" FOLDING
""""""""""""""""""""""""""
" Enable folding
set foldenable
" Sets the fold levels when first opening a buffer
set foldlevelstart=10
" To make sure there aren't too many folds (guard against too many folds)
set foldnestmax=10
" Folds based on indent level
set foldmethod=indent

""""""""""""""""""""""""""
"""" MISC
""""""""""""""""""""""""""

" To not accidentally enter Ex mode
nnoremap Q <nop>
" Use F8 to compile and run C++ code
map <F8> :w <CR> :!g++ -std=c++11 % -o %< && ./%< <CR>
" Remap C-n for Nerd Tree
map <C-n> :NERDTreeToggle<CR>

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

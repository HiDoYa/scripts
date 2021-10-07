""""""""""""""""""""""""""
" Compatible mode with vi is off
""""""""""""""""""""""""""
:set nocompatible

""""""""""""""""""""""""""
"""" VUNDLE (PLUGIN MANAGER)
""""""""""""""""""""""""""
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" Status line
Plugin 'bling/vim-airline'
" Status line theme
Plugin 'vim-airline/vim-airline-themes'
" Git wrapper
Plugin 'tpope/vim-fugitive'
" Filesystem explorer
Plugin 'scrooloose/nerdtree'
" Prettier/linter
Plugin 'prettier/vim-prettier'
" Git diff visualizer
Plugin 'airblade/vim-gitgutter'
" Comment functions
Plugin 'scrooloose/nerdcommenter'
" Aligning text
Plugin 'godlygeek/tabular'
" Autocomplete
Plugin 'shougo/deoplete.nvim'

" Finish vundle plugin loading
call vundle#end()
filetype plugin indent on

" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

""""""""""""""""""""""""""
"""" THEME
""""""""""""""""""""""""""
" Sets color scheme
colorscheme slate

""""""""""""""""""""""""""
"""" AIRLINE
""""""""""""""""""""""""""
" Sets status bar theme
let g:airline_theme='simple'

""""""""""""""""""""""""""
"""" BACKUP AND UNDO
""""""""""""""""""""""""""
" Keeps 50 lines of command line history
set history=50
" Makes undo file
set undofile
" Makes backup file
set backup
set writebackup
" This puts all backup and undo files in a separate folder
set backupdir=~/.vimbackup
set directory=~/.vimbackup
set undodir=~/.vimbackup

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
"""" CUSTOM TAB SIZE
""""""""""""""""""""""""""
function! SetTab(size)
	execute "set tabstop=". a:size
	execute "set shiftwidth=". a:size
	set expandtab
:endfunction

function! ResetTab()
	set tabstop=8
	set shiftwidth=8
	set noexpandtab
:endfunction

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
"""" NERDTREE
""""""""""""""""""""""""""
" Show hidden files
let NERDTreeShowHidden = 1

" Automatically exits nerd tree upon file close
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Automatically opens nerdtree on new tab
autocmd BufWinEnter * NERDTreeMirror

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
" Folds persist over sessions
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview

""""""""""""""""""""""""""
"""" MISC
""""""""""""""""""""""""""
" To not accidentally enter Ex mode
nnoremap Q <nop>
" Remap C-n for Nerd Tree
map <C-n> :NERDTreeToggle<CR>
" Timeout for key codes
set ttimeoutlen=50
" Allow backspace to remove indentations, newlines, etc.
set backspace=indent,eol,start
" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
\ if line("'\"") >= 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

""""""""""""""""""""""""""
"""" GIT GUTTER
""""""""""""""""""""""""""
" Git signs update time
set updatetime=100
" Keep default highlighting for 'sign' (+/-) column
" Note: this must be at bottom, else it fails
highlight clear SignColumn
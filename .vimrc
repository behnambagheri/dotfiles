"
" =============================
"   Optimized .vimrc Configuration
" =============================

" Enable line numbers
set number
"set relativenumber     " Relative line numbers for easier navigation

" Enable syntax highlighting and color scheme
syntax enable
set termguicolors      " Use full 24-bit colors
colorscheme molokai

" Better searching
set ignorecase         " Ignore case in searches
set smartcase          " Case-sensitive if search contains uppercase
set incsearch          " Show matches as you type
set hlsearch           " Highlight matches

" Indentation and tab settings
set expandtab          " Use spaces instead of tabs
set tabstop=4          " Number of spaces per tab
set shiftwidth=4       " Number of spaces for autoindent
set softtabstop=4      " Soft tab stops for smoother indenting
set autoindent         " Copy indentation from previous line
set smartindent        " Smart auto-indentation

" Clipboard
set clipboard=unnamedplus  " Use system clipboard for copy/paste

" Status line and UI improvements
set showcmd            " Show commands as you type them
set wildmenu           " Enhance command-line completion
set ruler              " Show cursor position in status bar
set cursorline         " Highlight the current line

" Scrolling and window behavior
set scrolloff=5        " Keep 5 lines above and below cursor
set sidescrolloff=8    " Keep some padding at the sides
set lazyredraw         " Don't redraw screen while executing macros
set nowrap             " Don't wrap long lines

" Undo and backup settings
set undofile           " Enable persistent undo
set undodir=~/.vim/undo

" Folding
set foldmethod=indent  " Fold based on indentation
set foldlevel=99       " Open all folds by default

" Performance tweaks for large files
set nocursorline       " Disable cursorline for better performance
set synmaxcol=200      " Limit syntax highlighting for long lines

" Key mappings
nnoremap <Space> :noh<CR>   " Spacebar clears search highlights
" plugins

"Vim-Pluged
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/Yggdroot/indentLine'
Plug 'https://github.com/elzr/vim-json'
Plug 'stephpy/vim-yaml'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()


:filetype plugin on " This line enables loading the plugin files for specific file types
:set showmatch " Show matching brackets
:map <C-p> :w<CR>:!chmod +x;clear;python3 './%' <CR>
:map <C-b> :w<CR>:!chmod +x;clear;bash './%' <CR>
:set pastetoggle=<F2> " Paste mode toggle with F2 Pastemode disable auto-indent and bracket auto-compelation and it helps you to paste code fro elsewhere .
" autocomplpop setting
:set omnifunc=syntaxcomplete " This is necessary for acp plugin
:let g:acp_behaviorKeywordLength = 1 "  Length of keyword characters before the cursor, which are needed to attempt keyword completion




au! BufRead,BufNewFile *.json set filetype=json
augroup json_autocmd
  autocmd!
  autocmd FileType json set autoindent
  autocmd FileType json set formatoptions=tcq2l
  autocmd FileType json set textwidth=78 shiftwidth=2
  autocmd FileType json set softtabstop=2 tabstop=8
  autocmd FileType json set expandtab
  autocmd FileType json set foldmethod=syntax
augroup END

set encoding=utf-8

:set guioptions+=a



" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>


nnoremap <F3> :if &number == 1 \| set nonumber norelativenumber \| else \| set number \| endif<CR>" =============================
nnoremap <F4> :IndentLinesToggle<CR>


:filetype plugin on " This line enables loading the plugin files for specific file types
" Define comment leaders based on file type
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python,bash let b:comment_leader = '# '

" Define comment leaders based on file type
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python,bash let b:comment_leader = '# '

" Map F5 to toggle comments
noremap <silent> <F5> :<C-B>silent <C-E>call ToggleComment()<CR>

" Toggle function
function! ToggleComment()
    " Check if the current line is commented
    if getline('.') =~ '^\s*' . escape(b:comment_leader, '/\*.$^~[]')
        " Uncomment the line
        execute 'silent! s/^\s*' . escape(b:comment_leader, '/\*.$^~[]') . '//e'
    else
        " Comment the line
        execute 'silent! s/^/\=b:comment_leader/'
    endif
    nohlsearch
endfunction


" Toggle mouse support with F6
nnoremap <F6> :call ToggleMouse()<CR>

" Function to enable/disable mouse
function! ToggleMouse()
    if &mouse == 'a'
        set mouse=
        echo "Mouse disabled"
    else
        set mouse=a
        echo "Mouse enabled"
    endif
endfunction

"  End of .vimrc
" =============================







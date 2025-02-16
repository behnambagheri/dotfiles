set number
set termguicolors      " Use full 24-bit colors
set ignorecase         " Ignore case in searches
set smartcase          " Case-sensitive if search contains uppercase
set incsearch          " Show matches as you type
set hlsearch           " Highlight matches
set expandtab          " Use spaces instead of tabs
set tabstop=4          " Number of spaces per tab
set shiftwidth=4       " Number of spaces for auto-indent
set softtabstop=4      " Soft tab stops for smoother indenting
set autoindent         " Copy indentation from previous line
set smartindent        " Smart auto-indentation
set clipboard=unnamedplus  " Use system clipboard for copy/paste
set showcmd            " Show commands as you type them
" set wildmenu           " Enhance command-line completion
set ruler              " Show cursor position in status bar
set cursorline         " Highlight the current line
set scrolloff=5        " Keep 5 lines above and below cursor
set sidescrolloff=8    " Keep some padding at the sides
set lazyredraw         " Don't redraw screen while executing macros
set nowrap             " Don't wrap long lines
set undofile           " Enable persistent undo
set undodir=~/.vim/undo
" set foldmethod=indent  " Fold based on indentation
" set foldlevel=99       " Open all folds by default
" set synmaxcol=200      " Limit syntax highlighting for long lines
set encoding=utf-8
" set mouse=a            " Enable mouse support

syntax enable
set termguicolors      " Use full 24-bit colors
colorscheme molokai

" Key mappings
nnoremap <Space> :noh<CR>   " Spacebar clears search highlights

" Run the current file with Python (Ctrl + P)
nnoremap <C-p> :w<CR>:!chmod +x %; clear; python3 %<CR>

" Run the current file with Bash (Ctrl + B)
nnoremap <C-b> :w<CR>:!chmod +x %; clear; bash %<CR>

" Remember the last cursor position when reopening a file
if has("autocmd")
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
endif

nnoremap <F3> :if &number == 1 \| set nonumber norelativenumber \| else \| set number \| endif<CR>



" Enable file type detection and plugin support
filetype plugin on 

" Define comment leaders based on file type
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python,bash let b:comment_leader = '# '
autocmd FileType nginx let b:comment_leader = '# '
autocmd FileType vim let b:comment_leader = '" '
autocmd FileType * if !exists('b:comment_leader') | let b:comment_leader = '# ' | endif

" Optionally set specific file type for PostgreSQL config files if needed
autocmd BufNewFile,BufRead *.conf set filetype=conf

" Map F5 to toggle comments
noremap <silent> <F5> :<C-B>silent <C-E>call ToggleCommentAndMove()<CR>

" Function to toggle comments on a line and move to the next
function! ToggleCommentAndMove()
    if getline('.') =~ '^\s*' . escape(b:comment_leader, '/\*.$^~[]')
        " Uncomment the line
        execute 'silent! s/^\s*' . escape(b:comment_leader, '/\*.$^~[]') . '//e'
    else
        " Comment the line
        execute 'silent! s/^/\=b:comment_leader/'
    endif
    " Move cursor to the next line
    execute 'normal! j'
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


" Save a read-only file with sudo using F10
" command! x! execute 'x!' | edit!'
" nnoremap <F10> :x!<CR>


" Save a read-only file using F10 without direct sudo
nnoremap <F10> :call SudoSave()<CR>

" Function to write a read-only file
function! SudoSave()
    let l:tmpfile = tempname()
    execute 'write! ' . l:tmpfile
    execute 'silent !mv ' . shellescape(l:tmpfile) . ' ' . shellescape(expand('%'))
    edit!
    echo "File saved successfully!"
endfunction


let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

let g:python3_host_prog = '/usr/bin/python3'
" lua << EOF
" -- Bootstrap Lazy.nvim
" local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
" if not vim.loop.fs_stat(lazypath) then
"   vim.fn.system({
"     "git", "clone", "--filter=blob:none",
"     "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
"   })
" end
" vim.opt.rtp:prepend(lazypath)
" 
" require("lazy").setup({
"     { "vim-airline/vim-airline" },
"     { "Yggdroot/indentLine" },
"     { "elzr/vim-json" },
"     { "stephpy/vim-yaml" },
"     { "jiangmiao/auto-pairs" },
"     { "chr4/nginx.vim" },
"     { "neoclide/coc.nvim", branch = "release" }
" })
" EOF


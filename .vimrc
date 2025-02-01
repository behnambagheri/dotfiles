:set number " Display line numbers on the left side
:set ls=2 " This makes Vim show a status line even when only one window is shown
:filetype plugin on " This line enables loading the plugin files for specific file types
:set tabstop=4 " Set tabstop to tell vim how many columns a tab counts for. Linux kernel code expects each tab to be eight columns wide.
:set expandtab " When expandtab is set, hitting Tab in insert mode will produce the appropriate number of spaces.
:set softtabstop=4 " Set softtabstop to control how many columns vim uses when you hit Tab in insert mode. If softtabstop is less than tabstop and expandtab is not set, vim will use a combination of tabs and spaces to make up the desired spacing. If softtabstop equals tabstop and expandtab is not set, vim will always use tabs. When expandtab is set, vim will always use the appropriate number of spaces.
:set shiftwidth=4 " Set shiftwidth to control how many columns text is indented with the reindent operations (<< and >>) and automatic C-style indentation. 
":setlocal foldmethod=indent " Set folding method
:set t_Co=256 " makes Vim use 256 colors
:set nowrap " Don't Wrap lines!
:colorscheme  molokai "Set colorScheme
:set nocp " This changes the values of a LOT of options, enabling features which are not Vi compatible but really really nice
"":set clipboard=unnamed
"":set clipboard=unnamedplus
:set autoindent " Automatic indentation
:set cindent " This turns on C style indentation
:set si " Smart indent
:syntax enable " syntax highlighting
:set showmatch " Show matching brackets
:set hlsearch " Highlight in search
"":set ignorecase " Ignore case in search
:set noswapfile " Avoid swap files
:set mouse=a " Mouse Integration
""set mouse-=a


" auto complete for ( , " , ' , [ , { 
:inoremap        (  ()<Left>
:inoremap        "  ""<Left>
:inoremap        `  ``<Left>
:inoremap        '  ''<Left>
:inoremap        [  []<Left>
:inoremap      {  {}<Left>

" auto comment and uncooment with F6 and F7 key
:autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
:autocmd FileType sh,ruby,python,bash   let b:comment_leader = '# '
:noremap <silent> #6 :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR> " commenting line with F6
:noremap <silent> #7 :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR> " uncommenting line with F7

"for kde terminal(konsole)
":noremap <silent> #5 :!konsole --hold -e './%' <CR> <CR> 
" execute bash & python script with F5
:map <C-p> :w<CR>:!chmod +x;clear;python3 './%' <CR>
:map <C-b> :w<CR>:!chmod +x;clear;bash './%' <CR>

"========================================================
":noremap <silent> #5 :!xterm -hold -e './%' <CR> <CR>" execute bash & python script with F5
"noremap <silent> #6 :!chmod 755;clear;bash "./%"<CR> 
"noremap <silent> #5 :!;clear;python %<CR>
":noremap <silent> #5 :!'python ./%' <CR> <CR>" execute python script with F5
"noremap <silent> #6 :!chmod 755;clear;bash "./%"<CR> 
"noremap <silent> #5 :!;clear;python %<CR>
"noremap <silent> #6 :!chmod 755;clear;python "./%"<CR>
":noremap <silent> #5 :!konsole --hold -e './%' <CR> <CR>" execute python script with F5
":noremap <silent> #5 :!clear;konsole --hold -e 'python ./%' <CR> <CR>
"nnoremap <buffer> <F5> :exec '!python' shellescape(@%, 1)<cr>
":noremap <silent> #5 :!konsole --hold -e 'python ./%' <CR> <CR>" execute python script with F5
"========================================================

:noremap <silent> #3 :tabprevious<CR> " switch to previous tab with F3
:noremap <silent> #4 :tabnext<CR> " switch to next tab with F2
:map <F8> :setlocal spell! spelllang=en_us<CR> " check spelling with F8
:set pastetoggle=<F2> " Paste mode toggle with F2 Pastemode disable auto-indent and bracket auto-compelation and it helps you to paste code fro elsewhere .

map <C-s> :w<CR>" save project with control+s
map <C-x> :!chmod +x "./%"<CR>" execute x with control+x

" plugins

"Vim-Pluged
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/vim-airline/vim-airline-themes'
Plug 'https://github.com/Yggdroot/indentLine'
Plug 'https://github.com/enricobacis/vim-airline-clock'
Plug 'https://github.com/elzr/vim-json'
Plug 'stephpy/vim-yaml'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

"indentLine 
:let g:indentLine_char = '|'
" autocomplpop setting
:set omnifunc=syntaxcomplete " This is necessary for acp plugin
:let g:acp_behaviorKeywordLength = 1 "  Length of keyword characters before the cursor, which are needed to attempt keyword completion

" airline plugin setting
:let g:airline_theme='wombat' " set airline plugin theme
:let g:airline#extensions#tabline#enabled = 1 " showing tabs 
:let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

 " unicode symbols
  let g:airline_left_sep = '»'
  let g:airline_left_sep = '▶'
  let g:airline_right_sep = '«'
  let g:airline_right_sep = '◀'

"vim-airline-clock 
:let g:airline#extensions#clock#format = '%c'

" NERDTree plugin setting

"toggle showing NERDTree with F9
:map <F9> :NERDTreeToggle<CR> 
""nnoremap <F9> :NERDTreeToggle<CR> 

"open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Open file in new tab with ctrl + t
:let NERDTreeMapOpenInTab='<c-t>'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
            \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

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


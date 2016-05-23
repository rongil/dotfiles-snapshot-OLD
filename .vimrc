source $HOME/.vim/helper_funcs.vim
let g:RootOrTempFile=CheckIfRootOrTemp()

source $HOME/.vim/vundle_plugins.vim

"==============================================================================
" General Options
"==============================================================================
set nocompatible "More useful instead of more compatible :)
if !exists('g:syntax_on') "Don't source script again if not necessary
  syntax enable  "Enable syntax highlighting
endif
filetype plugin indent on "Enable file type detection

set wildmenu "Improved tab completion
set number "Line numbers
set splitright "Opens new vertical window on right
set splitbelow "Opens new horizontal window under

"Remove trailing whitespace on save (\v forces very magic, e flag silences errors)
autocmd BufWritePre * :%s/\v\s+$//e

set mouse=a "Enable use of the mouse for all modes (already enabled by term emulator)
set visualbell "Don't ring bell when doing something wrong
set t_vb= "Also don't show flash from visual bell
set lazyredraw "Don't redraw while performing untyped commands (e.g. macros)

"X window clipboard (without storing in clipboard unless + register specified)
set clipboard=unnamed

"==============================================================================
" Swap File Settings
"==============================================================================
"Only have swap file if file is currently in modified state
"Source: http://vi.stackexchange.com/a/69
autocmd CursorHold,BufWritePost,BufReadPost,BufLeave *
  \ if isdirectory(expand("<amatch>:h")) | let &swapfile = &modified | endif

"==============================================================================
" General Mappings
"==============================================================================
"Default is yy unlike for C and D
map Y y$

"<C-L> (redraw screen) also turns off search highlight until the next search
nnoremap <C-L> :nohl<CR><C-L>

"Jump to outside of parentheses when inside
inoremap <C-J> <ESC>%%a

"Have uppercase with same effect
command WQ wq
command Wq wq
command W w
command Q q

"==============================================================================
" Indentation
"==============================================================================
"Default Indent
set autoindent
set smartindent
set expandtab "Use spaces instead of tabs
set shiftwidth=2 softtabstop=2 tabstop=2

"Custom Indents
autocmd Filetype lua setlocal sw=4 sts=4 ts=4
autocmd Filetype python setlocal sw=4 sts=4 ts=4

"==============================================================================
" Folding
"==============================================================================
set foldmethod=indent "Sets folds based on indent by default
set foldnestmax=2 "Max nesting level

"==============================================================================
" Spell Check
"==============================================================================
set spelllang=en_us
autocmd Filetype gitcommit,markdown,tex,text if !&readonly | set spell

"==============================================================================
" Color Settings
"==============================================================================
"Color Scheme
set t_Co=256 "Use 256 colors
"set background=dark
"colorscheme blackboard
colorscheme distinguished
"colorscheme grb256
"colorscheme molokai
"colorscheme wombat256mod

"==============================================================================
" Search
"==============================================================================
set hlsearch "Search highlighting
set incsearch "Incremental search
set magic "Regex: unescaped magic chars are magic chars (rather than literals)

"==============================================================================
" Persistent Undo
"==============================================================================
" Don't keep persistent history if root-owned file or temp file
if !g:RootOrTempFile
  set undodir=~/.vim/undodir
  set undofile
  set undolevels=1000 "Maximum number of changes that can be undone
  set undoreload=10000 "Maximum number lines to save for undo on a buffer reload
endif

"==============================================================================
" Special syntax
"==============================================================================
autocmd BufNewFile,BufRead *.ejs set filetype=html

"==============================================================================
" Latex
"==============================================================================
let g:Tex_Flavor='latex'
let g:Tex_DefaultTargetFormat='pdf' "Latex compile to pdf
let g:Tex_ViewRule_pdf='zathura'
let g:Tex_CompileRule_pdf='mkdir -p build; pdflatex -output-directory build -interaction=nonstopmode $*; cp build/*.pdf .' "Place auxilary files in separate folder and copy pdf to main directory
autocmd BufWritePost,FileWritePost *.tex silent call Tex_RunLaTeX()

"==============================================================================
" PySolve (Not through Vundle)
"==============================================================================
imap <silent> <F3> <C-O>:call PySolve(0)<CR>

"==============================================================================
" Vim-Go
"==============================================================================
"let g:go_fmt_autosave = 0 "Closes all folds due to buffer rewrite
let g:go_bin_path = expand('~/.vim/go')
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <leader>f :<C-u>GoFmt<CR>

"==============================================================================
" Tern JS
"==============================================================================
let g:tern_show_argument_hints='on_hold'

"==============================================================================
" Syntastic
"==============================================================================
let g:syntastic_always_populate_loc_list = 1 "Always fill in error list
let g:syntastic_auto_loc_list = 0 "Auto display errors list
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_c_checkers = ['gcc']
let g:syntastic_c_compiler_options = '-std=c99 -Wall -Wextra -Wpedantic'
let g:syntastic_cpp_checkers = ['gcc']
let g:syntastic_cpp_compiler_options = '-std=c++11 -Wall -Wextra -Wpedantic'
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']

"Active mode must be activated manually (e.g. through SyntasticToggleMode)
"Reasoning: syntax check can cause huge slowdown when making quick changes
let g:syntastic_mode_map = {
\  'mode': 'passive',
\  'active_filetypes': [],
\  'passive_filetypes': ['go']
\}

"Shortcuts to toggle syntax checking on write
noremap <F2> :SyntasticToggleMode<CR>
inoremap <F2> <C-O>:SyntasticToggleMode<CR>

"==============================================================================
" MatchTagAlways
"==============================================================================
nnoremap <leader>% :MtaJumpToOtherTag<CR>

"==============================================================================
" Gundo Undo Tree
"==============================================================================
nnoremap <F5> :GundoToggle<CR>

"==============================================================================
" Airline Status bar
"==============================================================================
set laststatus=2 "Always show statusline

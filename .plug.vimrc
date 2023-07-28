call plug#begin('~/.vim/plugged')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Utilities
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlP
" Plug 'ctrlpvim/ctrlp.vim'
"    let g:ctrlp_user_command = 'find %s -type f'
"    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
"    let g:ctrlp_clear_cache_on_exit = 0

" LeaderF
" Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" clap: Modern performant generic finder and dispatcher for Vim and NeoVim 
" The bang version will try to download the prebuilt binary if cargo does not exist.
" Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
"   let g:clap_theme = 'material_design_dark'

" NerdTree
Plug 'preservim/nerdtree'
  let g:NERDTreeWinPos = "right"
  let NERDTreeShowHidden=0
  let NERDTreeIgnore = ['\.pyc$', '__pycache__']
  let g:NERDTreeWinSize=35
  map <leader>nn :NERDTreeToggle<cr>
  map <leader>nb :NERDTreeFromBookmark<Space>
  map <leader>nf :NERDTreeFind<cr> 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Languages
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Asynchronous Lint Engine
Plug 'dense-analysis/ale'
  let g:ale_linters = {
  \   'javascript': ['jshint'],
  \   'python': ['pyls', 'pyright', 'flake8'],
  \   'go': ['go', 'golint', 'errcheck'],
  \   'vim': ['vint'],
  \   'cpp': ['clang'],
  \   'c': ['clang']
  \}
  nmap <silent> <leader>a <Plug>(ale_next_wrap)
  " Disabling highlighting
  let g:ale_set_highlights = 1
  " Only run linting when saving the file
  let g:ale_lint_on_text_changed = 'normal'
  let g:ale_lint_on_enter = 0
  
  " Auto-completion
  let g:ale_completion_enabled = 1
  set omnifunc=ale#completion#OmniFunc
  

" Beancount
" Plug 'nathangrigg/vim-beancount'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors, Fonts and Formats
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax highlighting
Plug 'sheerun/vim-polyglot'

" Code Formatter google/vim-codefmt and its dependencies
Plug 'google/maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer yapf
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

" Theme -> One Dark
Plug 'joshdick/onedark.vim'

" Lightline
Plug 'itchyny/lightline.vim'

call plug#end()

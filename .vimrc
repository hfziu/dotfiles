" source .basic.vim from https://github.com/amix/vimrc {{{
let $VIMRC_BASIC = $HOME . "/.basic.vimrc"
if filereadable($VIMRC_BASIC)
    source $VIMRC_BASIC
endif
" }}}

" source vim plug manager configurations {{{
let $VIMRC_PLUG = $HOME . "/.plug.vimrc"
if filereadable($VIMRC_PLUG)
    source $VIMRC_PLUG
endif
" }}}


" My settings here
set nu "Line numbering
set shiftwidth=2
set tabstop=2 "Override the setting in .basic.vimrc

if has('gui_macvim')
    set guifont=JetBrains\ Mono:h13
    set linespace=3
    set macligatures

    try
        colorscheme onedark
        let g:lightline = {
          \ 'colorscheme': 'onedark',
          \ }
    catch
    endtry

endif

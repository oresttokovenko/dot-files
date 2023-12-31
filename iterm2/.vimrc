" ============================================================================= "
" Plugins                                                                       "
" ============================================================================= "

call plug#begin('~/vim/plugged')

Plug 'cormacrelf/vim-colors-github'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'
Plug 'bkad/CamelCaseMotion'

call plug#end()

" ============================================================================= "
" Display & Interface Settings                                                  "
" ============================================================================= "

syntax on
filetype on
set number
set relativenumber
set gdefault
set termguicolors

" ============================================================================= "
" Keybindings & Mappings                                                        "
" ============================================================================= "

" Leader
let mapleader = "\<space>"

" Insert Mode
inoremap jk <Esc>

" Normal Mode
nnoremap J 5j
nnoremap K 5k
nnoremap H ^
nnoremap L g_
nnoremap <Leader>a ggVG

" Visual Mode
vnoremap J 5j
vnoremap K 5k
vnoremap H ^
vnoremap L g_

" EasyMotion Remaps
map <Leader>s <Plug>(easymotion-s2)
map <Leader>j <Plug>(easymotion-j)
